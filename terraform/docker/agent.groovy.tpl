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
JNLPLauncher jnlpLauncher = new JNLPLauncher()

// Define the agent
DumbSlave agent = new DumbSlave(
    agentName, 
    remoteFS, 
    jnlpLauncher
)
agent.setNumExecutors(Integer.parseInt(numExecutors))
agent.setMode(agentMode)
agent.setLabelString(labelString)
agent.setRetentionStrategy(new RetentionStrategy.Always())

// Get Jenkins instance
Jenkins jenkins = Jenkins.get()

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



def agent = jenkinsAgent.getNode("simple-agent")
def secret = agent.getComputer().getJnlpMac()
println "Agent secret: $${secret}"