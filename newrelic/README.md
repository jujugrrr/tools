# Tools

# Install gems dependencies

`bundle install`
## Delete old not reporting servers

`bundle exec ./delete_servers_not_reporting.rb MYAPI_KEY`

The script will check all the server and delete the one not reporting metrics
If you forget to give an API_KEY the script will failed

```
Invalid API key, API call returned : 401 Unauthorized
Usage : ./delete_servers_not_reporting.rb MY_API_KEY
```
