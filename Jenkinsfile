pipeline {
    agent any // Global agent: run on Jenkins master pod (for lightweight stages like triggering Ansible)
    // as no agent is configured, by default run in the jenkins master pod
    
    environment {
        DOCKER_REGISTRY = "docker.io/sayantan2k21"
        APP_NAME = "host-info-app"
        IMAGE_NAME = "${DOCKER_REGISTRY}/${APP_NAME}"
        GITHUB_SOURCE_CODE_REPO = "https://github.com/Sayantan2k24/LW-Project-08-Full-DevOps-Workflow-CodePush-JenkinsBuild-Ansible-Deploy-DockerContainer-K8s-Service.git"
        BRANCH = "main"
    }

    stages {
        stage('Docker Build & Push') {
            agent {
                kubernetes {
                    yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: image-builder-agent
spec:
  containers:
  - name: image-builder-agent
    image: docker.io/sayantan2k21/image-builder-k8s-agent:rhel9
    securityContext:
      privileged: true
    command:
    - cat
    tty: true
    volumeMounts:
    - name: docker-graph-storage
      mountPath: /var/lib/docker
  volumes:
  - name: docker-graph-storage
    emptyDir: {}
"""
                }
            }

            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', passwordVariable: 'pass', usernameVariable: 'user')]) {
                    container('image-builder-agent') {
                        script {
                            sh """
                            /usr/local/bin/dockerd-entrypoint.sh &

                            sleep 10

                            # Check Out SCM
                            git clone -b ${BRANCH} ${GITHUB_SOURCE_CODE_REPO} workspace

                            cd workspace/APP/

                            # Login to Dockerhub
                            echo ${pass} | docker login -u ${user} --password-stdin

                            # Push to DockerHub
                            docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                            docker push ${IMAGE_NAME}:${BUILD_NUMBER}
                            """
                        }
                    }
                }
            }
        }


        stage('Trigger Ansible Deployment') {
            steps {
                script {
                    sh """
                        kubectl exec -n devops deployment/ansible -c ansible -- bash -c 'cat <<EOF > /tmp/deploy-script.sh
ansible-playbook /home/ansible/playbooks/deploy-app.yml --extra-vars "image_name=${IMAGE_NAME} image_tag=${BUILD_NUMBER} app_name=${APP_NAME}"
EOF'
                        kubectl exec -n devops deployment/ansible -c ansible -- bash /tmp/deploy-script.sh
                    """
                }
            }
        }

        // stage('Scale Application') {
        //     when {
        //         branch 'production'
        //     }
        //     steps {
        //         container('ansible') {
        //             sh '''
        //             ansible-playbook /etc/ansible/playbooks/scale-deployment.yml \
        //               --extra-vars replicas=5 app_name=${APP_NAME}
        //             '''
        //         }
        //     }
        // }
    }

    post {
        success {
            echo '✅ Deployment successful!'
        }
        failure {
            echo '❌ Deployment failed!'
        }
    }
}
