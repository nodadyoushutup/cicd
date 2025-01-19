import jenkins.model.Jenkins
import jenkins.model.JenkinsLocationConfiguration

// Grab Jenkins instance
def jenkins = Jenkins.get()

// Set the Jenkins URL
def jenkins = JenkinsLocationConfiguration.get()
jenkins.setUrl("${JENKINS_URL}")
jenkins.save()