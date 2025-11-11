pipeline {
    agent none
    
    environment {
        RANDOM_ID = "${UUID.randomUUID().toString().take(8)}"
        AZURE_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        AZURE_CLIENT_ID = credentials('azure-client-id')
        AZURE_CLIENT_SECRET = credentials('azure-client-secret')
        AZURE_TENANT_ID = credentials('azure-tenant-id')
        RESOURCE_GROUP = 'osimages-automation'
        LOCATION = 'westus2'
        PACKER_IMAGE = 'custom-packer:latest'
    }
    
    parameters {
        choice(name: 'OS_NAME', choices: ['win2025', 'win2022', 'win2019'], description: 'OS Version for the custom image')
        choice(name: 'VM_SIZE', choices: ['Standard_D2ads_v6', 'Standard_D2as_v6'], description: 'Azure VM size for build')
    }
    
    stages {
        stage('Checkout from GitHub') {
            agent {
                label 'jenkins-agent'
            } // agent
            environment {
                GIT_REPO = 'https://github.com/johnnyc0121/Build-OSImages.git'
                GIT_BRANCH = 'main'
            } // environment

            steps {
                // Clean workspace first
                deleteDir()

                // Clone the GitHub repository
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "*/${env.GIT_BRANCH}"]],
                    userRemoteConfigs: [[
                        url: "${env.GIT_REPO}",
                        credentialsId: 'github-creds'
                    ]]
                ])

                // Verify workspace contents
                sh '''
                    echo "Current workspace:"
                    pwd
                    ls -la
                '''
            } // steps
        } // stage

        stage('Verify GitHub Checkout') {
            agent {
                docker {
                    image 'jenkins-agent:20251110'
                    args "--network host -v /host/workspaces/osimages-${env.RANDOM_ID}:/var/jenkins_home/workspace/osimages-${env.RANDOM_ID}"
                    customWorkspace "/var/jenkins_home/workspace/osimages-${env.RANDOM_ID}"
                }
            }
            steps {
                echo "Checked out code from ${env.GIT_REPO} on branch ${env.GIT_BRANCH}"
                sh '''
                    pwd
                    ls -la
               ''' // List files in workspace
            }
        }

        // stage('Build Packer Docker Image') {
        //     steps {
        //         script {
        //             echo 'Building Packer Docker image...'
        //             sh '''
        //                 cd packer
        //                 docker build -t ${PACKER_IMAGE} .
        //             '''
        //         }
        //     }
        // }
        
        stage('Validate Packer Template') {
            agent {
                docker {
                    image 'jenkins-agent:20251110'
                    args "--network host -v /host/workspaces/osimages-${env.RANDOM_ID}:/var/jenkins_home/workspace/osimages-${env.RANDOM_ID}"
                    customWorkspace "/var/jenkins_home/workspace/osimages-${env.RANDOM_ID}"
                }
            }
            steps {
                script {
                    echo 'Validating Packer template...'
                    sh '''
                        pwd
                        ls -la
                        packer validate \
                            -var="AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID}" \
                            -var="AZURE_CLIENT_ID=${AZURE_CLIENT_ID}" \
                            -var="AZURE_CLIENT_SECRET=${AZURE_CLIENT_SECRET}" \
                            -var="AZURE_TENANT_ID=${AZURE_TENANT_ID}" \
                            -var="resource_group=${RESOURCE_GROUP}" \
                            -var="location=${LOCATION}" \
                            -var="image_name=${OS_NAME}-100000" \
                            -var="os_name=${OS_NAME}" \
                            -var="vm_size=${VM_SIZE}" \
                            /Build-OSImages/packer/windows-server.pkr.hcl
                    '''
                }
            }
        }
        
        stage('Build Azure Image') {
            agent {
                docker {
                    image 'jenkins-agent:20251110'
                    args "--network host -v /host/workspaces/osimages-${env.RANDOM_ID}:/var/jenkins_home/workspace/osimages-${env.RANDOM_ID}"
                    customWorkspace "/var/jenkins_home/workspace/osimages-${env.RANDOM_ID}"
                }
            }
            steps {
                script {
                    echo 'Building custom Windows Server image in Azure...'
                    sh '''
                        packer build \
                            -var="AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID}" \
                            -var="AZURE_CLIENT_ID=${AZURE_CLIENT_ID}" \
                            -var="AZURE_CLIENT_SECRET=${AZURE_CLIENT_SECRET}" \
                            -var="AZURE_TENANT_ID=${AZURE_TENANT_ID}" \
                            -var="resource_group=${RESOURCE_GROUP}" \
                            -var="location=${LOCATION}" \
                            -var="image_name=${OS_NAME}-100000" \
                            -var="os_name=${OS_NAME}" \
                            -var="vm_size=${VM_SIZE}" \
                            /Build-OSImages/packer/windows-server.pkr.hcl
                    '''
                }
            }
        }
        
        stage('Tag Image') {
            steps {
                script {
                    echo 'Tagging image in Azure...'
                    sh '''
                        # Get the latest image name
                        IMAGE_FULL_NAME=$(docker run --rm \
                            -e AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID} \
                            -e AZURE_CLIENT_ID=${AZURE_CLIENT_ID} \
                            -e AZURE_CLIENT_SECRET=${AZURE_CLIENT_SECRET} \
                            -e AZURE_TENANT_ID=${AZURE_TENANT_ID} \
                            ${PACKER_IMAGE} \
                            /bin/sh -c "az login --service-principal -u ${AZURE_CLIENT_ID} -p ${AZURE_CLIENT_SECRET} --tenant ${AZURE_TENANT_ID} && \
                            az image list --resource-group ${RESOURCE_GROUP} --query '[0].name' -o tsv")
                        
                        echo "Created image: ${IMAGE_FULL_NAME}"
                    '''
                }
            }
        }
    }
    post {
        success {
            node('jenkins-agent') {
                echo 'Pipeline completed successfully! Custom Windows Server image has been created in Azure.'
            }
        }
        failure {
            node('jenkins-agent') {
                echo 'Pipeline failed. Check logs for details.'
            }
        }
        always {
            node('jenkins-agent') {
                cleanWs()
            }
        }
    }

}
