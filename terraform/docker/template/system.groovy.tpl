import jenkins.model.Jenkins
import jenkins.model.JenkinsLocationConfiguration

// Get the Jenkins location configuration
def jenkinsLocation = JenkinsLocationConfiguration.get()

// Set the Jenkins URL
jenkinsLocation.setUrl("https://jenkins.nodadyoushutup.com")

// Save the changes
jenkinsLocation.save()

println("Jenkins URL has been set to: " + jenkinsLocation.getUrl())
