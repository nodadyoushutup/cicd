import jenkins.model.Jenkins
import hudson.security.SecurityRealm
import org.jenkinsci.plugins.GithubSecurityRealm
import org.jenkinsci.plugins.GithubAuthorizationStrategy
import hudson.security.AuthorizationStrategy
import hudson.security.FullControlOnceLoggedInAuthorizationStrategy

String githubWebUri   = 'https://github.com'
String githubApiUri   = 'https://api.github.com'
String clientID       = '${GITHUB_JENKINS_CLIENT_ID}'
String clientSecret   = '${GITHUB_JENKINS_CLIENT_SECRET}'
String oauthScopes    = 'read:org'

// Instantiate the GitHub Security Realm
SecurityRealm githubRealm = new GithubSecurityRealm(
    githubWebUri,
    githubApiUri,
    clientID,
    clientSecret,
    oauthScopes
)

// Grab Jenkins instance
def jenkins = Jenkins.get()

// Configure Security Realm if different
if (!githubRealm.equals(jenkins.getSecurityRealm())) {
    jenkins.setSecurityRealm(githubRealm)
    println "GitHub Security Realm configured."
} else {
    println "GitHub Security Realm is already configured. No changes made."
}

//permissions are ordered similar to web UI
//Admin User Names
String adminUserNames = '${GITHUB_USERNAME}'
//Participant in Organization
String organizationNames = ''
//Use Github repository permissions
boolean useRepositoryPermissions = true
//Grant READ permissions to all Authenticated Users
boolean authenticatedUserReadPermission = false
//Grant CREATE Job permissions to all Authenticated Users
boolean authenticatedUserCreateJobPermission = false
//Grant READ permissions for /github-webhook
boolean allowGithubWebHookPermission = false
//Grant READ permissions for /cc.xml
boolean allowCcTrayPermission = false
//Grant READ permissions for Anonymous Users
boolean allowAnonymousReadPermission = false
//Grant ViewStatus permissions for Anonymous Users
boolean allowAnonymousJobStatusPermission = false

// Set Authorization Strategy to require login for all users
AuthorizationStrategy authStrategy = new GithubAuthorizationStrategy(
    adminUserNames,
    authenticatedUserReadPermission,
    useRepositoryPermissions,
    authenticatedUserCreateJobPermission,
    organizationNames,
    allowGithubWebHookPermission,
    allowCcTrayPermission,
    allowAnonymousReadPermission,
    allowAnonymousJobStatusPermission
)

if (!authStrategy.equals(jenkins.getAuthorizationStrategy())) {
    jenkins.setAuthorizationStrategy(authStrategy)
    println "Authorization Strategy configured to enforce authentication."
} else {
    println "Authorization Strategy is already configured."
}

// Save changes
jenkins.save()

