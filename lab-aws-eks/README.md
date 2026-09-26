The purpose of this document is to describe how my personal AWS Organization and accounts are configured to allow different users and profiles to use IAM Identity Center to natively access and interact with an EKS cluster.

## Architecture

The setup separates centralized identity management from workload infrastructure across distinct AWS accounts within an AWS Organization.

```mermaid
flowchart TD
    subgraph Management_Account["Management Account"]
        Users["Users (admin1, dev1, dev2, ...)"]
        Groups["Identity Center Groups (admin, developer)"]
        PermSets["Permission Sets:
        - AdministratorAccess
        - PowerUserAccess"]

        Users -->|members of| Groups
        Groups -->|mapped to| PermSets
    end

    subgraph AWS_Organizations["AWS Organizations assignments"]
        AssignAdmin["Assignment: admin + AdministratorAccess -> dev AWS Account"]
        AssignDev["Assignment: developer + PowerUserAccess -> dev AWS Account"]
    end

    subgraph Dev_Account["aws-platform-dev account (385470934621)"]
        RoleAdmin["IAM Role (auto-provisioned):
        AWSReservedSSO_AdministratorAccess_*"]
        RoleDev["IAM Role (auto-provisioned):
        AWSReservedSSO_PowerUserAccess_*"]

        subgraph EKS_Access_Entries["EKS Access Entries (API Auth)"]
            EntryAdmin["aws_eks_access_entry: sso_admin
            Policy: AmazonEKSClusterAdminPolicy
            Scope: cluster"]
            EntryDev["aws_eks_access_entry: sso_poweruser
            Policy: AmazonEKSEditPolicy
            Scope: cluster"]
        end

        subgraph Cluster["EKS Cluster (dev-eks)"]
            ControlPlane["ControlPlane (API Server)"]
            NodeGroup["Node Group (Spot instances)"]
        end
    end

    PermSets --> AWS_Organizations
    AssignAdmin -.->|provisions| RoleAdmin
    AssignDev -.->|provisions| RoleDev

    RoleAdmin -->|principal_arn| EntryAdmin
    RoleDev -->|principal_arn| EntryDev

    EntryAdmin -->|grants admin to| ControlPlane
    EntryDev -->|grants edit to| ControlPlane
    ControlPlane --- NodeGroup
```

---

Identity management is decoupled from individual AWS accounts:

1. **Identity Directory**:
   - Users (`admin1`, `dev1`, `dev2`) are defined centrally. Passwords and MFA enforcement reside only here.
   - Users are grouped into functional teams (e.g., `admin`, `developer`).

2. **Permission Sets**:
   - `AdministratorAccess`: Full administrative privileges across AWS services.
   - `PowerUserAccess`: Full AWS services access excluding direct IAM/Organization user and group management.

3. **Account Assignments**:
   - Groups are assigned to the target AWS account **`aws-platform-dev`** with their respective Permission Sets.
   - AWS Identity Center automatically provisions corresponding IAM Roles inside the AWS account with the path prefix `/aws-reserved/sso.amazonaws.com/` and the naming pattern:
     ```text
     AWSReservedSSO_<PermissionSetName>_<generated-hash>
     ```
   - Identity Center creates **one IAM Role per PermissionSet per target account**, not one role per user. Every member of the `developer` group assumes the same underlying `AWSReservedSSO_PowerUserAccess_*` IAM role in the Dev account.

---

When a user executes AWS CLI or `kubectl` commands, authentication traverses three stages: federated identity, STS role assumption, and EKS access validation.

```mermaid
sequenceDiagram
    autonumber
    actor User as Developer / Admin
    participant CLI as AWS CLI (SSO Plugin)
    participant SSO as IAM Identity Center (Portal)
    participant STS as AWS STS (385470934621)
    participant K8s as kubectl
    participant EKS as EKS Control Plane (dev-eks)

    User->>CLI: aws sso login --profile <profile>
    CLI->>SSO: Initiates PKCE OAuth2 flow
    SSO-->>User: Browser prompt for credentials + MFA
    User->>SSO: Authenticates
    SSO-->>CLI: Issues SSO bearer token
    
    User->>K8s: kubectl get pods
    K8s->>CLI: Calls exec credential plugin (aws eks get-token)
    CLI->>STS: AssumeRoleWithSAML (assumes AWSReservedSSO_*)
    STS-->>CLI: Returns temporary STS session credentials
    CLI-->>K8s: Returns signed token (STS presigned URL)
    K8s->>EKS: API request with Bearer Token
    EKS->>EKS: Extracts assumed-role base ARN
    EKS->>EKS: Matches ARN against aws_eks_access_entry
    EKS-->>K8s: HTTP 200 (Authorized via Access Policy Association)
```

Although users of the same permission set share the underlying IAM Role ARN, their specific username appears in the STS session name:
```text
arn:aws:sts::<DEV_ACCOUNT_ID>:assumed-role/AWSReservedSSO_PowerUserAccess_<hash>/<username>
```
AWS CloudTrail and EKS audit logs record `<username>` on every API call, preserving individual auditability.


