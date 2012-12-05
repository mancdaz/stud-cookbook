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
package 'libev-dev'
package 'libssl-dev'

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

directory '/etc/stud/configs-available' do
  mode '0755'
  owner 'root'
  group 'root'
end

directory '/etc/stud/configs-enabled' do
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

git '/opt/stud/build' do
  repository 'https://github.com/bumptech/stud.git'
  reference 'master'
  action :sync
end

bash "build stud" do
  cwd '/opt/stud/build'
  code <<-EOH
    make
    make install
    mv stud /opt/stud/
  EOH
end

template '/etc/init/stud.conf' do
  mode '0644'
  source 'init/stud.conf.erb'
end

stud_instance 'test' do
  source_port 4043
  destination_port 4040
end
