#
# Cookbook:: helloword
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
include_recipe "tomcat"
farm = node[:'java'][:env]
template "/opt/tomcat/bin/setenv.sh" do
  source "setenv.sh.erb"
  owner node[:'java'][:user]
  group node[:'java'][:group]
  mode "0440"
end

SSLCertificateFile="/opt/tomcat/certificate/certificate.crt"
SSLCertificateKeyFile="/opt/tomcat/certificate/certificate.key"

template "/opt/tomcat/conf/server.xml" do
  source "server.xml.erb"
  owner node[:'java'][:user]
  group node[:'java'][:group]
  mode "0440"
 variables(
    :SSLCertificateFile => SSLCertificateFile,
    :SSLCertificateKeyFile => SSLCertificateKeyFile
  )
end

cookbook_file certificate do
  source "certs/#{farm}/certificate.crt"
  source "certs/#{farm}/certificate.key"
  owner node[:'java'][:user]
  group node[:'java'][:group]
  mode "644"
  action :create
end

#stop tomcat in case it was running
service "tomcat" do
  action [:stop]
end

bash "deploy_war" do
  code <<-EOH
     rm -rf /opt/tomcat/webapps/
     cp -f node[:'java'][:path] /opt/tomcat/webapps/
     chown node[:'java'][:user]:node[:'java'][:group] /opt/tomcat/webapps/hello*
     EOH
end

service "tomcat" do
  action [:start]
end
