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

// Manually specified API key (JNLP secret)
String customSecret = "your-custom-api-key-here"

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
    
    // Set custom JNLP secret after adding the agent
    def computer = agent.toComputer()
    if (computer != null) {
        computer.setJnlpMac(customSecret)
        println "Custom API key (secret) has been set."
    } else {
        println "Error: Could not set custom secret, agent may not be fully initialized."
    }
} else { 
    println "Agent already exists. No changes made."
}

// Save Jenkins configuration
jenkinsAgent.save()
println 'Jenkins configuration saved successfully.'

// Verify and print agent secret safely
def computer = agent.toComputer()
if (computer != null) {
    def secret = computer.getJnlpMac()
    println "Agent secret: \$${secret}"
} else {
    println "Error: Could not retrieve agent secret, agent may not be fully initialized."
}
