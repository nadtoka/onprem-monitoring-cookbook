#
# Cookbook:: monitoring
# Recipe:: hosts
#

execute "echo \"#{node['lb']['ip']}  lb\" >> /etc/hosts" do
    not_if "grep -E -o ' lb' /etc/hosts"
end

execute "echo \"#{node['core']['ip']}  core\" >> /etc/hosts" do
    not_if "grep -E -o ' core' /etc/hosts"
end

execute "echo \"#{node['db']['ip']}  db\" >> /etc/hosts" do
    not_if "grep -E -o ' db' /etc/hosts"
end

execute "echo \"#{node['lb']['ip']}  #{node['core']['fqdn']}\" >> /etc/hosts" do
    not_if "grep #{node['core']['fqdn']} /etc/hosts"
end

execute "echo \"#{node['lb']['ip']}  web.#{node['core']['fqdn']}\" >> /etc/hosts" do
    not_if "grep web.#{node['core']['fqdn']} /etc/hosts"
end
