base_dir = node['monitoring']['base_dir']
owner = node['monitoring']['user']
group = node['monitoring']['group']

directory base_dir do
    mode '0755'
    owner owner
    group group
    recursive true
    action :create
end

directory "#{base_dir}/alertmanager" do
    mode '0755'
    owner owner
    group group
    recursive true
    action :create
end

template "#{base_dir}/alertmanager/alertmanager.yml" do
    source 'alertmanager/alertmanager.yml.erb'
    mode '0644'
    owner owner
    group group
    variables(
        :smtp_host => node['smtp']['host'],
        :smtp_port => node['smtp']['port'],
        :smtp_from => node['smtp']['from'],
        :smtp_to => node['smtp']['to'],
        :smtp_username => node['smtp']['user'],
        :smtp_password => node['smtp']['pwd'],
        :smtp_identity => node['smtp']['identity']
    )
end

directory "#{base_dir}/blackbox_exporter" do
    mode '0755'
    owner owner
    group group
    recursive true
    action :create
end

template "#{base_dir}/blackbox_exporter/blackbox.yml" do
    source 'blackbox/blackbox.yml.erb'
    mode '0644'
    owner owner
    group group
end

template "#{base_dir}/blackbox_exporter/jsonconfig.yml" do
    source 'blackbox/jsonconfig.yml.erb'
    mode '0644'
    owner owner
    group group
end

directory "#{base_dir}/prometheus" do
    mode '0755'
    owner owner
    group group
    recursive true
    action :create
end

template "#{base_dir}/prometheus/prometheus.yml" do
    source 'prometheus/prometheus.yml.erb'
    mode '0644'
    owner owner
    group group
    variables(
        :core_wh => node['server']['cwh']
    )
end

template "#{base_dir}/prometheus/rules.yml" do
    source 'prometheus/rules.yml.erb'
    mode '0644'
    owner owner
    group group
end

directory "#{base_dir}/grafana/dashboards" do
    mode '0755'
    owner owner
    group group
    recursive true
    action :create
end

template "#{base_dir}/grafana/dashboards/blackbox.json" do
    source 'grafana/dashboards/blackbox.json.erb'
    mode '0644'
    owner owner
    group group
end

template "#{base_dir}/grafana/dashboards/docker.json" do
    source 'grafana/dashboards/docker.json.erb'
    mode '0644'
    owner owner
    group group
end

template "#{base_dir}/grafana/dashboards/nodeexporter.json" do
    source 'grafana/dashboards/nodeexporter.json.erb'
    mode '0644'
    owner owner
    group group
end

template "#{base_dir}/grafana/dashboards/postgres.json" do
    source 'grafana/dashboards/postgres.json.erb'
    mode '0644'
    owner owner
    group group
end

directory "#{base_dir}/grafana/provisioning/datasources" do
    mode '0755'
    owner owner
    group group
    recursive true
    action :create
end

template "#{base_dir}/grafana/provisioning/datasources/datasource.yml" do
    source 'grafana/provisioning/datasources/datasource.yml.erb'
    mode '0644'
    owner owner
    group group
end

directory "#{base_dir}/grafana/provisioning/dashboards" do
    mode '0755'
    owner owner
    group group
    recursive true
    action :create
end

template "#{base_dir}/grafana/provisioning/dashboards/dashboard.yml" do
    source 'grafana/provisioning/dashboards/dashboard.yml.erb'
    mode '0644'
    owner owner
    group group
end

template "#{base_dir}/grafana/admin_password" do
    source 'grafana/admin_password.erb'
    mode '0644'
    owner owner
    group group
    variables(
        :gr_pwd => node['grafana']['pwd']
    )
end
