pipeline {
  agent any

  environment {
    AWS_ACCESS_KEY_ID     = credentials('aws-access-key')
    AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
  }

  stages {
    stage('Checkout') {
      steps {
        git 'https://github.com/your-repo/aws-terraform-jenkins-pipeline.git'
      }
    }

    stage('Terraform Init') {
      steps {
        sh 'terraform init'
      }
    }

    stage('Terraform Plan') {
      steps {
        sh 'terraform plan'
      }
    }

    stage('Terraform Apply') {
      steps {
        input message: 'Approve Terraform Apply?', ok: 'Apply'
        sh 'terraform apply -auto-approve'
      }
    }

    stage('Deploy') {
      steps {
        echo 'Deploying application to AWS'
        // Add deployment scripts here
      }
    }
  }
}
