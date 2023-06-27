pipeline {
    agent any
    tools {
        maven "maven3"
        jdk   "OpenJdk11"
    }

    options {
        timestamps()
    }
    
    stages {

        // stage('print env vars') {
        //   steps {
        //     echo sh(script: 'env|sort', returnStdout: true)
        //   }
        // }
        
        stage('SET trigger cause') {
            steps {
                script {
                    env.TRIGGER_CAUSE = sh (returnStdout: true, script: """#!/bin/bash
                        if [[ ${env.GITHUB_BRANCH_SHORT_DESC} == *"Hash Changed"* ]]; then
                            echo "hash_changed"
                        else
                            echo "branch_created"
                        fi
                    """)
                }
            }
        }

        stage('Fetch Terraform code') {
            steps {
              git branch: 'master', url: 'https://github.com/thczzz/tf_aws_project.git'
            }
        }

        stage('Create ssh-keys') {
            steps {
                sh """!#/bin/bash
                    cd new_env && ssh-keygen -f tf-key -P ""
                """
            }
        }

        stage('S3download') {
            steps {
                withAWS(credentials:'ebsDeployment') {
                    s3Download(file: 'terraform/${env.GITHUB_BRANCH_NAME}_env/secrets/application.properties', 
                               bucket: 'vprofile-kops-state-343', 
                               path: '/home/ubuntu/application.properties')
                }

                withAWS(credentials:'ebsDeployment') {
                    s3Download(file: 'secrets/env.auto.tfvars', 
                               bucket: 'vprofile-kops-state-343', 
                               path: 'new_env/env.auto.tfvars')
                }
            }
        }

        stage('init new ENV') {
            steps {
                withAWS(credentials:'ebsDeployment') {
                    sh """!#/bin/bash
                        export TF_VAR_GITHUB_BRANCH_NAME=${env.GITHUB_BRANCH_NAME}
                        cd new_env && echo "yes" | terraform init -backend-config="key=terraform/${env.GITHUB_BRANCH_NAME}_env/terraform.tfstate"
                    """
                }
            }
        }

        stage('Apply ENV') {
            steps {
                withAWS(credentials:'ebsDeployment') {
                    sh """!#/bin/bash
                        cd new_env && terraform validate && terraform apply -var="exclude_beanstalk_env=true" --auto-approve
                    """
                }
            }
        }

        stage('Fetch code') {
            steps {
              git branch: 'vp-rem', url: 'https://github.com/thczzz/vprofile-project.git'
            }
        }

        stage('Update application.properties') {
          steps {
            sh '''
              rm -rf src/main/resources/application.properties
              cp /home/ubuntu/application.properties src/main/resources/
            '''
          }
        }

        stage('Build') {
            steps {
                sh 'mvn install -DskipTests'
            }

            post {
                success {
                    echo 'Now Archiving it...'
                    archiveArtifacts artifacts: '**/target/*.war'
                }
            }
        }

        stage('UNIT TESTS') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Checkstyle Analysis') {
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
        }

        // stage('Rename vprofile-v2.war') {
        //   steps {
        //     sh 'mv target/vprofile-v2.war target/ROOT.war'
        //   }
        // }

        // stage('Deploy to BeanStalk') {
        //   steps {
        //     step(
        //       [
        //         $class: 'AWSEBDeploymentBuilder', 
        //         zeroDowntime: false,
        //         awsRegion: 'us-east-1', 
        //         applicationName: 'vprofile-prod2', 
        //         environmentName: 'vprofile-bean-prod', 
        //         bucketName: 'elasticbeanstalk-us-east-1-930052591067', 
        //         rootObject: "target",
        //         includes: "ROOT.war",
        //         credentialId: "ebsDeployment",
        //         versionLabelFormat: 'test', 
        //         versionDescriptionFormat: 'test'
        //       ]
        //     )
        //   } 
        // }


    }
    // post {
    //     always {
    //         echo 'Slack Notifications.'
    //         slackSend channel: '#jenkinscicd',
    //                   color: COLOR_MAP[currentBuild.currentResult],
    //                   message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"
    //     }
    // }

    post {
        always {
            withAWS(credentials:'ebsDeployment') {
                sh """!#/bin/bash
                    cd ${env.WORKDIR}/tf_aws_project/new_env && terraform destroy -var="exclude_beanstalk_env=true" --auto-approve
                """

                sh """!#/bin/bash
                    rm -rf ${env.WORKDIR}/*
                """
            }
        }
    }

}
