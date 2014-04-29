#
# Cookbook Name:: artifactory
# Recipe:: default
#
# Copyright (C) 2013 Fewbytes
# 
# Apache V2
#
node.set["java"]["jdk_version"] = 7

include_recipe "java"
package "unzip"

user node["artifactory"]["user"] do
	home node["artifactory"]["home"]
end

directory node["artifactory"]["home"] do
	owner node["artifactory"]["user"]
	mode "0755"
end

directory node["artifactory"]["catalina_base"] do
	owner node["artifactory"]["user"]
	mode "0755"
end

%w(work temp).each do |tomcat_dir|
	directory ::File.join(node["artifactory"]["catalina_base"], tomcat_dir) do
		owner node["artifactory"]["user"]
		mode 00755
	end
end

directory node["artifactory"]["log_dir"] do
	owner node["artifactory"]["user"]
	mode "0755"
end	

ark "artifactory" do
	url node["artifactory"]["zip_url"]
	checksum node["artifactory"]["zip_checksum"]
	action :install
end

link ::File.join(node["artifactory"]["home"], "webapps") do
	to "/usr/local/artifactory/webapps"
end

link ::File.join(node["artifactory"]["catalina_base"], "logs") do
	to node["artifactory"]["log_dir"]
end

link ::File.join(node["artifactory"]["catalina_base"], "conf") do
	to "/usr/local/artifactory/tomcat/conf"
end

template "/usr/local/artifactory/tomcat/conf/server.xml" do
	mode 00644
  case node['artifactory']['init_style']
  when "runit"
    notifies :restart, "runit_service[artifactory]"
     else
    notifies :restart, "service[artifactory]"
  end
end

case node['artifactory']['init_style']
when "runit"
  include_recipe "runit"
  runit_service "artifactory"
else
  execute "/usr/local/artifactory/bin/installService.sh" do
    creates "/etc/init.d/artifactory"
  end

  service "artifactory"
end
