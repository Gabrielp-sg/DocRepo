COPY --from=cr.core-services.leaseplan.systems/hub.docker.com/maven:3.9.4-eclipse-temurin-11 ${MAVEN_HOME} ${MAVEN_HOME}

include:
  - project: 'templates/gitlab-ci/pipelines'
    ref: old-pipeline
    file: 'kaniko/login.yml'

workflow:
  rules:
    - when: always

stages:
  - build
  - development
  - uat
  - production

variables:
  LZ_KANIKO_EXECUTOR_IMAGE: leaseplan.jfrog.io/art-0001-docker-virtual/lz-kaniko:master
  LZ_DOCKER_REGISTRY: https://leaseplan.jfrog.io
  VAULT_AUTH_ROLE: workloads-0072-wkl-lpbr-apps
  ARTIFACTORY_ROLE_DOCKER: art-0072-write-docker-local-default
  KANIKO_EXTRA_ARGS: ""
  KANIKO_EXTRA_ARGS_BUILD: ""
  DOCKER_FILE: cadastro-positivo/cadastro-positivo-diretorio/Dockerfile
  DOCKER_REGISTRY: leaseplan.jfrog.io/prv-0072-docker-local-default
  DOCKER_IMAGE_NAME: cadastro-positivo-diretorio
  VERSION: 1.0.0
  container: docker

build:
  stage: build
  image:  $LZ_KANIKO_EXECUTOR_IMAGE
  extends:
    - .kaniko-login
  script:
    - |
      /kaniko/executor \
        --context $CI_PROJECT_DIR \
        --dockerfile $CI_PROJECT_DIR/$DOCKER_FILE \
        --no-push

development:
  stage: development
  dependencies:
    - build
  image:  $LZ_KANIKO_EXECUTOR_IMAGE
  extends:
    - .kaniko-login
  script:
    - echo "Deploying to development environment"
    - |
      /kaniko/executor \
        --context $CI_PROJECT_DIR \
        --dockerfile $CI_PROJECT_DIR/$DOCKER_FILE \
        --destination $DOCKER_REGISTRY/$DOCKER_IMAGE_NAME:DEV-$VERSION
  when: manual
  environment:
    name: development
  only:
    - develop

uat:
  stage: uat
  dependencies:
    - build
  image:  $LZ_KANIKO_EXECUTOR_IMAGE
  extends:
    - .kaniko-login
  script:
    - echo "Deploying to uat environment"
    - |
      /kaniko/executor \
        --context $CI_PROJECT_DIR \
        --dockerfile $CI_PROJECT_DIR/$DOCKER_FILE \
        --destination $DOCKER_REGISTRY/$DOCKER_IMAGE_NAME:RELEASE-$VERSION
  when: manual
  environment:
    name: uat
  only:
    - release

production:
  stage: production
  dependencies:
    - build
  image:  $LZ_KANIKO_EXECUTOR_IMAGE
  extends:
    - .kaniko-login
  script:
    - echo "Deploying to production environment"
    - |
      /kaniko/executor \
        --context $CI_PROJECT_DIR \
        --dockerfile $CI_PROJECT_DIR/$DOCKER_FILE \
        --destination $DOCKER_REGISTRY/$DOCKER_IMAGE_NAME:$VERSION
  when: manual
  environment:
    name: production
  only:
    - master




FROM leaseplan.jfrog.io/art-0072-docker-virtual/amazoncorretto:21 as builder

ARG APPLICATION_PORT
ARG CREDENTIALS_USER
ARG CREDENTIALS_PASSWORD
ARG DIRETORIO_PATH
ARG ERROR_URI
ARG EVENT_URI
ARG AWS_WEB_IDENTITY_TOKEN_FILE
ARG AWS_ROLE_ARN
ARG AWS_ROLE_SESSION_NAME
ENV APPLICATION_PORT=$APPLICATION_PORT
ENV CREDENTIALS_USER=$CREDENTIALS_USER
ENV CREDENTIALS_PASSWORD=$CREDENTIALS_PASSWORD
ENV DIRETORIO_PATH=$DIRETORIO_PATH
ENV ERROR_URI=$ERROR_URI
ENV EVENT_URI=$EVENT_URI
ENV AWS_WEB_IDENTITY_TOKEN_FILE=$AWS_WEB_IDENTITY_TOKEN_FILE
ENV AWS_ROLE_ARN=$AWS_ROLE_ARN
ENV AWS_ROLE_SESSION_NAME=$AWS_ROLE_SESSION_NAME
ENV MAVEN_HOME /usr/share/maven

COPY --from=maven:3.9.4-eclipse-temurin-11 ${MAVEN_HOME} ${MAVEN_HOME}
COPY --from=maven:3.9.4-eclipse-temurin-11 /usr/local/bin/mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh
COPY --from=maven:3.9.4-eclipse-temurin-11 /usr/share/maven/ref/settings-docker.xml /usr/share/maven/ref/settings-docker.xml

RUN ln -s ${MAVEN_HOME}/bin/mvn /usr/bin/mvn

ARG MAVEN_VERSION=3.9.4
ARG USER_HOME_DIR="/root"
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"
ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]

WORKDIR /usr/src/app
COPY ./. .

RUN yes | keytool -trustcacerts -keystore "/usr/lib/jvm/java-21-amazon-corretto/lib/security/cacerts" -storepass changeit -importcert -file "/usr/src/app/certificados/ZscalerIntermediateRootCA-zscloud.net.crt" -alias ZScaler

RUN yes | keytool -trustcacerts -keystore "/usr/lib/jvm/java-21-amazon-corretto/lib/security/cacerts" -storepass changeit -importcert -file "/usr/src/app/certificados/repo.maven.apache.org.crt" -alias RepoMaven

RUN mvn -f /usr/src/app/cadastro-positivo/pom.xml clean package

FROM leaseplan.jfrog.io/art-0072-docker-virtual/amazoncorretto:21-alpine-full
COPY --from=builder /usr/src/app/certificados/ZscalerIntermediateRootCA-zscloud.net.crt /usr/share/ca-certificates/ZscalerIntermediateRootCA-zscloud.net.crt
RUN yes | keytool -trustcacerts -keystore "/usr/lib/jvm/default-jvm/lib/security/cacerts" -storepass changeit -importcert -file "/usr/share/ca-certificates/ZscalerIntermediateRootCA-zscloud.net.crt" -alias ZScaler
COPY --from=builder /usr/src/app/cadastro-positivo/cadastro-positivo-diretorio/target/cadastro-positivo-diretorio-1.0.0.jar /usr
ENTRYPOINT ["java","-jar","/usr/cadastro-positivo-diretorio-1.0.0.jar"]
