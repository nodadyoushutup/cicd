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
                    file(credentialsId: 'private_key', variable: 'SSH_PRIVATE_KEY')
                ]) {
                    echo "Setting private key permissions"
                    sh "chmod 600 ${SSH_PRIVATE_KEY}"
                    echo 'Running Terraform plan...'
                    sh "terraform plan -var-file=${TFVARS_FILE} -var 'SSH_PRIVATE_KEY=${SSH_PRIVATE_KEY}' -out=tfplan"
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
