#
# Cookbook:: monitoring
# Recipe:: docker
#

registry = node['docker']['registry'].to_s

unless registry.empty?
  docker_registry registry do
    username node['docker']['username']
    password node['docker']['key']
  end
end
