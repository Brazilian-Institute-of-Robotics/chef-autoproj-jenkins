# Workaround the run setup wizard on jenkins > 2.4
default['jenkins']['master']['jvm_options'] = "-Dhudson.security.ArtifactsPermission=true -Djenkins.install.runSetupWizard=false"

# Use the Jenkins LTS
default['jenkins']['master']['repository'] = "http://pkg.jenkins-ci.org/debian-stable"

# Whether autoproj-jenkins should be used in --dev mode
#
# In dev mode, autoproj, autoproj-jenkins and autobuild are checked out from git
# in /opt. The chef recipes make sure of that
default['autoproj']['dev'] = false

# The credentials of the user that autoproj-jenkins should use to access Jenkins
# to manage the package's jobs
default['autoproj-jenkins']['cli-credentials'].tap do |cli_credentials|
    # The credential ID. This is the ID used by default by autoproj-jenkins
    cli_credentials['id'] = 'autoproj-jenkins-cli'

    # The user under which autoproj-jenkins should access Jenkins
    cli_credentials['user'] = 'admin'
    
    # The user's password. It only has to be set if 'user' is not 'admin'. If
    # 'user' is admin, the admin password will be used
    cli_credentials['password'] = nil
end
