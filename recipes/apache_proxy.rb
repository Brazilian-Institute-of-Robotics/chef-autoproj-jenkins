include_recipe 'apache2'
include_recipe 'apache2::mod_ssl'
include_recipe 'apache2::mod_proxy'
include_recipe 'apache2::mod_proxy_http'

package 'python-letsencrypt-apache'

template '/etc/apache2/sites-available/jenkins.conf' do
    source 'apache-jenkins.conf'
    action :create
    owner 'root'
    group 'root'
    mode '0644'
    notifies  :restart, 'service[apache2]'
end

apache_site 'jenkins' do
    enable true
end

