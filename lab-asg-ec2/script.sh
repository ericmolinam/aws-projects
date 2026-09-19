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
  <title>old-company.org</title>
  <style>
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      background-color: #fafafa;
      color: #171717;
      line-height: 1.6;
    }
    header {
      border-bottom: 1px solid #e5e5e5;
      background: #ffffff;
      position: sticky;
      top: 0;
    }
    .nav-inner {
      max-width: 960px;
      margin: 0 auto;
      padding: 1rem 1.5rem;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .logo {
      font-weight: 700;
      font-size: 1.125rem;
      color: #0a0a0a;
      letter-spacing: -0.02em;
    }
    nav a {
      color: #525252;
      text-decoration: none;
      font-size: 0.875rem;
      margin-left: 1.5rem;
      transition: color 0.15s ease;
    }
    nav a:hover {
      color: #0a0a0a;
    }
    main {
      max-width: 960px;
      margin: 0 auto;
      padding: 3.5rem 1.5rem;
    }
    .hero {
      padding: 2rem 0 3.5rem;
      border-bottom: 1px solid #e5e5e5;
    }
    .hero-tag {
      font-size: 0.75rem;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.08em;
      color: #737373;
      margin-bottom: 0.75rem;
    }
    .hero h1 {
      font-size: clamp(2rem, 5vw, 3rem);
      font-weight: 700;
      line-height: 1.2;
      color: #0a0a0a;
      letter-spacing: -0.03em;
      margin-bottom: 1.25rem;
      max-width: 720px;
    }
    .hero p {
      font-size: 1.125rem;
      color: #525252;
      max-width: 620px;
      margin-bottom: 2rem;
    }
    .btn-group {
      display: flex;
      flex-wrap: wrap;
      gap: 0.75rem;
    }
    .btn {
      display: inline-block;
      padding: 0.625rem 1.25rem;
      border-radius: 6px;
      font-size: 0.875rem;
      font-weight: 500;
      text-decoration: none;
    }
    .btn-primary {
      background: #171717;
      color: #ffffff;
    }
    .btn-secondary {
      background: #ffffff;
      color: #171717;
      border: 1px solid #d4d4d4;
    }
    .features {
      padding: 3.5rem 0;
      border-bottom: 1px solid #e5e5e5;
    }
    .section-title {
      font-size: 0.75rem;
      text-transform: uppercase;
      letter-spacing: 0.08em;
      color: #737373;
      font-weight: 600;
      margin-bottom: 2rem;
    }
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
      gap: 1.5rem;
    }
    .card {
      background: #ffffff;
      border: 1px solid #e5e5e5;
      border-radius: 8px;
      padding: 1.5rem;
    }
    .card h3 {
      font-size: 1.125rem;
      font-weight: 600;
      color: #0a0a0a;
      margin-bottom: 0.5rem;
    }
    .card p {
      font-size: 0.9rem;
      color: #525252;
    }
    .sys-bar {
      margin-top: 3.5rem;
      background: #ffffff;
      border: 1px solid #e5e5e5;
      border-radius: 8px;
      padding: 1rem 1.25rem;
      display: flex;
      flex-wrap: wrap;
      justify-content: space-between;
      align-items: center;
      gap: 0.75rem;
      font-size: 0.8125rem;
      color: #737373;
    }
    .sys-pill {
      display: inline-flex;
      align-items: center;
      gap: 0.4rem;
      color: #15803d;
      font-weight: 500;
    }
    .sys-dot {
      width: 6px;
      height: 6px;
      background: #22c55e;
      border-radius: 50%;
    }
    .sys-info {
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
      color: #404040;
    }
    footer {
      border-top: 1px solid #e5e5e5;
      background: #ffffff;
      padding: 2rem 1.5rem;
      text-align: center;
      font-size: 0.8125rem;
      color: #737373;
    }
  </style>
</head>
<body>
  <header>
    <div class="nav-inner">
      <div class="logo">old-company.org</div>
      <nav>
        <a href="#section1">Dolor</a>
        <a href="#section2">Sit</a>
        <a href="#section3">Amet</a>
      </nav>
    </div>
  </header>

  <main>
    <section class="hero">
      <h1>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</h1>
      <p>Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p>
      <div class="btn-group">
        <a href="#section1" class="btn btn-primary">Lorem Ipsum</a>
        <a href="#section2" class="btn btn-secondary">Dolor Sit</a>
      </div>
    </section>

    <section id="services" class="features">
      <div class="section-title">Consectetur Adipiscing</div>
      <div class="grid">
        <div class="card">
          <h3>Lorem Ipsum</h3>
          <p>Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur excepteur sint occaecat.</p>
        </div>
        <div class="card">
          <h3>Dolor Sit</h3>
          <p>Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum et accusamus.</p>
        </div>
        <div class="card">
          <h3>Amet Consectetur</h3>
          <p>At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti.</p>
        </div>
      </div>
    </section>

    <div class="sys-bar">
      <span class="sys-pill">
        <span class="sys-dot"></span> Operational
      </span>
      <span class="sys-info">Host: ${HOSTNAME}</span>
      <span class="sys-info">Date: ${DEPLOY_DATE}</span>
    </div>
  </main>

  <footer id="contact">
    <p>&copy; 2026 &bull; old-company.org</p>
  </footer>
</body>
</html>
EOF

sudo systemctl start httpd
sudo systemctl enable httpd
