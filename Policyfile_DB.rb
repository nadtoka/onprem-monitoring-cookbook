# Policyfile.rb - Describe how you want Chef Infra Client to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile/

# A name that describes what the system you're building with Chef does.
name 'monitoring_db'

# Where to find external cookbooks:
default_source :supermarket
default_source :chef_repo, '../'
default_source :chef_repo, '../' do |s|
  s.preferred_for 'nginx'
end

# run_list: chef-client will run these recipes in the order specified.
run_list 'monitoring::docker', 'monitoring::postgres', 'monitoring::node-exporter', 'monitoring::cadvisor'

# Specify a custom source for a single cookbook:
cookbook 'monitoring', path: '.'
