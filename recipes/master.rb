#
# Cookbook Name:: autoproj-jenkins
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'openssl'
require 'net/ssh'

if node['autoproj']['dev']
    include_recipe "#{cookbook_name}::_autoproj_dev"
end
include_recipe "#{cookbook_name}::_common"
include_recipe 'jenkins::master'

jenkins_command 'safe-restart' do
    action :nothing
end
jenkins_command 'reload-configuration' do
    action :nothing
end

plugins = [
  "matrix-auth",
  "workflow-aggregator",
  "workflow-scm-step",
  "workflow-support",
  "workflow-cps",
  "workflow-job",
  "workflow-step-api",
  "pipeline-stage-step",
  "pipeline-stage-view",
  "script-security",
  "job-dsl",
  "git",
  "warnings",
  "ansicolor",
  "greenballs",
  "PrioritySorter",
  "embeddable-build-status",
  "pipeline-utility-steps",
  "copyartifact",
  'xunit',
  'dashboard-view',
  'purge-build-queue-plugin',
  'credentials-binding',
  'subversion'
]

plugins.each_with_index do |(plugin, plugin_version), index|
    jenkins_plugin plugin do
        if plugin_version
            version plugin_version
        end
	# we want to restart Jenkins after the last plugin installation
	notifies :execute, "jenkins_command[safe-restart]", :immediately if index == plugins.length - 1
    end
end





jenkins_auth = data_bag_item('jenkins', 'auth')
node.run_state[:jenkins_private_key] = jenkins_auth['admin_key']

admin_public_key = ChefAutoprojJenkins.public_key_of(jenkins_auth['admin_key'])
jenkins_user 'admin' do
    password jenkins_auth['admin_password']
    public_keys [admin_public_key]
end

jenkins_user 'bir' do
    password jenkins_auth['bir']
end
autoproj_jenkins_public_key = ChefAutoprojJenkins.public_key_of(jenkins_auth['autoproj-jenkins'])
jenkins_user 'autoproj-jenkins' do
    public_keys [autoproj_jenkins_public_key]
end

autoproj_cli_credentials = node['autoproj-jenkins']['cli-credentials']
jenkins_password_credentials autoproj_cli_credentials['user'] do
    id autoproj_cli_credentials['id']
    description "credentials used by the generated 'buildconf' job to manage the separate build jobs"
    if password = autoproj_cli_credentials['password']
        password password
    elsif autoproj_cli_credentials['user'] == 'admin'
        password jenkins_auth['admin_password']
    else
        raise "the autoproj-jenkins/cli-credentials/user is not 'admin', you must set a password explicitely"
    end
end

# This configures authentication
jenkins_script 'auth' do
  command <<-EOH.gsub(/^ {4}/, '')
    import jenkins.model.Jenkins
    import hudson.security.HudsonPrivateSecurityRealm
    import hudson.security.csrf.DefaultCrumbIssuer
    import hudson.security.GlobalMatrixAuthorizationStrategy
    def instance = Jenkins.getInstance()

    if (!instance.isUseCrumbs())
    {
        instance.setCrumbIssuer(new hudson.security.csrf.DefaultCrumbIssuer(false))
        instance.save()
    }

    // Authentication - use Jenkins own user base for now
    if (!(instance.getSecurityRealm() instanceof hudson.security.HudsonPrivateSecurityRealm))
    {
        instance.setSecurityRealm(new hudson.security.HudsonPrivateSecurityRealm(false));
        instance.save()
    }

    //////////////////////////////////////
    // Authorization
    //////////////////////////////////////
    def strategy = new GlobalMatrixAuthorizationStrategy()

    strategy.add(Jenkins.ADMINISTER, "admin")
    strategy.add(hudson.model.Run.ARTIFACTS, "admin")

    strategy.add(hudson.model.Job.BUILD,  "autoproj-jenkins")
    strategy.add(hudson.model.Job.CREATE,  "autoproj-jenkins")

    strategy.add(Jenkins.READ,            "bir")
    strategy.add(hudson.model.View.READ,  "bir")
    strategy.add(hudson.model.Job.BUILD,  "bir")
    strategy.add(hudson.model.Job.CANCEL, "bir")
    strategy.add(hudson.model.Item.READ,  "bir")
    strategy.add(hudson.model.View.READ,  "bir")
    strategy.add(hudson.model.Run.ARTIFACTS, "bir")

    //check for equality, no need to modify the runtime if no settings changed
    if (!strategy.equals(instance.getAuthorizationStrategy())) {
        instance.setAuthorizationStrategy(strategy)
        instance.save()
    }
  EOH
end
