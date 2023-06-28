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

        stage('mkdir') {
            steps {
                sh "mkdir -p ${env.JOB_NAME}_${env.BUILD_ID}/vprofile-project/"
            }
        }
        
        // stage('SET trigger cause') {
        //     steps {
        //         script {
        //             env.TRIGGER_CAUSE = sh (returnStdout: true, script: """#!/bin/bash
        //                 echo ${env.GITHUB_BRANCH_SHORT_DESC}
        //                 if [[ "${env.GITHUB_BRANCH_SHORT_DESC}" == *"Hash Changed"* ]]; then
        //                     echo "hash_changed"
        //                 else
        //                     echo "branch_created"
        //                 fi
        //             """)
        //         }
        //     }
        // }

        stage('Fetch Terraform code') {
            steps {
                dir("${env.JOB_NAME}_${env.BUILD_ID}") {
                    git branch: 'master', url: 'https://github.com/thczzz/tf_aws_project.git'
                }
            }
        }

        stage('Create ssh-keys') {
            steps {
                dir("${env.JOB_NAME}_${env.BUILD_ID}") {
                    sh 'cd new_env && ssh-keygen -f tf-key -P ""'
                }
            }
        }

        stage('S3download') {
            steps {
                dir("${env.JOB_NAME}_${env.BUILD_ID}") {
                    withAWS(region: "us-east-1", credentials:'ebsDeployment') {
                        s3Download(file: 'new_env/env.auto.tfvars', 
                                   bucket: 'vprofile-kops-state-343', 
                                   path: 'secrets/env.auto.tfvars')
                    }
                }
            }
        }

        stage('init new ENV') {
            steps {
                dir("${env.JOB_NAME}_${env.BUILD_ID}") {
                    withAWS(region: "us-east-1", credentials:'ebsDeployment') {
                        sh "cd new_env && echo 'yes' | terraform init -backend-config='key=terraform/${env.GITHUB_BRANCH_NAME}_env/terraform.tfstate'"
                    }
                }
            }
        }

        stage('Apply ENV') {
            steps {
                dir("${env.JOB_NAME}_${env.BUILD_ID}") {
                    withAWS(region: "us-east-1", credentials:'ebsDeployment') {
                        sh "cd new_env && terraform validate && terraform apply -var='GITHUB_BRANCH_NAME=${env.GITHUB_BRANCH_NAME}' -var='exclude_beanstalk_env=false' --auto-approve"
                    }
                }
            }
        }

        stage('S3download 2') {
            steps {
                withAWS(region: "us-east-1", credentials:'ebsDeployment') {
                    s3Download(file: '/home/ubuntu/application.properties', 
                               bucket: 'vprofile-kops-state-343', 
                               path: "terraform/${env.GITHUB_BRANCH_NAME}_env/secrets/application.properties")
                }
            }
        }

        stage('Fetch code') {
            steps {
                dir("${env.JOB_NAME}_${env.BUILD_ID}/vprofile-project") {
                    git branch: 'vp-rem', url: 'https://github.com/thczzz/vprofile-project.git'
                }
            }
        }

        stage('Update application.properties') {
          steps {
            dir("${env.JOB_NAME}_${env.BUILD_ID}/vprofile-project") {
                sh """
                    rm -rf src/main/resources/application.properties
                    cp /home/ubuntu/application.properties src/main/resources/
                    export BEANSTALK_ENV_NAME=$(grep -oP "(?<=beanstalk_env_name=).+" src/main/resources/application.properties
                """
            }
          }
        }

        stage('Build') {
            steps {
                dir("${env.JOB_NAME}_${env.BUILD_ID}/vprofile-project") {
                    sh 'mvn install -DskipTests'
                }
            }
        }

        stage('UNIT TESTS') {
            steps {
                dir("${env.JOB_NAME}_${env.BUILD_ID}/vprofile-project") {
                    sh 'mvn test'
                }
            }
        }

        stage('Checkstyle Analysis') {
            steps {
                dir("${env.JOB_NAME}_${env.BUILD_ID}/vprofile-project") {
                    sh 'mvn checkstyle:checkstyle'
                }
            }
        }

        stage('Rename vprofile-v2.war') {
          steps {
            dir("${env.JOB_NAME}_${env.BUILD_ID}/vprofile-project") {
                sh 'mv target/vprofile-v2.war target/ROOT.war'
            }
          }
        }

        stage('Deploy to BeanStalk') {
          steps {
            dir("${env.JOB_NAME}_${env.BUILD_ID}/vprofile-project") {
                step(
                    [
                        $class: 'AWSEBDeploymentBuilder', 
                        zeroDowntime: false,
                        awsRegion: 'us-east-1', 
                        applicationName: 'vprofile-prod2', 
                        environmentName: "${env.BEANSTALK_ENV_NAME}", 
                        bucketName: 'elasticbeanstalk-us-east-1-930052591067', 
                        rootObject: "target",
                        includes: "ROOT.war",
                        credentialId: "ebsDeployment",
                        versionLabelFormat: 'test', 
                        versionDescriptionFormat: 'test'
                    ]
                )
            }
          } 
        }
    }
    // post {
    //     always {
    //         echo 'Slack Notifications.'
    //         slackSend channel: '#jenkinscicd',
    //                   color: COLOR_MAP[currentBuild.currentResult],
    //                   message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"
    //     }
    // }

    // post {
    //     always {
    //         dir("${env.JOB_NAME}_${env.BUILD_ID}") {
    //             withAWS(region: "us-east-1", credentials:'ebsDeployment') {
    //                 sh "cd new_env && terraform destroy -var='GITHUB_BRANCH_NAME=${env.GITHUB_BRANCH_NAME}' -var='exclude_beanstalk_env=false' --auto-approve && cd .. && rm -rf *"
    //             }
    //         }
    //     }
    // }

}
