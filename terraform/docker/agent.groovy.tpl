import jenkins.model.Jenkins
import hudson.slaves.DumbSlave
import hudson.slaves.SlaveComputer
import hudson.slaves.RetentionStrategy
import hudson.model.Node
import hudson.plugins.sshslaves.SSHLauncher
import hudson.slaves.EnvironmentVariablesNodeProperty
import hudson.EnvVars

// Agent configuration parameters
String agentName = 'remote-agent'
String agentDescription = 'Jenkins SSH Agent'
String remoteFS = '/home/jenkins'
String numExecutors = '2'
Node.Mode agentMode = Node.Mode.NORMAL
String labelString = 'linux docker'
String host = '192.168.1.200'
int port = 22
String credentialsId = 'jenkins-ssh-key'
int launchTimeoutSeconds = 120
int maxNumRetries = 5
int retryWaitTime = 15

// API Key (replace with actual value or inject securely)
String jenkinsApiKey = 'your-generated-api-key'

// Create SSH launcher for the agent
SSHLauncher sshLauncher = new SSHLauncher(
    host,
    port,
    credentialsId,
    null,  // JVM Options
    null,  // JavaPath
    null,  // Prefix Start Slave Command
    null,  // Suffix Start Slave Command
    launchTimeoutSeconds,
    maxNumRetries,
    retryWaitTime
)

// Define the agent
DumbSlave agent = new DumbSlave(
    agentName,
    agentDescription,
    remoteFS,
    numExecutors,
    agentMode,
    labelString,
    sshLauncher,
    RetentionStrategy.INSTANCE_ALWAYS,
    []
)

// Add environment variables, including the API key
EnvVars env = new EnvVars()
env.put('JENKINS_API_KEY', jenkinsApiKey)
EnvironmentVariablesNodeProperty envProperty = new EnvironmentVariablesNodeProperty(env)
agent.getNodeProperties().add(envProperty)

// Get Jenkins instance
Jenkins jenkins = Jenkins.get()

// Check if agent already exists
if (jenkins.getNode(agentName) == null) {
    jenkins.addNode(agent)
    println "Agent '${agentName}' configured successfully with API key."
} else {
    println "Agent '${agentName}' already exists. No changes made."
}

// Save Jenkins configuration
jenkins.save()
println 'Jenkins configuration saved successfully.'
