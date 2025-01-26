import jenkins.model.Jenkins
import hudson.slaves.DumbSlave
import hudson.slaves.RetentionStrategy
import hudson.model.Node
import hudson.slaves.JNLPLauncher

// Agent configuration parameters
String agentName = 'simple-agent'
String remoteFS = '/home/jenkins'
String numExecutors = '1'
Node.Mode agentMode = Node.Mode.NORMAL
String labelString = 'simple'

// Create JNLP launcher for the agent
def jnlpLauncher = new JNLPLauncher()

// Define the agent
def agent = new DumbSlave(
    agentName, 
    remoteFS, 
    jnlpLauncher
)
agent.setNumExecutors(Integer.parseInt(numExecutors))
agent.setMode(agentMode)
agent.setLabelString(labelString)
agent.setRetentionStrategy(new RetentionStrategy.Always())

// Get Jenkins instance
def jenkinsAgent = Jenkins.get()

// Check if agent already exists
if (jenkinsAgent.getNode(agentName) == null) { 
    jenkinsAgent.addNode(agent)
    println "Agent configured successfully."
} else { 
    println "Agent already exists. No changes made."
}

// Save Jenkins configuration
jenkinsAgent.save()
println 'Jenkins configuration saved successfully.'

// Get and print agent secret safely
def computer = agent.toComputer()
if (computer != null) {
    def secret = computer.getJnlpMac()
    println "Agent secret: \$${secret}"

    // Define the file path
    def secretFilePath = "/secret/jenkins_agent"
    
    // Write the secret to the file
    def secretFile = new File(secretFilePath)
    secretFile.text = secret
    
    println "Agent secret written to: \$${secretFilePath}"
} else {
    println "Error: Could not retrieve agent secret, agent may not be fully initialized."
}
