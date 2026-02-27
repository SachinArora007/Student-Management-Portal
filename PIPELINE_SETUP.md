# 🚀 CI/CD Pipeline Setup Guide

## Pipeline Architecture

```
Developer (Push Code)
        │
        ▼
  📁 GitHub Repo
        │  (Webhook triggers automatically)
        ▼
  🔧 Jenkins Server
        │
        ├─► 📥 Stage 1: Checkout Code
        ├─► 🔍 Stage 2: Validate Files
        ├─► 🐳 Stage 3: Build Docker Image
        ├─► 📤 Stage 4: Push to Docker Hub
        └─► 🚀 Stage 5: Deploy to Web Server
                          │
                          ▼
                  🌐 Web Server (Live App)
                  http://YOUR_SERVER_IP
```

---

## ✅ Prerequisites

| Tool | Where | Purpose |
|---|---|---|
| Git | Local machine | Push code to GitHub |
| Docker | Jenkins server + Web server | Build & run containers |
| Jenkins | Jenkins server | Run the pipeline |
| Docker Hub account | hub.docker.com | Store Docker images |
| Web Server | Any Linux VM/VPS | Host the running app |

---

## 📋 Step-by-Step Setup

### Step 1 — Push Code to GitHub

```bash
# In your project folder
git init
git add .
git commit -m "Initial commit: Student Management App"
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

---

### Step 2 — Install Jenkins Required Plugins

Go to **Jenkins → Manage Jenkins → Plugins** and install:

- ✅ `Git Plugin`
- ✅ `GitHub Integration Plugin` ← for webhooks
- ✅ `Docker Plugin`
- ✅ `SSH Agent Plugin`
- ✅ `Pipeline Plugin`

---

### Step 3 — Add Jenkins Credentials

Go to **Jenkins → Manage Jenkins → Credentials → Global → Add Credential**

Add the following secrets (use **Secret Text** or **Username & Password** kind):

| Credential ID | Type | Value |
|---|---|---|
| `DOCKER_HUB_USER` | Secret Text | Your Docker Hub username |
| `DOCKER_HUB_PASS` | Secret Text | Your Docker Hub password |
| `WEB_SERVER_IP` | Secret Text | Your web server's IP address |
| `WEB_SERVER_USER` | Secret Text | SSH username (e.g., `ubuntu`) |
| `WEB_SERVER_SSH_KEY` | SSH Username with Private Key | Your private SSH key |

---

### Step 4 — Create Jenkins Pipeline Job

1. Go to **Jenkins → New Item**
2. Name it: `student-management-pipeline`
3. Type: **Pipeline**
4. Click **OK**

In the job config:
- **Build Triggers** → ✅ Check `GitHub hook trigger for GITScm polling`
- **Pipeline → Definition** → `Pipeline script from SCM`
- **SCM** → `Git`
- **Repository URL** → `https://github.com/YOUR_USERNAME/YOUR_REPO.git`
- **Branch** → `*/main`
- **Script Path** → `Jenkinsfile`

Click **Save**

---

### Step 5 — Set Up GitHub Webhook

1. Go to your **GitHub repo → Settings → Webhooks → Add webhook**
2. Fill in:
   - **Payload URL**: `http://YOUR_JENKINS_IP:8080/github-webhook/`
   - **Content type**: `application/json`
   - **Events**: ✅ `Just the push event`
3. Click **Add webhook**

---

### Step 6 — Prepare Your Web Server

SSH into your web server and run:

```bash
# Install Docker
sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Allow your SSH user to run Docker without sudo
sudo usermod -aG docker $USER
newgrp docker

# Verify
docker --version
```

---

### Step 7 — Test the Pipeline

```bash
# On your local machine — make a small change and push
git add .
git commit -m "test: trigger pipeline"
git push origin main
```

Watch Jenkins automatically:
1. Detect the push (via webhook)
2. Pull the code
3. Build the Docker image
4. Push it to Docker Hub
5. SSH into your web server and deploy it 🚀

---

## 🌐 Access Your App

After a successful pipeline run:

```
http://YOUR_WEB_SERVER_IP
```

Your Student Management System will be live! 🎓

---

## 📁 Final Project Structure

```
First_repo/
├── first.html          ← Web application
├── Dockerfile          ← Docker image definition
├── Jenkinsfile         ← CI/CD pipeline definition
├── .dockerignore       ← Docker build exclusions
├── PIPELINE_SETUP.md   ← This guide
└── README.md
```
