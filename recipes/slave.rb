node.run_state[:jenkins_private_key] = data_bag_item('jenkins', 'auth')['admin_key']

if node['autoproj']['dev']
    include_recipe "#{cookbook_name}::_autoproj_dev"
end
package 'default-jre'
jenkins_jnlp_slave node.name do
    description 'generic slave builder'
    executors (node['cpu']['cores'] * 1.5).ceil
    labels ['autoproj-jenkins']
end

