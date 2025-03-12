pipeline {
    agent any
    
    environment {
        AWS_REGION = 'ap-southeast-1'
        TF_VERSION = '1.1.5'
        S3_BUCKET = 'my-static-content-bucket'
        TF_STATE_BUCKET = 'my-terraform-state-bucket'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Initialize Terraform') {
            steps {
                script {
                    sh 'terraform init -backend-config="bucket=${TF_STATE_BUCKET}" -backend-config="region=${AWS_REGION}"'
                }
            }
        }

        stage('Plan Terraform') {
            steps {
                script {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Apply Terraform') {
            steps {
                script {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Destroy Terraform') {
            steps {
                script {
                    sh 'terraform destroy -auto-approve'
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
