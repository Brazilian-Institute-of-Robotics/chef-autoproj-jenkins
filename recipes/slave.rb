include_recipe "#{cookbook_name}::_auth"

package 'default-jre'
jenkins_jnlp_slave node.name do
    description 'generic slave builder'
    executors 6
end

