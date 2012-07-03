#
# Cookbook Name:: virtualbox
# Recipe:: default
#
# Copyright 2011, Joshua Timberman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'open-uri'

urlbase       = default['vbox']['urlbase']
major_version = default['vbox']['version']['major']
minor_version = default['vbox']['version']['minor']
release       = default['vbox']['version']['release']

case node['platform']
when "mac_os_x"
  version          = "#{major_version}.#{minor_version}-#{release}"
  filename         = "VirtualBox-#{version}-OSX.dmg"}
when "ubuntu","debian"
  version          = "#{major_version}_#{major_version}.#{minor_version}-#{release}"
  platform         = node['platform'].capitalize
  code_name        = node['lsb']['codename']
  arch             = (node['kernel']['machine'] = "x86_64") ? "amd64" : "i386"
  filename         = "virtualbox-#{version}~#{platform}~#{code_name}_#{arch}.deb"}
when "rhel","centos","fedora"
  version          = "#{major_version}-#{major_version}.#{minor_version}_#{release}"
  platform         = (node['platform'] = "centos") ? "rhel" : node['platform']
  platform_version = node['platform_version'].split(".")[0]
  arch             = node['kernel']['machine']
  filename         = "VirtualBox-#{version}_#{platform}#{platform_version}_1.#{arch}.rpm"}
end

url       = node['virtualbox']['url'].empty? ? "#{urlbase}/#{major_version}.#{minor_version}/#{filename}" : node['virtualbox']['url']
target    = "#{Chef::Config[:file_cache_path]}/#{filename}"
sha256sum = "" # retrieve the sha256sums from the virtualbox mirror
open("#{urlbase}/SHA256SUMS").each do |line|
  sha256sum = line.split(" ")[0] if line =~ /#{distfile}/
end

case node['platform']
when "mac_os_x"
  dmg_package "Virtualbox" do
    source url
    type "mpkg"
    checksum sha256sum
  end
when "ubuntu","debian"
  remote_file target do
    source url
    mode 0644
    checksum sha256sum
  end
  dpkg_package "virtualbox" do
    source target
  end
when "rhel","centos","fedora"
  remote_file target do
    source url
    mode 0644
    checksum sha256sum
  end
  rpm_package "virtualbox" do
    source target
  end
end

