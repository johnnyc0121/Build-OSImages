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
                label 'jenkins-agent'
            } // agent
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
                label 'jenkins-agent'
            } // agent
            steps {
                script {
                    echo 'Validating Packer template...'
                    sh '''
                        pwd
                        ls -la

                        # Export Azure credentials as environment variables
                        export AZURE_SUBSCRIPTION_ID="${AZURE_SUBSCRIPTION_ID}"
                        export AZURE_CLIENT_ID="${AZURE_CLIENT_ID}"
                        export AZURE_CLIENT_SECRET="${AZURE_CLIENT_SECRET}"
                        export AZURE_TENANT_ID="${AZURE_TENANT_ID}"
                        
                        # Pass only Packer template variables
                        packer init
                        packer validate \
                            -var="resource_group=${RESOURCE_GROUP}" \
                            -var="location=${LOCATION}" \
                            -var="image_name=${OS_NAME}-100000" \
                            -var-file="packer/config/${OS_NAME}.pkrvars.hcl" \
                            packer/windows-server.pkr.hcl
                    '''

                }
            }
        }
        
        stage('Build Azure Image') {
            agent {
                label 'jenkins-agent'
            } // agent
            steps {
                script {
                    echo 'Building custom Windows Server image in Azure...'
                    sh '''
                        # Export Azure credentials as environment variables
                        export AZURE_SUBSCRIPTION_ID="${AZURE_SUBSCRIPTION_ID}"
                        export AZURE_CLIENT_ID="${AZURE_CLIENT_ID}"
                        export AZURE_CLIENT_SECRET="${AZURE_CLIENT_SECRET}"
                        export AZURE_TENANT_ID="${AZURE_TENANT_ID}"

                        packer init
                        packer build \
                            -var="resource_group=${RESOURCE_GROUP}" \
                            -var="location=${LOCATION}" \
                            -var="image_name=${OS_NAME}-100000" \
                            -var-file="packer/config/${OS_NAME}.pkrvars.hcl" \
                            packer/windows-server.pkr.hcl
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
