#!/bin/bash
sudo yum update -y && sudo yum install -y httpd

HOSTNAME=$(hostname)
DEPLOY_DATE=$(date -u '+%Y-%m-%d %H:%M:%S UTC')

cat <<EOF | sudo tee /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>The Old Company</title>
  <style>
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
      background-color: #f9fafb;
      color: #111827;
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      padding: 1.5rem;
    }
    .container {
      background-color: #ffffff;
      border: 1px solid #e5e7eb;
      border-radius: 8px;
      padding: 2rem;
      width: 100%;
      max-width: 480px;
    }
    .status {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      font-size: 0.875rem;
      color: #166534;
      margin-bottom: 1rem;
    }
    .status-dot {
      width: 8px;
      height: 8px;
      background-color: #22c55e;
      border-radius: 50%;
    }
    h1 {
      font-size: 1.5rem;
      font-weight: 600;
      color: #111827;
      margin-bottom: 0.5rem;
    }
    p {
      color: #6b7280;
      font-size: 0.95rem;
      line-height: 1.5;
      margin-bottom: 1.5rem;
    }
    dl {
      border-top: 1px solid #f3f4f6;
      display: grid;
      grid-template-columns: 1fr;
      gap: 0.75rem;
      padding-top: 1rem;
    }
    .row {
      display: flex;
      flex-direction: column;
      gap: 0.25rem;
    }
    @media (min-width: 400px) {
      .row {
        flex-direction: row;
        justify-content: space-between;
      }
    }
    dt {
      color: #6b7280;
      font-size: 0.875rem;
    }
    dd {
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
      font-size: 0.875rem;
      color: #1f2937;
      font-weight: 500;
      word-break: break-all;
    }
    footer {
      margin-top: 1.5rem;
      font-size: 0.8rem;
      color: #9ca3af;
      text-align: center;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>The Old Company</h1>
    <p>Web service deployed across public subnets with Auto Scaling and an Application Load Balancer.</p>

    <dl>
      <div class="row">
        <dt>Host</dt>
        <dd>${HOSTNAME}</dd>
      </div>
      <div class="row">
        <dt>Deployed</dt>
        <dd>${DEPLOY_DATE}</dd>
      </div>
      <div class="row">
        <dt>Load Balancer</dt>
        <dd>HTTP/HTTPS (port 80 / 443)</dd>
      </div>
    </dl>
  </div>
  <footer>
    old-company.org
  </footer>
</body>
</html>
EOF

sudo systemctl start httpd
sudo systemctl enable httpd