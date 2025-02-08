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
                // Use the secret file credential.
                // The file credential with ID 'tfvars' will be bound to the TFVARS_FILE environment variable.
                withCredentials([file(credentialsId: 'tfvars', variable: 'TFVARS_FILE')]) {
                    echo 'Running Terraform plan...'
                    // Use the tfvars file when planning.
                    // TFVARS_FILE is the path to the secret file that Jenkins creates.
                    sh "terraform plan -var-file=${TFVARS_FILE} -out=tfplan"
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
