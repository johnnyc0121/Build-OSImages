docker run -d \
  --rm \
  --name jenkins-agent \
  --user 2000:2000 \
  --network jenkins-network \
  -e JENKINS_URL=http://jenkins-server:8080 \
  -e JENKINS_AGENT_NAME=jenkins-agent \
  -e JENKINS_SECRET=<PUT SECRET HERE> \
  -v /home/jenkins/workspaces:/home/jenkins/workspace \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins-agent:20251110