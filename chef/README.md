# Tools
# Install gems dependencies

`bundle install`

# Requirement
The script is using your ~/.chef/knife.rb file by default, please change the KNIFE_FILE variable in the script according to the knife confioguration you want to use. By default DRYRUN is set to true, meaning it will not delete any node, change it to false if you really want the script to apply the changes.
## Delete old node/client from Chef server
The goal of this script is to clear old client/noes from Chef server

`bundle exec ./chef_cleaning.rb`

```
deleting 00d770df-350d-4982-8ddb-7e02a346fba1
Deleted node[00d770df-350d-4982-8ddb-7e02a346fba1]
Deleted client[00d770df-350d-4982-8ddb-7e02a346fba1]
deleting b0856901-bbf4-4603-b791-d3f401d44acb
About to delete xxx2
Are you sure you want to delete this server? it looks like a real name (y/n): n
you answered n
Skipping xxx2
deleting cc19568c-a5a0-41c8-b947-7247a0cd8076
Deleted node[cc19568c-a5a0-41c8-b947-7247a0cd8076]
Deleted client[cc19568c-a5a0-41c8-b947-7247a0cd8076]
About to delete xxx1
Are you sure you want to delete this server? it looks like a real name (y/n): y
you answered y
deleting xxx1
Deleted node[xxx1]
Deleted client[xxx1]
```

The script will get a list of servers where chef has not been run for a while(`knife status`) on staging by default, and a list of server fom rackspace cloud. It will try to match the instance UUID with the Chef node name. If your node name doesn't look like an instance UUID (it will probably fail to find a match) you will be prompted to confirm the deletation.


