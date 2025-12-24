#
# Cookbook:: monitoring
# Recipe:: grafana
#

base_dir = node['monitoring']['base_dir']
registry_prefix = node['docker']['registry_prefix'].to_s
image_repo = node['grafana']['image']
image = registry_prefix.empty? ? image_repo : "#{registry_prefix}/#{image_repo}"

docker_image 'grafana' do
  repo image
  tag node['grafana']['tag']
  action :pull_if_missing
end

docker_volume 'grafana-data' do
  action :create
end

env = ['GF_SECURITY_ADMIN_PASSWORD__FILE=/run/secrets/admin_password']
volumes = [
  'grafana-data:/var/lib/grafana',
  "#{base_dir}/grafana/admin_password:/run/secrets/admin_password",
  "#{base_dir}/grafana/provisioning/datasources/datasource.yml:/etc/grafana/provisioning/datasources/datasource.yml",
  "#{base_dir}/grafana/provisioning/dashboards/dashboard.yml:/etc/grafana/provisioning/dashboards/dashboard.yml",
  "#{base_dir}/grafana/dashboards/nodeexporter.json:/var/lib/grafana/dashboards/nodeexporter.json",
  "#{base_dir}/grafana/dashboards/docker.json:/var/lib/grafana/dashboards/docker.json",
  "#{base_dir}/grafana/dashboards/postgres.json:/var/lib/grafana/dashboards/postgres.json",
  "#{base_dir}/grafana/dashboards/blackbox.json:/var/lib/grafana/dashboards/blackbox.json",
]
network_mode = 'host'
container_name = 'grafana'
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
    docker_tag: node['grafana']['tag']
  )
end

docker_container container_name do
  repo image
  tag node['grafana']['tag']
  restart_policy restart_policy
  volumes volumes
  env env
  network_mode network_mode
  action :run
end
