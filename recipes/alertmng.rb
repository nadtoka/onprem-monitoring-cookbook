#
# Cookbook:: monitoring
# Recipe:: alertmng
#

base_dir = node['monitoring']['base_dir']
registry_prefix = node['docker']['registry_prefix'].to_s
image_repo = node['alertmanager']['image']
image = registry_prefix.empty? ? image_repo : "#{registry_prefix}/#{image_repo}"

docker_image "alertmanager" do
    repo image
    tag node['alertmanager']['tag']
    action :pull_if_missing
end

docker_volume 'alertmanager-data' do
  action :create
end

volumes = [ 'alertmanager-data:/data',
            "#{base_dir}/alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml" ]
network_mode = 'host'
container_name = 'alertmanager'
restart_policy = 'unless-stopped'

# Hacky way to workaround strange ":" processing in list elements when passing to the template
volumes_mod = []
volumes.each do |val|
    volumes_mod.append(val.gsub(":", "__"))
end

template "/root/run_#{container_name}.sh" do
    mode '0755'
    source 'run_container_sh.erb'
    cookbook 'monitoring'
    variables(
        :volumes => volumes_mod,
        :network_mode => network_mode,
        :restart_policy => restart_policy,
        :docker_image => image,
        :docker_tag => node['alertmanager']['tag']
    )
end

docker_container container_name do
    repo image
    tag node['alertmanager']['tag']
    restart_policy restart_policy
    volumes volumes
    network_mode network_mode
    action :run
end
