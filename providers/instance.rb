#
# Cookbook Name:: stud
# Provider:: stud_instance
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

action :enable do

  action_create

  link "/opt/stud/configs-available/#{new_resource.config_name}.conf" do
    to "/opt/stud/configs-enabled/#{new_resource.config_name}.conf"
  end

end

def action_create

  if Chef::Config[:solo]
    databag = data_bag_item('stud', new_resource.config_name)
  else
    databag = Chef::EncryptedDataBagItem.load('stud', new_resource.config_name)
  end

  Chef::Log.warn new_resource

  if new_resource.respond_to?('pem')
    pemContents = new_resource.pem
  else

    unless new_resource.respond_to?('key')
      new_resource.key = databag['key']
    end

    unless new_resource.respond_to?('certificate')
      new_resource.certificate = databag['certificate']
    end

    pemContents = "#{new_resource.certificate}\n#{new_resource.key}"
  end

  file "/etc/stud/certs/#{new_resource.config_name}.pem" do
    owner 'root'
    group 'root'
    mode '0644'
    content pemContents
  end

  template "/etc/stud/configs-available/#{new_resource.config_name}.conf" do
    owner 'root'
    group 'root'
    mode '0644'
    source 'stud.conf.erb'
    variables({
      :source_port => new_resource.source_port,
      :destination_hostname => new_resource.destination_hostname,
      :destination_port => new_resource.destination_port
    })
  end

end