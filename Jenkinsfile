pipeline {
    agent any
    
    environment {
        AZURE_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        AZURE_CLIENT_ID = credentials('azure-client-id')
        AZURE_CLIENT_SECRET = credentials('azure-client-secret')
        AZURE_TENANT_ID = credentials('azure-tenant-id')
        PACKER_IMAGE = 'custom-packer:latest'
        RESOURCE_GROUP = 'osimages-automation'
        LOCATION = 'westus2'
        RANDOM_ID = "${UUID.randomUUID().toString().take(8)}"
    }
    
    parameters {
        choice(name: 'OS_NAME', choices: ['win2025', 'win2022', 'win2019'], description: 'OS Version for the custom image')
        choice(name: 'VM_SIZE', choices: ['Standard_D2ads_v6', 'Standard_D2as_v6'], description: 'Azure VM size for build')
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Debug - List Files') {
            steps {
                sh '''
                    echo "=== Workspace contents ==="
                    ls -la ${WORKSPACE}
                    
                    echo "=== Packer directory contents ==="
                    ls -la ${WORKSPACE}/packer || echo "packer directory not found"
                    
                    echo "=== Looking for HCL files ==="
                    find ${WORKSPACE} -name "*.hcl" || echo "no HCL files found"
                '''
            }
        }

        stage('Build Packer Docker Image') {
            steps {
                script {
                    echo 'Building Packer Docker image...'
                    sh '''
                        cd packer
                        docker build -t ${PACKER_IMAGE} .
                    '''
                }
            }
        }
        
        stage('Validate Packer Template') {
            agent {
                docker {
                    image 'custom-packer:latest'
                    args '-v ${WORKSPACE}/packer:/workspace'
                    customWorkspace '/home/jenkins/workspace-${RANDOM_ID}'
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
                            /workspace/windows-server.pkr.hcl
                    '''
                }
            }
        }
        
        stage('Build Azure Image') {
            steps {
                script {
                    echo 'Building custom Windows Server image in Azure...'
                    sh '''
                        docker run --rm \
                            -v ${WORKSPACE}/packer:/workspace \
                            -e AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID} \
                            -e AZURE_CLIENT_ID=${AZURE_CLIENT_ID} \
                            -e AZURE_CLIENT_SECRET=${AZURE_CLIENT_SECRET} \
                            -e AZURE_TENANT_ID=${AZURE_TENANT_ID} \
                            -e PACKER_LOG=1 \
                            ${PACKER_IMAGE} \
                            build \
                            -force \
                            -var="resource_group=${RESOURCE_GROUP}" \
                            -var="location=${LOCATION}" \
                            -var="image_name=${OS_NAME}-100000" \
                            -var="os_name=${OS_NAME}" \
                            -var="vm_size=${VM_SIZE}" \
                            /workspace/windows-server.pkr.hcl
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
            echo 'Pipeline completed successfully! Custom Windows Server image has been created in Azure.'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
        always {
            cleanWs()
        }
    }
}
