node.run_state[:jenkins_private_key] = data_bag_item('jenkins', 'auth')['admin_key']

if node['autoproj']['dev']
    include_recipe "#{cookbook_name}::_autoproj_dev"
end
package 'default-jre'
include_recipe "#{cookbook_name}::_common"

directory '/var/lib/jenkins'

jenkins_jnlp_slave node.name do
    description 'generic slave builder'
    executors (node['cpu']['cores'] * 1.5).ceil
    labels ['autoproj-jenkins']
    remote_fs '/var/lib/jenkins' # must match the JENKINS_HOME on the master
    environment(
        'LANG' => "en_US.UTF-8",
        'LC_ALL' => "en_US.UTF-8"
    )
end

