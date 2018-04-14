//noinspection GroovyUnusedAssignment
projectId = "your-application-name"

pipeline {
    agent any

    environment {
        TF_VAR_env_custom_variable=credentials('env_custom_variable')
        AWS_ACCOUNT_ID=credentials('AWS_ACCOUNT_ID')
        AWS_ACCESS_KEY_ID=credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY=credentials('AWS_SECRET_ACCESS_KEY')
    }

    options {
        ansiColor("xterm")
    }

    stages {

        stage("Deploy to AWS ElasticBeanstalk") {

            when {
                anyOf {
                    branch 'playground'; branch 'staging'; branch 'production'
                }
            }

            steps {
                sh '''#!/bin/bash -l
                    bash infrastructure/deploy.sh your-application-name $BRANCH_NAME eu-west-1 $(git rev-parse HEAD)
                '''
            }
        }
    }

    post {
        always {
            echo 'Cleaning up....'
            sh '''#!/bin/bash -l
    
                bash infrastructure/clean.sh
    
            '''
        }
    }
}