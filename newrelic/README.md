# NewRelic tools
You need to get your [NewRelic API key](https://docs.newrelic.com/docs/apm/apis/requirements/api-key)

## Install gems dependencies

`bundle install`

## Delete old not reporting servers

```
bundle exec ./delete_servers_not_reporting.rb MYAPI_KEY
checking autoscale-hgjhjkg
checking autoscale-ghjkghjk
checking autoscale-ghjkghkj
checking autoscale-ghjkghjkghjk
checking server1
checking server2
checking staging1
checking staging2
Deleting autoscale-hgjhjkg
Deleting autoscale-ghjkghjk
Deleting autoscale-ghjkghkj
Deleting autoscale-ghjkghjkghjk
```


The script will check all the servers and delete the ones not reporting metrics
If you forget to give an API_KEY, or if this one is not correct,  the script will failed.
```
Invalid API key, API call returned : 401 Unauthorized
Usage : ./delete_servers_not_reporting.rb MY_API_KEY
```
