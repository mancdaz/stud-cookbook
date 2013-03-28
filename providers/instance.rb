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

  link "/etc/stud/configs-enabled/#{new_resource.config_name}.conf" do
    to "/etc/stud/configs-available/#{new_resource.config_name}.conf"
  end

end

def action_create

  
  Chef::Log.info "certificate domain is #{new_resource.certificate_domain}"
  Chef::Log.info "source_port is #{new_resource.source_port}"
  certificate_domain = new_resource.certificate_domain.sub(/\./, '')

  if Chef::Config[:solo]
    databag = data_bag_item('stud', certificate_domain)
  else
    databag = Chef::EncryptedDataBagItem.load('stud', certificate_domain)
  end

  if new_resource.pem
    pemContents = new_resource.pem

  elsif
    if new_resource.certificate
      pemContents = new_resource.certificate
    else
      pemContents = databag['certificate']
    end

    pemContents << "\n"

    if new_resource.key
      pemContents << new_resource.key
    else
      pemContents << databag['key']
    end

  else
    if new_resource.pemfile
      pemContents = File.read(new_resource.pemfile)
    end

  end

  file "/etc/stud/certs/#{certificate_domain}.pem" do
    owner 'root'
    group 'root'
    mode '0644'
    content pemContents
  end

  template "/etc/stud/conf.d/#{new_resource.config_name}.conf" do
    cookbook 'stud'
    owner 'root'
    group 'root'
    mode '0644'
    source 'stud.conf.erb'
    variables({
      :source_hostname => new_resource.source_hostname,
      :source_port => new_resource.source_port,
      :destination_hostname => new_resource.destination_hostname,
      :destination_hostname => new_resource.destination_hostname,
      :destination_port => new_resource.destination_port,
      :certificate_domain => certificate_domain
    })
  end

  new_resource.updated_by_last_action(true)

end
