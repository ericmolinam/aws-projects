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
  <title>The Old Org - Web Service</title>
  <style>
    :root {
      --bg: #0f172a;
      --card-bg: #1e293b;
      --text-main: #f8fafc;
      --text-muted: #94a3b8;
      --accent: #38bdf8;
      --accent-glow: rgba(56, 189, 248, 0.2);
      --success: #22c55e;
      --border: #334155;
    }
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      background: radial-gradient(circle at 50% 0%, #1e293b 0%, var(--bg) 75%);
      color: var(--text-main);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 1.5rem;
    }
    .card {
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 1.25rem;
      padding: 2.25rem;
      width: 100%;
      max-width: 560px;
      box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.45), 0 0 40px var(--accent-glow);
    }
    .badge {
      display: inline-flex;
      align-items: center;
      gap: 0.5rem;
      background: rgba(34, 197, 94, 0.15);
      color: var(--success);
      border: 1px solid rgba(34, 197, 94, 0.3);
      padding: 0.35rem 0.85rem;
      border-radius: 9999px;
      font-size: 0.875rem;
      font-weight: 600;
      margin-bottom: 1.25rem;
    }
    .badge-dot {
      width: 0.5rem;
      height: 0.5rem;
      background-color: var(--success);
      border-radius: 50%;
      box-shadow: 0 0 8px var(--success);
    }
    h1 {
      font-size: 1.875rem;
      font-weight: 700;
      letter-spacing: -0.025em;
      margin-bottom: 0.5rem;
      background: linear-gradient(to right, #ffffff, #cbd5e1);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }
    p.subtitle {
      color: var(--text-muted);
      font-size: 0.975rem;
      margin-bottom: 1.75rem;
      line-height: 1.5;
    }
    .info-list {
      display: flex;
      flex-direction: column;
      gap: 0.875rem;
      background: rgba(15, 23, 42, 0.6);
      border: 1px solid var(--border);
      border-radius: 0.75rem;
      padding: 1.25rem;
    }
    .info-item {
      display: flex;
      flex-direction: column;
      gap: 0.25rem;
    }
    @media (min-width: 480px) {
      .info-item {
        flex-direction: row;
        justify-content: space-between;
        align-items: center;
      }
    }
    .info-label {
      font-size: 0.825rem;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      color: var(--text-muted);
      font-weight: 600;
    }
    .info-value {
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
      font-size: 0.925rem;
      color: var(--accent);
      word-break: break-all;
    }
    footer {
      margin-top: 2rem;
      text-align: center;
      font-size: 0.8rem;
      color: var(--text-muted);
    }
  </style>
</head>
<body>
  <div class="card">
    <div class="badge">
      <span class="badge-dot"></span>
      Online &amp; Healthy
    </div>
    <h1>The Old Org</h1>
    <p class="subtitle">High-availability web service running behind an AWS Application Load Balancer.</p>

    <div class="info-list">
      <div class="info-item">
        <span class="info-label">Host Instance</span>
        <span class="info-value">${HOSTNAME}</span>
      </div>
      <div class="info-item">
        <span class="info-label">Deployed At</span>
        <span class="info-value">${DEPLOY_DATE}</span>
      </div>
      <div class="info-item">
        <span class="info-label">Environment</span>
        <span class="info-value">AWS Auto Scaling Group</span>
      </div>
    </div>

    <footer>
      Protected with ACM TLS &bull; Managed via Terraform
    </footer>
  </div>
</body>
</html>
EOF

sudo systemctl start httpd
sudo systemctl enable httpd