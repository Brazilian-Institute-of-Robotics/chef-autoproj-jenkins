include_recipe 'locale::default'

package 'ruby'

# The Jenkins CLI gem that autoproj-jenkins needs depends on a C extension ...
# make sure it can be compiled
package 'ruby-dev'
package 'build-essential'
package 'zlib1g-dev'

# Needed for the conversion of Boost unit tests into
package 'libsaxonb-java'

# Needed for the osdep installation
sudo 'jenkins' do
    group 'jenkins'
    nopasswd true
    commands ['/usr/bin/apt-get']
    env_keep_add ['DEBIAN_FRONTEND']
end


