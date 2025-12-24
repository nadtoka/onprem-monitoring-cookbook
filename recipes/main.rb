#
# Cookbook:: monitoring
# Recipe:: default
#
# Copyright:: 2024, ExampleCorp

# include_recipe 'customization::default'
include_recipe '::docker'
include_recipe '::hosts'
include_recipe '::templates'
include_recipe '::prometheus'
include_recipe '::blackbox'
include_recipe '::alertmng'
include_recipe '::grafana'
