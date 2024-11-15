pipeline {
    agent any

    tools {
        terraform 'terraform' // Ensure Terraform is correctly configured in Jenkins
    }

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'stage', 'prod'], description: 'Select the environment')
        booleanParam(name: 'DESTROY', defaultValue: false, description: 'Check to destroy resources')
    }

    environment {
        TF_ENV = "${params.ENVIRONMENT}" // Use environment variable for workspace
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/ymkgithub/AWS-MP.git' // Your Git repository
            }
        }

        stage('Fetch Workspace Variables') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-cred', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    script {
                        def secretId = "${TF_ENV}/drupal/secrets"
                        sh """
                            aws secretsmanager get-secret-value --secret-id ${secretId} --query SecretString --output text > terraform-${TF_ENV}.json
                        """
                    }
                }
            }
        }

        stage('Terraform Init') {
            // when {
            //     expression {
            //         return !params.DESTROY
            //     }
            // }
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-cred', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    script {
                        sh """
                            terraform init
                        """
                    }
                }
            }
        }

        stage('workspace selection') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-cred', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    script {
                        sh """
                            terraform workspace select ${TF_ENV} || terraform workspace new ${TF_ENV}
                            terraform validate
                        """
                    }
                }
            }
        }

        stage('Terraform Plan') {
            when {
                expression {
                    return !params.DESTROY
                }
            }
            steps {
                script {
                    sh """
                        terraform plan -var-file=terraform-${TF_ENV}.json -out=tfplan
                    """
                }
            }
        }

        stage('Plan Confirmation') {
            when {
                expression {
                    return !params.DESTROY
                }
            }
            steps {
                script {
                    def userInput = input(
                        id: 'userInput', 
                        message: "Are you sure you want to execute this plan in the '${TF_ENV}' environment workspace?",
                        parameters: [[$class: 'BooleanParameterDefinition', name: 'Confirm', defaultValue: false]]
                    )

                    if (!userInput) {
                        error("User aborted the pipeline.")
                    }
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression {
                    return !params.DESTROY
                }
            }
            steps {
                script {
                    sh """
                        terraform apply -auto-approve tfplan
                    """
                }
            }
        }

        // Plan for destroy
        stage('Terraform Plan (Destroy)') {
            when {
                expression {
                    return params.DESTROY
                }
            }
            steps {
                script {
                    sh """
                        terraform plan -var-file=terraform-${TF_ENV}.json -destroy -out=tf-destroy-plan
                    """
                }
            }
        }

        stage('Destroy Confirmation') {
            when {
                expression {
                    return params.DESTROY
                }
            }
            steps {
                script {
                    input message: "Are you sure you want to destroy resources in the '${TF_ENV}' workspace?",
                          ok: "Yes, Destroy"
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression {
                    return params.DESTROY
                }
            }
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-cred', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    script {
                        sh """
                            terraform apply -auto-approve tf-destroy-plan
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            // Clean up the terraform-{TF_ENV}.json file
            sh """
                rm -rf terraform-${TF_ENV}.json
            """
        }
    }
}



// pipeline {
//     agent any

//     tools {
//         terraform 'terraform' // Ensure Terraform is correctly configured in Jenkins
//     }

//     parameters {
//         choice(name: 'ENVIRONMENT', choices: ['dev', 'stage', 'prod'], description: 'Select the environment')
//         booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply/destroy without manual approval?')
//         choice(name: 'action', choices: ['apply', 'destroy'], description: 'Select the action to perform')
//     }

//     stages {
//         stage('Checkout') {
//             steps {
//                 git credentialsId: 'gogs-cred', url: 'https://gogs.bicsglobal.com/BICS_IT/K8S-Drupal-IAC.git' // Your Git repository
//             }
//         }

//         stage('Terraform Init & Plan') {
//             steps {
//                 withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-cred', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
//                     script {
//                         def env = params.ENVIRONMENT
//                         // Select or create a workspace for the specified environment
//                         sh """
//                             terraform init
//                             terraform workspace select ${env} || terraform workspace new ${env}
//                             terraform fmt
//                             terraform validate
//                         """
//                     }
//                 }
//             }
//         }

//         stage('Plan') {
//             steps {
//                 withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-cred', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
//                     // Generate the plan and save it as `tfplan`
//                     sh 'terraform plan -out=tfplan'
//                     // Export the plan to a text file for review
//                     sh 'terraform show -no-color tfplan > tfplan.txt'
//                 }
//             }
//         }

//         stage('Review and Confirm') {
//             steps {
//                 script {
//                     def plan = readFile 'tfplan.txt'
//                     def userInput = input message: "Do you want to apply this plan?", 
//                                           parameters: [choice(name: 'confirmation', choices: ['Yes', 'No'], description: 'Please confirm if you want to proceed with the plan')]

//                     if (userInput == 'No') {
//                         error "User chose not to proceed with the deployment."
//                     }
//                 }
//             }
//         }

//         stage('Apply / Destroy') {
//             when {
//                 expression { params.action == 'apply' || params.action == 'destroy' }
//             }
//             steps {
//                 withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-cred', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
//                     script {
//                         // Apply action
//                         if (params.action == 'apply') {
//                             // Execute the Terraform apply command
//                             sh 'terraform apply -input=false tfplan'
//                         } else if (params.action == 'destroy') {
//                             if (!params.autoApprove) {
//                                 input message: "Are you sure you want to destroy the infrastructure?"
//                             }
//                             // Execute the Terraform destroy command
//                             sh 'terraform destroy --auto-approve'
//                         } else {
//                             // Error handling for invalid action
//                             error "Invalid action selected. Please choose either 'apply' or 'destroy'."
//                         }
//                     }
//                 }
//             }
//         }
//     }
// }
