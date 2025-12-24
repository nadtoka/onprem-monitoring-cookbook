#
# Cookbook:: monitoring
# Recipe:: node-exporter
#

registry_prefix = node['docker']['registry_prefix'].to_s
image_repo = node['node-exporter']['image']
image = registry_prefix.empty? ? image_repo : "#{registry_prefix}/#{image_repo}"

docker_image 'node-exporter' do
  repo image
  tag node['node-exporter']['tag']
  action :pull_if_missing
end

command = ['--path.rootfs=/host --web.listen-address=:9900']
command_mod = '--path.rootfs=/host --web.listen-address=:9900'
volumes = ['/:/host:ro,rslave']
network_mode = 'host'
pid_mode = 'host'
container_name = 'node-exporter'
restart_policy = 'unless-stopped'

template "/root/run_#{container_name}.sh" do
  mode '0755'
  source 'run_container_sh.erb'
  cookbook 'monitoring'
  variables(
    container_name: container_name,
    volumes: volumes,
    command: command,
    network_mode: network_mode,
    pid_mode: pid_mode,
    restart_policy: restart_policy,
    docker_image: image,
    docker_tag: node['node-exporter']['tag']
  )
end

docker_container container_name do
  repo image
  tag node['node-exporter']['tag']
  restart_policy restart_policy
  volumes volumes
  command command_mod
  network_mode network_mode
  pid_mode pid_mode
  action :run
end
