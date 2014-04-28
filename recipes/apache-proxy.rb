#
# Cookbook Name:: artifactory
# Recipe:: apache-proxy
#
# Copyright (C) 2013 Fewbytes
# 
# Apache V2

include_recipe "artifactory"
include_recipe "apache2"
include_recipe "apache2::mod_proxy_http"
include_recipe "apache2::mod_ssl" if node['artifactory']['use_ssl']

host_name = node['artifactory']['host_name'] || node['fqdn']

if node['artifactory']['use_ssl']
  cookbook_file "#{node['apache']['dir']}/ssl/#{node['artifactory']['cert_name']}.crt" do
    cookbook node['artifactory']['cert_cookbook']
    source "certs/#{node['artifactory']['cert_name']}.crt"
    notifies :restart, "service[apache2]"
  end

  cookbook_file "#{node['apache']['dir']}/ssl/#{node['artifactory']['cert_name']}.key" do
    cookbook node['artifactory']['cert_cookbook']
    source "certs/#{node['artifactory']['cert_name']}.key"
    notifies :restart, "service[apache2]"
  end

  cookbook_file "#{node['apache']['dir']}/ssl/#{node['artifactory']['cert_ca_name']}.crt" do
    cookbook node['artifactory']['cert_cookbook']
    source "certs/#{node['artifactory']['cert_ca_name']}.crt"
    not_if { node['artifactory']['cert_ca_name'].nil? }
    notifies :restart, "service[apache2]"
  end
end

template "#{node['apache']['dir']}/sites-available/artifactory" do
	source "apache-artifactory-vhost.conf.erb"
	owner       'root'
	group       'root'
	mode        '0644'
	variables(
	:host_name        => host_name
	)
	
	if File.exists?("#{node['apache']['dir']}/sites-enabled/artifactory")
		notifies  :restart, 'service[apache2]'
	end
end

apache_site "artifactory" do
	enable true
end
