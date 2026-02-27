// ══════════════════════════════════════════════════════════════
//  Jenkinsfile — CI/CD Pipeline
//  Flow: GitHub → Jenkins → Docker Hub → Web Server (via SSH)
// ══════════════════════════════════════════════════════════════

pipeline {

    // Run on any available Jenkins agent
    agent any

    // ── Environment Variables ──────────────────────────────────
    environment {
        IMAGE_NAME      = "student-management-app"           // Docker image name
        DOCKER_HUB_USER = credentials('DOCKER_HUB_USER')    // DockerHub username (Jenkins secret)
        DOCKER_HUB_PASS = credentials('DOCKER_HUB_PASS')    // DockerHub password (Jenkins secret)
        WEB_SERVER_IP   = credentials('WEB_SERVER_IP')       // Web server IP  (Jenkins secret)
        WEB_SERVER_USER = credentials('WEB_SERVER_USER')     // Web server SSH user (Jenkins secret)
        IMAGE_TAG       = "${DOCKER_HUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}"
        IMAGE_LATEST    = "${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
    }

    // ── Triggers ───────────────────────────────────────────────
    triggers {
        // Auto-trigger when GitHub pushes (requires GitHub webhook → Jenkins)
        githubPush()
    }

    // ── Pipeline Options ───────────────────────────────────────
    options {
        timestamps()                      // Add timestamps to console output
        disableConcurrentBuilds()         // Prevent parallel builds
        buildDiscarder(logRotator(numToKeepStr: '10'))  // Keep last 10 builds
    }

    // ══════════════════════════════════════════════════════════
    //  STAGES
    // ══════════════════════════════════════════════════════════
    stages {

        // ── Stage 1: Checkout Code from GitHub ──────────────
        stage('📥 Checkout') {
            steps {
                echo '🔄 Pulling latest code from GitHub...'
                checkout scm
                sh 'echo "✅ Code checked out successfully"'
                sh 'ls -la'
            }
        }

        // ── Stage 2: Validate Files ──────────────────────────
        stage('🔍 Validate') {
            steps {
                echo '🔍 Validating required files...'
                sh '''
                    echo "Checking Dockerfile..."
                    test -f Dockerfile && echo "✅ Dockerfile found" || (echo "❌ Dockerfile missing!" && exit 1)

                    echo "Checking first.html..."
                    test -f first.html && echo "✅ first.html found" || (echo "❌ first.html missing!" && exit 1)

                    echo "All required files present!"
                '''
            }
        }

        // ── Stage 3: Build Docker Image ──────────────────────
        stage('🐳 Build Docker Image') {
            steps {
                echo '🔨 Building Docker image...'
                sh """
                    docker build -t ${IMAGE_TAG} -t ${IMAGE_LATEST} .
                    echo "✅ Docker image built: ${IMAGE_TAG}"
                    docker images | grep ${IMAGE_NAME}
                """
            }
        }

        // ── Stage 4: Push to Docker Hub ──────────────────────
        stage('📤 Push to Docker Hub') {
            steps {
                echo '📤 Pushing image to Docker Hub...'
                sh """
                    echo "${DOCKER_HUB_PASS}" | docker login -u "${DOCKER_HUB_USER}" --password-stdin
                    docker push ${IMAGE_TAG}
                    docker push ${IMAGE_LATEST}
                    docker logout
                    echo "✅ Image pushed to Docker Hub successfully!"
                """
            }
        }

        // ── Stage 5: Deploy to Web Server ────────────────────
        stage('🚀 Deploy to Web Server') {
            steps {
                echo '🚀 Deploying to production web server...'
                sshagent(credentials: ['WEB_SERVER_SSH_KEY']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${WEB_SERVER_USER}@${WEB_SERVER_IP} '
                            echo "🔄 Pulling latest Docker image..."
                            docker pull ${IMAGE_LATEST}

                            echo "🛑 Stopping existing container (if any)..."
                            docker stop student-app 2>/dev/null || true
                            docker rm   student-app 2>/dev/null || true

                            echo "▶️ Starting new container..."
                            docker run -d \\
                                --name student-app \\
                                --restart always \\
                                -p 80:80 \\
                                ${IMAGE_LATEST}

                            echo "✅ Deployment complete!"
                            docker ps | grep student-app
                        '
                    """
                }
            }
        }

    }
    // ── END STAGES ─────────────────────────────────────────────


    // ══════════════════════════════════════════════════════════
    //  POST — Notifications after pipeline finishes
    // ══════════════════════════════════════════════════════════
    post {

        success {
            echo """
            ╔══════════════════════════════════════════╗
            ║  ✅ PIPELINE SUCCEEDED — Build #${BUILD_NUMBER}  ║
            ║  🌐 App is LIVE on http://${WEB_SERVER_IP}  ║
            ╚══════════════════════════════════════════╝
            """
        }

        failure {
            echo """
            ╔══════════════════════════════════════════╗
            ║  ❌ PIPELINE FAILED — Build #${BUILD_NUMBER}     ║
            ║  Check console output for details        ║
            ╚══════════════════════════════════════════╝
            """
        }

        always {
            echo '🧹 Cleaning up local Docker images to free disk space...'
            sh "docker rmi ${IMAGE_TAG} 2>/dev/null || true"
            sh "docker image prune -f 2>/dev/null || true"
            cleanWs()   // Clean Jenkins workspace
        }

    }
}
