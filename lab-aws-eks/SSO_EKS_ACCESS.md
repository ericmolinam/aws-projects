This guide documents how to configure the AWS CLI and `kubectl` to switch seamlessly between different AWS IAM Identity Center (SSO) users (e.g., `admin1` and `dev1`) on the same local machine.

## 1. Configure Named SSO Profiles in `~/.aws/config`

Add or edit the profiles in `~/.aws/config`:

```ini
[sso-session my-sso]
sso_start_url = https://<your-alias>.awsapps.com/start
sso_region = eu-west-1
sso_registration_scopes = sso:account:access

# Admin Profile
[profile admin1]
sso_session = my-sso
sso_account_id = <DEV_ACCOUNT_ID>
sso_role_name = AdministratorAccess
region = eu-west-1
output = json

# Developer Profile
[profile dev1]
sso_session = my-sso
sso_account_id = <DEV_ACCOUNT_ID>
sso_role_name = PowerUserAccess
region = eu-west-1
output = json
```

> **Note:** Replace `<your-alias>`, `<DEV_ACCOUNT_ID>`, and region values with your actual AWS setup.

## 2. Authenticate Sessions

Log into the respective profiles via SSO:

```bash
# Log in as admin1 (opens browser for admin1 credentials + MFA)
aws sso login --profile admin1

# Log in as dev1 (opens browser for dev1 credentials + MFA)
aws sso login --profile dev1
```

> **Tip:** If your browser caches the previous session, open an Incognito/Private window or log out from the AWS Access Portal before signing in as another user.


```bash
# Verify admin1 identity
aws sts get-caller-identity --profile admin1

# Verify dev1 identity
aws sts get-caller-identity --profile dev1
```

## 3. Configure `kubectl` for EKS

### Method A: Shared Dynamic Context (Driven by `AWS_PROFILE`)

Register the cluster once without baking a specific profile into the kubeconfig:

```bash
aws eks update-kubeconfig --region <region> --name dev-eks
```

Switch identities on the fly in your terminal session using `AWS_PROFILE`:

```bash
# Act as dev1
export AWS_PROFILE=dev1
kubectl get pods

# Act as admin1
export AWS_PROFILE=admin1
kubectl get nodes
```

### Method B: Dedicated Named `kubectl` Contexts

Create two explicit contexts with custom aliases:

```bash
# Register context for admin1
aws eks update-kubeconfig \
  --region <region> \
  --name dev-eks \
  --profile admin1 \
  --alias eks-admin1

# Register context for dev1
aws eks update-kubeconfig \
  --region <region> \
  --name dev-eks \
  --profile dev1 \
  --alias eks-dev1
```

Switch between Kubernetes contexts directly:

```bash
# Switch to dev1 context
kubectl config use-context eks-dev1
kubectl get pods

# Switch to admin1 context
kubectl config use-context eks-admin1
kubectl get nodes
```

## 4. Check Current Contexts

```bash
# View active kubectl context
kubectl config current-context

# List all available kubectl contexts
kubectl config get-contexts
```
