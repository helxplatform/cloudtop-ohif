pipeline {
    agent { label 'agent-docker' }
    environment {
        DOCKERHUB_CREDS = credentials("${env.REGISTRY_CREDS_ID_STR}")
        DOCKER_REGISTRY = "${env.DOCKER_REGISTRY}"
        REG_OWNER="helxplatform"
        REG_APP="cloudtop-ohif"
        COMMIT_HASH="${sh(script:"git rev-parse --short HEAD", returnStdout: true).trim()}"
        IMAGE_NAME="${DOCKER_REGISTRY}/${REG_OWNER}/${REG_APP}"
        TAG1="$BRANCH_NAME"
        TAG2="$COMMIT_HASH"
    }
    stages {
        stage('Build') {
            steps {
                sh '''
                echo "Build Stage"
                docker build -t $IMAGE_NAME:$TAG1 -t $IMAGE_NAME:$TAG2 --build-arg CLOUDTOP_TAG=$BRANCH_NAME .
               '''
            }
        }
        stage('Test') {
            steps {
                sh '''
                echo "Test Stage"
                '''
            }
        }
        stage('Publish') {
            steps {
                sh '''
                echo "Publish Stage"
                echo $DOCKERHUB_CREDS_PSW | docker login -u $DOCKERHUB_CREDS_USR --password-stdin $DOCKER_REGISTRY
                docker push $IMAGE_NAME:$TAG1
                docker push $IMAGE_NAME:$TAG2
                '''
            }
        }
    }
}
//  stages {
//      stage('Build') {
//          environment {
//              DOCKERHUB_CREDS = credentials("${env.REGISTRY_CREDS_ID_STR}")
//              DOCKER_REGISTRY = "${env.DOCKER_REGISTRY}"
//          }
//          steps {
//              container('agent-docker') {
//                  sh '''
//                  echo build
//                  docker build -t helxplatform/cloudtop-ohif:$BRANCH_NAME --build-arg CLOUDTOP_TAG=$BRANCH_NAME .
//                  '''
//              }
//          }
//      }
//      stage('Test') {
//          steps {
//              container('agent-docker') {
//                  sh '''
//                  echo test
//                  '''
//              }
//          }
//      }
//      stage('Publish') {
//          environment {
//              DOCKERHUB_CREDS = credentials("${env.REGISTRY_CREDS_ID_STR}")
//              DOCKER_REGISTRY = "${env.DOCKER_REGISTRY}"
//          }
//          steps {
//              container('agent-docker') {
//                  sh '''
//                  echo publish
//                  echo $DOCKERHUB_CREDS_PSW | docker login -u $DOCKERHUB_CREDS_USR --password-stdin $DOCKER_REGISTRY
//                  docker push helxplatform/cloudtop-ohif:$BRANCH_NAME
//                  '''
//              }
//          }
//      }
//  }
//}
