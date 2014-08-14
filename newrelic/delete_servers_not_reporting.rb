#!/usr/bin/env ruby
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

require 'json'
require 'curb'

API_KEY = ARGV[0]
DRY_RUN = false

def check_api_key
    response = Curl::Easy.perform("https://api.newrelic.com/v2/applications.json") do |curl|
      curl.headers["x-api-key"] = API_KEY
    end
    unless response.status == "200 OK"
       puts "Invalid API key, API call returned : #{response.status}"
       puts "Usage : #{$0} MY_API_KEY"
       exit
    end
end

def api_call_get(endpoint)
    response = Curl::Easy.perform("https://api.newrelic.com/v2/#{endpoint}") do |curl|
      curl.headers["x-api-key"] = API_KEY
    end
    JSON.parse(response.body_str)
end
def api_call_delete(endpoint)
    response = Curl.delete("https://api.newrelic.com/v2/#{endpoint}") do |curl|
      curl.headers["x-api-key"] = API_KEY
    end
    JSON.parse(response.body_str)
end
def servers_list
   api_call_get("servers.json")
end
def server_reporting?(server)
    puts "checking " + server['server']['name']
    if server['server']['reporting'] == false
        server['server']['reporting']
    else
        true
    end
end
def server_show(id)
    api_call_get("servers/#{id}.json")
end
def server_delete(id)
    api_call_delete("servers/#{id}.json")
end

def server_list_not_reporting
    servers = servers_list
    servers["servers"].delete_if do |serv|
        server_reporting?(server_show(serv["id"]))
    end
end
def server_list_reporting
    servers = servers_list
    servers["servers"].delete_if do |serv|
        not server_reporting?(server_show(serv["id"]))
    end
end
def delete_server_not_reporting
    server_list_not_reporting.each do |serv|
        puts "Deleting #{serv['name']}..."
        server_delete(serv['id']) unless DRY_RUN
    end
end

check_api_key
delete_server_not_reporting
