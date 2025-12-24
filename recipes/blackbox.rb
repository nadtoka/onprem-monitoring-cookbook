#
# Cookbook:: monitoring
# Recipe::  blackbox
#

base_dir = node['monitoring']['base_dir']
registry_prefix = node['docker']['registry_prefix'].to_s
image_repo = node['blackbox-exporter']['image']
image = registry_prefix.empty? ? image_repo : "#{registry_prefix}/#{image_repo}"

docker_image "blackbox-exporter" do
    repo image
    tag node['blackbox-exporter']['tag']
    action :pull_if_missing
end

command = [ "--config.file=/config/blackbox.yml" ]
volumes = [ "#{base_dir}/blackbox_exporter:/config" ]
network_mode = 'host'
container_name = 'blackbox-exporter'
restart_policy = 'unless-stopped'

template "/root/run_#{container_name}.sh" do
    mode '0755'
    source 'run_container_sh.erb'
    cookbook 'monitoring'
    variables(
        :volumes => volumes,
        :command => command,
        :network_mode => network_mode,
        :restart_policy => restart_policy,
        :docker_image => image,
        :docker_tag => node['blackbox-exporter']['tag']
    )
end

docker_container container_name do
    repo image
    tag node['blackbox-exporter']['tag']
    restart_policy restart_policy
    volumes volumes
    command command
    network_mode network_mode
    action :run
end
