## check_sendgrid_credits

Monitor sendgrid remaining credit 

### prerequisites

This script uses theses libs : REST::Client, Data::Dumper,JSON, Monitoring::Plugin, File::Basename, Readonly

to install them type :

```
sudo cpan  REST::Client Data::Dumper JSON File::Basename Readonly  Monitoring::Plugin
```

You need an API Key with user.credits.read right only
To create this API key you must use an admin API key with the following curl command : 


```shell
curl --location --request POST 'https://api.sendgrid.com/v3/api_keys' \
--header 'Authorization: Bearer SG.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' \
--header 'Content-Type: application/json' \
--data-raw '{
  "name": "KeyMonitorCredits",
  "scopes": ["user.credits.read"]
}'    
```

  you may get:

```json
{
    "api_key": "SG.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    "api_key_id": "261mXSYzTZW5k2L6cmxN_g",
    "name": "KeyMonitorCredits",
    "scopes": [
        "user.credits.read"
    ]
}
```

### Use case 


```bash
check_sendgrid_credits.pl 2.0.0

This nagios plugin is free software, and comes with ABSOLUTELY NO WARRANTY.
It may be used, redistributed and/or modified under the terms of the GNU
General Public Licence (see http://www.fsf.org/licensing/licenses/gpl.txt).

check_sendgrid_credits.pl is a Nagios check for sendgrid remaining credit

Usage: check_sendgrid_credits.pl   [-v] -K <API-KEY> [-w  <warning> -c <critical>]

 -?, --usage
   Print usage information
 -h, --help
   Print detailed help screen
 -V, --version
   Print version information
 --extra-opts=[section][@file]
   Read options from an ini file. See https://www.monitoring-plugins.org/doc/extra-opts.html
   for usage and examples.
 -K, --Key=STRING
 API-KEY for webservice authentication
 -w, --warning=threshold
   See https://www.monitoring-plugins.org/doc/guidelines.html#THRESHOLDFORMAT for the threshold format.
 -c, --critical=threshold
   See https://www.monitoring-plugins.org/doc/guidelines.html#THRESHOLDFORMAT for the threshold format.
 -t, --timeout=INTEGER
   Seconds before plugin times out (default: 30)
 -v, --verbose
   Show details for command-line debugging (can repeat up to 3 times)
```

Sample to get credit usage:

```bash
./check_sendgrid_credits.pl -K "SG.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" -w 80 -c 90
```

you may get :

```bash
 OK - credits used 14.18% | Usage=14.18%;80;90
```

