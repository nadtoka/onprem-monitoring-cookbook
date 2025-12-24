#
# Cookbook:: monitoring
# Recipe:: postgres
#

databases = node['monitordb']['databases'] || []
registry_prefix = node['docker']['registry_prefix'].to_s
image_repo = node['postgres-exporter']['image']
image = registry_prefix.empty? ? image_repo : "#{registry_prefix}/#{image_repo}"

execute 'postgres create user monitor' do
    command "/usr/bin/psql -c \"create user #{node['monitordb']['user']}  with \
    encrypted password \'#{node['monitordb']['pwd']}\' \" -U postgres --host #{node['postgres']['host']} --port 5432"
    user "postgres"
    login true
    sensitive true

    not_if "psql -h #{node['postgres']['host']} postgres -tAc \"SELECT 1 FROM pg_roles WHERE rolname='#{node['monitordb']['user']}'\" | grep -q 1", :user => 'postgres'
end

grant_commands = databases.map do |database|
    "/usr/bin/psql -c \" GRANT CONNECT ON DATABASE #{database} TO #{node['monitordb']['user']} \" -U postgres --host #{node['postgres']['host']} --port 5432"
end

grant_commands.unshift("/usr/bin/psql -c \" GRANT pg_monitor TO #{node['monitordb']['user']}\" -U postgres --host #{node['postgres']['host']} --port 5432")
grant_commands.unshift("/usr/bin/psql -c \" GRANT USAGE ON SCHEMA public TO #{node['monitordb']['user']} \" -U postgres --host #{node['postgres']['host']} --port 5432")

bash 'grant permissions' do
    user "postgres"
    login true
    live_stream true
    code <<-EOH
    #{grant_commands.join("\n    ")}
    EOH

    not_if "PGPASSWORD=#{node['postgres']['pwd']} psql -h #{node['postgres']['host']}  postgres -tAc \"select 1 from pg_user join pg_auth_members on (pg_user.usesysid=pg_auth_members.member) join pg_roles on (pg_roles.oid=pg_auth_members.roleid) where pg_user.usename='#{node['monitordb']['user']}'\" | grep -q 1 " , :user => 'postgres'
end

docker_image "postgres-exporter" do
    repo image
    tag node['postgres-exporter']['tag']
    action :pull_if_missing
end

env = [ "DATA_SOURCE_NAME=postgresql://#{node['monitordb']['user']}:#{node['monitordb']['pwd']}@localhost:5432/postgres?sslmode=disable" ]
network_mode = 'host'
container_name = 'postgres-exporter'
restart_policy = 'unless-stopped'

template "/root/run_#{container_name}.sh" do
    mode '0755'
    source 'run_container_sh.erb'
    cookbook 'monitoring'
    variables(
        :container_name => container_name,
        :env => env,
        :network_mode => network_mode,
        :restart_policy => restart_policy,
        :docker_image => image,
        :docker_tag => node['postgres-exporter']['tag']
    )
end

docker_container container_name do
    repo image
    tag node['postgres-exporter']['tag']
    restart_policy restart_policy
    env env
    network_mode network_mode
    action :run
end
