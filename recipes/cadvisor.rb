#
# Cookbook:: monitoring
# Recipe:: cadvisor
#

registry_prefix = node['docker']['registry_prefix'].to_s
image_repo = node['cadvisor']['image']
image = registry_prefix.empty? ? image_repo : "#{registry_prefix}/#{image_repo}"

docker_image 'cadvisor' do
  repo image
  tag node['cadvisor']['tag']
  action :pull_if_missing
end

volumes = [
  '/:/rootfs:ro',
  '/var/run:/var/run:ro',
  '/sys:/sys:ro',
  '/var/lib/docker/:/var/lib/docker:ro',
  '/dev/disk/:/dev/disk:ro'
]
network_mode = 'docker_network'
container_name = 'cadvisor'
restart_policy = 'unless-stopped'

# Hacky way to workaround strange ":" processing in list elements when passing to the template
volumes_mod = []
volumes.each do |val|
  volumes_mod << val.gsub(':', '__')
end

template "/root/run_#{container_name}.sh" do
  mode '0755'
  source 'run_container_sh.erb'
  cookbook 'monitoring'
  variables(
    container_name: container_name,
    volumes: volumes_mod,
    network_mode: network_mode,
    restart_policy: restart_policy,
    docker_image: image,
    docker_tag: node['cadvisor']['tag']
  )
end

docker_container container_name do
  repo image
  tag node['cadvisor']['tag']
  restart_policy restart_policy
  volumes volumes
  network_aliases [container_name]
  port node['cadvisor']['ports']
  network_mode network_mode
  action :run
end
