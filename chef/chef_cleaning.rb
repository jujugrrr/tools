#!/usr/bin/ruby
#
#Copyright (c) 2014 Rackspace US, Inc.
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

KNIFE_FILE='~/.chef/knife.rb'
DRYRUN=true

#i.e "name2"=>
#        {"ip"=>"10.x.x.x",
#        "public_ip"=>"x.x.x.x",
#        "instance_id"=>"xxxxxx-xxxx-xxxx-xxxx-xxxx"},
#     "name"=>
#        {"ip"=>"10.x.x.x",
#         "public_ip"=>"x.x.x.x",
#         "instance_id"=>"xxxxxx-xxxx-xxxx-xxxx-xxxx"},
def cloud_server_list
    servers = `knife rackspace server list -c #{KNIFE_FILE}`.split(/\n/).map { |node| node.split}
    mynode = {}
    servers.shift
    servers.each do |node|
      mynode[node[0]] = { 'ip' => node[3], 'public_ip' => node[2], 'instance_name' => node[1] }
    end
    mynode
end

# return a hash of nodes not having run chef for the last hour
# i.e {"xxxxxx-xxxx-xxxx-xxxx-xxxx"=>{"ip"=>nil},
#  "xxxxxx-xxxx-xxxx-xxxx-xxxx"=>{"ip"=>nil},
#   "xxxxxx-xxxx-xxxx-xxxx-xxxx"=>{"ip"=>"8.8.8.8"}}
def chef_out_of_date_server_list(env='*')
    nodes = `knife status 'chef_environment:#{env}' -H -c #{KNIFE_FILE}`.split(/.\n/).map { |node| node.split(/, /)}
    mynode = {}
    nodes.each do |node|
        mynode[node[1]] = { 'ip' => node[3] }
    end
    mynode
end

def chef_out_of_date_server_list_production
    chef_out_of_date_server_list('production')
end

def chef_out_of_date_server_list_staging
    chef_out_of_date_server_list('staging')
end

# return a hash of chef_out_of_date_server_list less the one running in Cloud
def chef_to_be_removed(chef_server_list)
    servers_up = cloud_server_list
    chef_server_list.delete_if do |name,server|
        puts "Do not delete #{name}, it's up" if servers_up[name]
        !! servers_up[name]
    end
end

# test if we have to be carefull with this server (naming convention different from instance UUID)
def carefull_name?(name)
    not !! (name =~ /\w{8}-\w{4}-\w{4}-\w{4}-\w{12}/)
end

def prompt(*args)
    print(*args)
   gets
end

def delete_chef_node(name)
    puts "deleting #{name}"
    puts `knife node delete #{name} -c #{KNIFE_FILE} -y` unless DRYRUN
    puts `knife client delete #{name} -c #{KNIFE_FILE} -y` unless DRYRUN
end

def delete_chef_nodes(list)
    list.each do | name,properties |
        if carefull_name?(name)
            puts "About to delete #{name}"
            answer = prompt("Are you sure you want to delete this server? it looks like a real name (y/n): ").chomp
            puts "you answered #{answer}"
            if answer == "y"
                delete_chef_node(name)
            else
                puts "Skipping #{name}"
            end
        else
            delete_chef_node(name)
        end
    end
end

def main
    toremove = chef_to_be_removed(chef_out_of_date_server_list_staging)
    delete_chef_nodes(toremove)
end
main

