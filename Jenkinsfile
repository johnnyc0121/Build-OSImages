def osConfigs = [
    win2025: [agent: 'win2025-agent'],
    win2022: [agent: 'win2022-agent'],
    win2019: [agent: 'win2019-agent']
]

pipeline {
    agent none

    parameters {
        choice(name: 'OS_NAME', choices: ['win2025', 'win2022', 'win2019'], description: 'OS Version for the custom image')
    }

    environment {
        AGENT = "jenkins-agent-cloud"
        DATESTAMP = new Date().format('yyyyMMdd_HHmmss')
        RANDOM_ID = "${UUID.randomUUID().toString().take(8)}"
        AZURE_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        AZURE_CLIENT_ID = credentials('azure-client-id')
        AZURE_CLIENT_SECRET = credentials('azure-client-secret')
        AZURE_TENANT_ID = credentials('azure-tenant-id')
        RESOURCE_GROUP = 'osimages-automation'
        LOCATION = 'westus2'
        PACKER_IMAGE = 'custom-packer:latest'
    }
    
    stages {
        stage('Checkout from GitHub') {
            agent {
                label "${AGENT}"
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
                label "${AGENT}"
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
                label "${AGENT}"
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
                        packer init packer/windows-server.pkr.hcl
                        packer validate \
                            -var="image_name=${OS_NAME}-${DATESTAMP}" \
                            -var-file="packer/config/azure.pkrvars.hcl" \
                            -var-file="packer/config/${OS_NAME}.pkrvars.hcl" \
                            packer/windows-server.pkr.hcl
                    '''

                }
            }
        }
        
        stage('Build Azure Image') {
            agent {
                label "${AGENT}"
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

                        packer init packer/windows-server.pkr.hcl
                        packer build \
                            -var="image_name=${OS_NAME}-${DATESTAMP}" \
                            -var-file="packer/config/azure.pkrvars.hcl" \
                            -var-file="packer/config/${OS_NAME}.pkrvars.hcl" \
                            packer/windows-server.pkr.hcl
                    '''
                }
            }
        }
    }
    post {
        always {
            node("${AGENT}") {
                echo 'Pipeline completed (success or failure)'
                cleanWs()

                script {
                    if (currentBuild.currentResult == 'SUCCESS') {
                        echo '✅ Pipeline completed successfully!'
                    } else {
                        echo '❌ Pipeline failed.'
                    }
                }
            }
        }
    } // post
}
