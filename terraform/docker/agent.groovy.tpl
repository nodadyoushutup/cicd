import jenkins.model.Jenkins
import hudson.slaves.DumbSlave
import hudson.slaves.RetentionStrategy
import hudson.model.Node
import hudson.plugins.sshslaves.SSHLauncher

// Agent configuration parameters
String agentName = 'simple-agent'
String remoteFS = '/home/jenkins'
String numExecutors = '1'
Node.Mode agentMode = Node.Mode.NORMAL
String labelString = 'simple'
String host = '192.168.1.150'
int port = 22
String credentialsId = 'jenkins-ssh-key'

// Create SSH launcher for the agent
SSHLauncher sshLauncher = new SSHLauncher(
    host,
    port,
    credentialsId
)

// Define the agent
DumbSlave agent = new DumbSlave(
    agentName,
    remoteFS,
    sshLauncher
)
agent.setNumExecutors(Integer.parseInt(numExecutors))
agent.setMode(agentMode)
agent.setLabelString(labelString)
agent.setRetentionStrategy(RetentionStrategy.INSTANCE_ALWAYS)

// Get Jenkins instance
Jenkins jenkins = Jenkins.get()

// Check if agent already exists
if (jenkins.getNode(agentName) == null) {
    jenkins.addNode(agent)
    println "Agent '${agentName}' configured successfully."
} else {
    println "Agent '${agentName}' already exists. No changes made."
}

// Save Jenkins configuration
jenkins.save()
println 'Jenkins configuration saved successfully.'
