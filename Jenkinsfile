pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Terraform Init') {
            steps {
                echo 'Initializing Terraform...'
                sh 'terraform init'
            }
        }
        stage('Terraform Plan') {
            steps {
                withCredentials([
                    file(credentialsId: 'tfvars', variable: 'TFVARS_FILE'),
                    file(credentialsId: 'ssh_private_key', variable: 'SSH_PRIVATE_KEY')
                ]) {
                    echo "Setting private key permissions"
                    // Set proper permissions on the injected key
                    sh "chmod 600 ${SSH_PRIVATE_KEY}"
                    
                    echo "Copying private key to workspace"
                    // Copy the key into the workspace so that Terraform's file() can read it.
                    sh "cp ${SSH_PRIVATE_KEY} ./id_rsa"
                    
                    echo 'Running Terraform plan...'
                    // Pass the tfvars file and the new private key path to Terraform
                    sh "terraform plan -var-file=${TFVARS_FILE} -var 'SSH_PRIVATE_KEY=./id_rsa' -out=tfplan"
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                echo 'Applying Terraform changes...'
                sh 'terraform apply tfplan'
            }
        }
    }
}
