# Monitoring Cookbook (Prometheus + Grafana Stack)

This Chef cookbook deploys an on-prem monitoring stack consisting of Prometheus, Alertmanager, Grafana, and common exporters (node-exporter, blackbox-exporter, cAdvisor, and postgres-exporter). It is designed to be reusable and safe for public distribution.

## Status

This cookbook is provided as a reusable reference implementation for deploying an on-prem Prometheus + Grafana monitoring stack.

It has been validated in a lab setup and is continuously improved. Depending on your environment (OS packages, firewall rules, Docker setup, SMTP/Vault configuration), you may need small adjustments. Please open an issue or submit a PR if you hit a compatibility problem.

## Architecture overview

The cookbook provisions:

- **Prometheus** (metrics collection)
- **Alertmanager** (alert routing)
- **Grafana** (dashboards)
- **Exporters**: node-exporter, blackbox-exporter, cAdvisor, postgres-exporter
- **Docker** runtime with containers on the host network

Configuration files and dashboards are rendered into a configurable base directory and mounted into containers.

## Supported OS

- Ubuntu 20.04 (primary)
- CentOS 7 (secondary)

## Deployment workflows

### A) Recommended (Policyfile, local-mode)

Use Policyfiles for reproducible deployments:

```bash
chef install Policyfile_MONITORING.rb
chef-client -z -P Policyfile_MONITORING.rb
```

This pins cookbook dependencies via `Policyfile.lock.json`.

### B) Quick demo (runlist, local-mode)

```bash
chef-client --local-mode --runlist 'recipe[monitoring::main]'
```

This does not pin dependencies like Policyfiles.

### C) Testing (Test Kitchen, optional)

Test Kitchen is intended for converge/verify testing and can target static hosts if configured.

Example commands:

```bash
kitchen list
kitchen converge monitoring-ubuntu
kitchen verify monitoring-ubuntu
```

`kitchen converge` is used to deploy to the configured (remote) hosts for the suite.

## Configuration knobs

### Base directory

All configuration and dashboard assets are stored under a configurable base directory:

- `node['monitoring']['base_dir']` (default: `/opt/monitoring`)
- `node['monitoring']['user']` / `node['monitoring']['group']` (default: `root`)

### Docker image registry

Public images are used by default. To override with a private registry:

- `node['docker']['registry_prefix']` (default: empty)
  - Example: `registry.example.com/monitoring` (no trailing slash required)
- `node['docker']['registry']` / `node['docker']['username']` / `node['docker']['key']` for optional registry login

### Images and tags

Each component has an image and tag attribute, for example:

- `node['prometheus']['image']` (default: `prom/prometheus`)
- `node['grafana']['image']` (default: `grafana/grafana`)
- `node['alertmanager']['image']` (default: `prom/alertmanager`)

### Ports

Ports are defined in each recipe (e.g., node-exporter on `9900`, postgres-exporter on `9187`, Grafana on `3000`). Adjust by editing the relevant recipe or adding attributes for your environment.

### SMTP (Alertmanager)

Alertmanager email settings are configurable via attributes:

- `node['smtp']['host']`
- `node['smtp']['port']`
- `node['smtp']['user']`
- `node['smtp']['pwd']`
- `node['smtp']['from']`
- `node['smtp']['to']`
- `node['smtp']['identity']`

If these are left empty, the rendered config uses placeholder values (safe for public repos).

### Vault (optional)

Vault integration is optional. When Vault attributes are empty, no reads occur and placeholders are used.

- `node['vault']['url']`
- `node['vault']['token']`
- `node['vault']['secret']`
- `node['vault']['monitoring']`

## Offline bundle

See `packages/README` for a simple process to build and store offline bundles of container images.

## Security notes

- This repo does **not** contain secrets. Populate credentials via attributes, environment variables, or Vault.
- Review rendered configs before use in production.
