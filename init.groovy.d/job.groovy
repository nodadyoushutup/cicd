vscode-remote://ssh-remote%2Bcicd/home/ubuntu/iac/cicd/docker/init.groovy.d/job.groovyimport jenkins.model.Jenkins
import javax.xml.transform.stream.StreamSource
import java.io.StringReader
import java.io.ByteArrayInputStream

// Define the job name (change this if needed)
def jobName = "jenkins"

// Your job configuration XML
def configXml = '''
  <flow-definition plugin="workflow-job@1505.vea_4b_20a_4a_495">
    <actions>
      <org.jenkinsci.plugins.pipeline.modeldefinition.actions.DeclarativeJobAction plugin="pipeline-model-definition@2.2247.va_423189a_7dff"/>
      <org.jenkinsci.plugins.pipeline.modeldefinition.actions.DeclarativeJobPropertyTrackerAction plugin="pipeline-model-definition@2.2247.va_423189a_7dff">
        <jobProperties/>
        <triggers/>
        <parameters/>
        <options/>
      </org.jenkinsci.plugins.pipeline.modeldefinition.actions.DeclarativeJobPropertyTrackerAction>
    </actions>
    <description/>
    <keepDependencies>false</keepDependencies>
    <properties>
      <jenkins.model.BuildDiscarderProperty>
        <strategy class="hudson.tasks.LogRotator">
          <daysToKeep>-1</daysToKeep>
          <numToKeep>20</numToKeep>
          <artifactDaysToKeep>-1</artifactDaysToKeep>
          <artifactNumToKeep>-1</artifactNumToKeep>
          <removeLastBuild>false</removeLastBuild>
        </strategy>
      </jenkins.model.BuildDiscarderProperty>
      <org.jenkinsci.plugins.workflow.job.properties.DisableConcurrentBuildsJobProperty>
        <abortPrevious>false</abortPrevious>
      </org.jenkinsci.plugins.workflow.job.properties.DisableConcurrentBuildsJobProperty>
      <com.coravy.hudson.plugins.github.GithubProjectProperty plugin="github@1.42.0">
        <projectUrl>https://github.com/nodadyoushutup/iac/</projectUrl>
        <displayName/>
      </com.coravy.hudson.plugins.github.GithubProjectProperty>
      <hudson.model.ParametersDefinitionProperty>
        <parameterDefinitions>
          <hudson.model.StringParameterDefinition>
            <name>subdir</name>
            <defaultValue>terraform/job/jenkins</defaultValue>
            <trim>true</trim>
          </hudson.model.StringParameterDefinition>
        </parameterDefinitions>
      </hudson.model.ParametersDefinitionProperty>
    </properties>
    <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps@4043.va_fb_de6a_a_8b_f5">
      <scm class="hudson.plugins.git.GitSCM" plugin="git@5.7.0">
        <configVersion>2</configVersion>
        <userRemoteConfigs>
          <hudson.plugins.git.UserRemoteConfig>
            <url>https://github.com/nodadyoushutup/iac</url>
          </hudson.plugins.git.UserRemoteConfig>
        </userRemoteConfigs>
        <branches>
          <hudson.plugins.git.BranchSpec>
            <name>main</name>
          </hudson.plugins.git.BranchSpec>
        </branches>
        <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
        <submoduleCfg class="empty-list"/>
        <extensions/>
      </scm>
      <scriptPath>terraform/job/jenkins/pipeline/terraform.jenkins</scriptPath>
      <lightweight>true</lightweight>
    </definition>
    <triggers/>
    <disabled>false</disabled>
  </flow-definition>
  '''

def jenkins = Jenkins.instance

// Check if the job exists
def job = jenkins.getItem(jobName)
if (job == null) {
    println "Job '${jobName}' does not exist. Creating new job."
    jenkins.createProjectFromXML(jobName, new ByteArrayInputStream(configXml.getBytes("UTF-8")))
    println "Job '${jobName}' created successfully."
} else {
    println "Job '${jobName}' exists. Updating job configuration."
    job.updateByXml(new StreamSource(new StringReader(configXml)))
    job.save()
    println "Job '${jobName}' updated successfully."
}
