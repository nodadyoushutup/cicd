import jenkins.model.Jenkins

def agentName = 'simple-agent'
def secretFile = new File('/secrets/jenkins-agent-secret')

try {
    def node = Jenkins.instance.getNode(agentName)
    if (node != null) {
        def computer = node.toComputer()
        if (computer != null) {
            def secret = computer.jnlpMac
            secretFile.parentFile.mkdirs()
            secretFile.text = secret
            println "Generated secret for '${agentName}' at ${secretFile}"
        } else {
            println "No computer for node '${agentName}'"
        }
    } else {
        println "Node '${agentName}' not found"
    }
} catch (Throwable t) {
    println "Error writing agent secret: ${t.message}"
}
