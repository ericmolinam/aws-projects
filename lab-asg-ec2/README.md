A small project to practice deploying a scaled and load-balanced web app on AWS using Terraform. It is based on the [AWS Auto Scaling & ALB tutorial](https://docs.aws.amazon.com/autoscaling/ec2/userguide/tutorial-ec2-auto-scaling-load-balancer.html), but with HTTPS and an ACM certificate added.

### Architecture

```text
       Internet
          |
          v
+-------------------+
|  ALB (HTTP: 80)   | --> 301 Redirect to HTTPS (443)
|  ALB (HTTPS: 443) | [ACM Certificate / TLS Termination]
+---------+---------+
          |
          v
  +---------------+
  | Target Group  | (Health check: HTTP /:80)
  +-------+-------+
          |
    +-----+-----+
    |           |
    v           v
+-------+   +-------+
|  EC2  |   |  EC2  |  Auto Scaling Group (t3.micro, AL2023)
| (AZ1) |   | (AZ2) |
+-------+   +-------+
```

### How it works

- **VPC & Subnets:** A custom VPC with public subnets across multiple availability zones.
- **ALB:** Listens on port 80 and redirects to 443. Port 443 terminates TLS with an ACM cert and forwards traffic to the target group.
- **Auto Scaling Group:** Manages `t3.micro` instances running Amazon Linux 2023. Desired count is 2 (min 1, max 4).
- **Launch Template & User Data:** Boots instances with `script.sh` to start a simple web server.
- **Target Group & Health Checks:** Checks `/` on port 80 every 30 seconds to keep track of healthy instances.
- **Rolling Refresh:** Uses `instance_refresh` with a 50% minimum healthy percentage so updating the launch template doesn't take down the service.


### Test

```bash
curl -I http://<ALB_DNS_NAME>   # Should return a 301 redirect to HTTPS
curl -I https://<ALB_DNS_NAME>  # Should return 200 OK