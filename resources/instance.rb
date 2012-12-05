#
# Cookbook Name:: stud
# Resource:: stud_instance
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

actions :create, :delete, :enable, :disable
default_action :create

def initialize(*args)
  super
  @action = :create
end

attribute :config_name, :name_attribute => true
attribute :enabled, :default => true
attribute :source_port
attribute :destination_hostname, :default => '127.0.0.1'
attribute :destination_port
attribute :key
attribute :certificate
attribute :pem
