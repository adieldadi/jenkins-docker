FROM jenkins/jenkins:latest
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc.yaml
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
COPY casc.yaml /var/jenkins_home/casc.yaml
COPY seed-job.groovy /var/jenkins_home/seed-job.groovy
COPY --chown=jenkins bootstrap.groovy /var/jenkins_home/workspace/bootstrap/
COPY --chown=jenkins --chmod=600 id_rsa /var/jenkins_home/.ssh/
COPY --chown=jenkins --chmod=600 id_rsa.pub /var/jenkins_home/.ssh/
COPY --chown=jenkins --chmod=600 aws-credentials /var/jenkins_home/.aws/credentials
COPY --chown=jenkins --chmod=600 aws-config /var/jenkins_home/.aws/config
RUN ssh-keyscan github.com >> /var/jenkins_home/.ssh/known_hosts
USER root
RUN  apt-get update \
     && apt-get install wget unzip awscli software-properties-common  -y
RUN wget --quiet https://releases.hashicorp.com/terraform/0.11.3/terraform_0.11.3_linux_amd64.zip \
  && unzip terraform_0.11.3_linux_amd64.zip \
  && mv terraform /usr/bin \
  && rm terraform_0.11.3_linux_amd64.zip
COPY JENKINS_ADMIN_PASSWORD /run/secrets/
COPY JENKINS_ADMIN_ID /run/secrets/
COPY PRIVATE_SSH_CERT /run/secrets/
COPY PUBLIC_SSH_CERT /run/secrets/
USER jenkins
RUN chmod -R +w /var/jenkins_home/workspace/
