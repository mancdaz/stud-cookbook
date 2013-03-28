#
# Cookbook Name:: stud
# Recipe:: default
#
# Copyright (C) 2012 Lucas Jandrew
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include_recipe "build-essential"

platform_options = node["stud"]["platform"]

platform_options["stud_packages"].each do |pkg|
  package pkg do
    action :install
      options platform_options["package_overrides"]
  end
end

directory '/opt/stud/build' do
  mode '0755'
  owner 'root'
  group 'root'
  recursive true
end

directory '/etc/stud/certs' do
  mode '0755'
  owner 'root'
  group 'root'
  recursive true
end

directory '/etc/stud/conf.d' do
  mode '0755'
  owner 'root'
  group 'root'
end

user 'stud' do
  system true
end

group 'stud' do
  members ['stud']
  system true
end

###################################################
### NOTE:(mancdaz) until we get packaging sorted ##
git '/opt/stud/build' do
  repository 'https://github.com/bumptech/stud.git'
  reference 'master'
  action :sync
end

if node['platform'] == 'redhat'
  link '/usr/include/ev.h' do
    to '/usr/include/libev/ev.h'
  end
end

bash "build stud" do
  cwd '/opt/stud/build'
  code <<-EOH
    make
    make install
    mv stud /opt/stud/
  EOH
  not_if { ::File.exists?("/usr/local/bin/stud") }
end
###################################################

# upstart config file works on ubuntu and rhel
cookbook_file '/etc/init/stud.conf' do
  mode '0644'
  source 'stud-upstart.conf'
end

service 'stud' do
  case node[:platform]
  when 'ubuntu', 'redhat'
    provider Chef::Provider::Service::Upstart
  end
  action :enable
end


stud_instance "mything" do
    pemfile "/tmp/apemfile.pem"
    source_hostname = '127.0.0.1'
    source_port = '4000'
    destination_hostname = '127.0.0.1'
    destination_port = '22'
    certificate_domain = 'anameofadomain'
end
