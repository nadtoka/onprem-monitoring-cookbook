#TODO: Switch to https://docs.chef.io/infra_language/secrets/ (now in beta)
unified_mode true

require 'vault'

vault_url = node['vault']['url'].to_s
vault_token = node['vault']['token'].to_s
vault_secret = node['vault']['secret'].to_s
vault_monitoring = node['vault']['monitoring'].to_s

if vault_url.empty? || vault_token.empty? || vault_secret.empty?
  Chef::Log.info('Vault configuration missing; skipping vault lookups.')
else
  vault = Vault::Client.new(address: vault_url, ssl_verify: false)
  vault.token = vault_token

  # Renew the lease while we're here otherwise it'll eventually expire and be useless.
  # vault.auth_token.renew_self 3600 * 24 * 30

  # Extract secret into a hash
  secret = vault.logical.read(vault_secret)
  node.override['ssh']['user'] = secret.data[:data][:SSH_USER]
  node.override['ssh']['pubkey'] = secret.data[:data][:SSH_PUBKEY]
  node.override['ssh']['key'] = secret.data[:data][:SSH_KEY]
  node.override['core']['fqdn'] = secret.data[:data][:CORE_WEB_HOST]

  node.override['core']['web_pwd'] = secret.data[:data][:CORE_WEB_PWD]
  node.override['smile']['web_pwd'] = secret.data[:data][:SMILE_WEB_PWD]
  node.override['activemq']['web_pwd'] = secret.data[:data][:SMILE_AMQ_PWD]
  node.override['postgres']['pwd'] = secret.data[:data][:POSTGRES_PASSWORD]

  if vault_monitoring.empty?
    Chef::Log.info('Vault monitoring secret not configured; skipping monitoring secrets.')
  else
    monitoring_secret = vault.logical.read(vault_monitoring)
    node.override['monitordb']['pwd'] = monitoring_secret.data[:data][:MONITOR_DB_PWD]
    node.override['monitordb']['user'] = monitoring_secret.data[:data][:MONITOR_DB_USER]
    node.override['grafana']['user'] = monitoring_secret.data[:data][:GRAFANA_ADMIN_USER]
    node.override['grafana']['pwd'] = monitoring_secret.data[:data][:GRAFANA_ADMIN_PWD]
    node.override['smtp']['user'] = monitoring_secret.data[:data][:SMTP_USER]
    node.override['smtp']['pwd'] = monitoring_secret.data[:data][:SMTP_PWD]
    node.override['smtp']['host'] = monitoring_secret.data[:data][:SMTP_HOST]
    node.override['smtp']['port'] = monitoring_secret.data[:data][:SMTP_PORT]
    node.override['smtp']['from'] = monitoring_secret.data[:data][:SMTP_FROM]
    node.override['smtp']['to'] = monitoring_secret.data[:data][:SMTP_TO]
    node.override['smtp']['identity'] = monitoring_secret.data[:data][:SMTP_IDENTITY]
  end
end
