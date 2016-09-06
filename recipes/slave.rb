node.run_state[:jenkins_private_key] = data_bag_item('jenkins', 'auth')['admin_key']

package 'default-jre'
jenkins_jnlp_slave node.name do
    description 'generic slave builder'
    executors 6
end

