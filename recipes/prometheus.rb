#
# Cookbook:: monitoring
# Recipe:: prometheus
#

base_dir = node['monitoring']['base_dir']
registry_prefix = node['docker']['registry_prefix'].to_s
image_repo = node['prometheus']['image']
image = registry_prefix.empty? ? image_repo : "#{registry_prefix}/#{image_repo}"

docker_image 'prometheus' do
  repo image
  tag node['prometheus']['tag']
  action :pull_if_missing
end

docker_volume 'prometheus-data' do
  action :create
end

volumes = [
  'prometheus-data:/prometheus',
  "#{base_dir}/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml",
  "#{base_dir}/prometheus/rules.yml:/etc/prometheus/rules.yml",
]
network_mode = 'host'
container_name = 'prometheus'
restart_policy = 'unless-stopped'

# Hacky way to workaround strange ":" processing in list elements when passing to the template
volumes_mod = volumes.map { |val| val.gsub(':', '__') }

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
    docker_tag: node['prometheus']['tag']
  )
end

docker_container container_name do
  repo image
  tag node['prometheus']['tag']
  restart_policy restart_policy
  volumes volumes
  network_mode network_mode
  action :run
end
