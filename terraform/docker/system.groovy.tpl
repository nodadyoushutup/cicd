import jenkins.model.Jenkins
import jenkins.model.JenkinsLocationConfiguration

// Grab Jenkins instance
def jenkinsSystem = Jenkins.get()

// Set the Jenkins URL
def jenkins = JenkinsLocationConfiguration.get()
jenkinsSystem.setUrl("${JENKINS_URL}")
jenkinsSystem.save()