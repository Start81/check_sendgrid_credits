#!/usr/bin/perl -w 
#===============================================================================
# Script Name   : check_sendgrid_credits.pl
# Usage Syntax  : check_sendgrid_credits.pl [-v] -K <API-KEY> [-w  <warning> -c <critical>]
# Author        : Start81
# Version       : 2.0.0
# Last Modified : 14/11/2023
# Modified By   : JULEN DESAREST Start81 
# Description   : check sendgrid remaining credit
# Depends On    : REST::Client,Data::Dumper,Getopt::Long
#
# Changelog:
#    Legend:
#       [*] Informational, [!] Bugix, [+] Added, [-] Removed
#
# - 05/03/2021 | 1.0.0 | [*] initial realease
# - 26/01/2023 | 1.0.1 | [*] Reviewing
# - 14/11/2023 | 2.0.0 | [*] Reviewing
#===============================================================================
use strict;
use warnings;
use REST::Client;
use warnings;
use Data::Dumper;
use JSON;
use Getopt::Long;
use Readonly;
use File::Basename;
use Monitoring::Plugin;
my $msg;
my $o_verb;

Readonly our $VERSION => '2.0.0';
sub verb { my $t=shift; print $t,"\n" if ($o_verb) ; return 0}
my $me = basename($0);
my $np = Monitoring::Plugin->new(
    usage => "Usage: %s   [-v] -K <API-KEY> [-w  <warning> -c <critical>] \n",
    plugin => $me,
    shortname => " ",
    blurb => "$me is a Nagios check for sendgrid remaining credit",
    version => $VERSION,
    timeout => 30
);
#-K, --Key=<API-KEY>
$np->add_arg(
    spec => 'Key|K=s',
    help => "-K, --Key=STRING\n"
          . ' API-KEY for webservice authentication ',
    required => 1
);
$np->add_arg(
    spec => 'warning|w=s',
    help => "-w, --warning=threshold\n" 
          . '   See https://www.monitoring-plugins.org/doc/guidelines.html#THRESHOLDFORMAT for the threshold format.',
);
$np->add_arg(
    spec => 'critical|c=s',
    help => "-c, --critical=threshold\n"  
          . '   See https://www.monitoring-plugins.org/doc/guidelines.html#THRESHOLDFORMAT for the threshold format.',
);

#Check parameter
$np->getopts;
my $o_warning = $np->opts->warning;
my $o_critical = $np->opts->critical;
my $o_token =  $np->opts->Key;
$o_verb = $np->opts->verbose if (defined $np->opts->verbose);

#Init Rest Client
my $client = REST::Client->new();
$client->setTimeout(30);
my $url = "https://api.sendgrid.com/v3/user/credits";
verb($url);
$client->addHeader('Content-Type', 'application/json;charset=utf8');
$client->addHeader('Accept', 'application/json');
$client->addHeader('Authorization','Bearer ' . $o_token);
$client->addHeader('Accept-Encoding',"gzip, deflate, br");
#Get Credits informations
$client->GET($url);
if( $client->responseCode() ne '200'){
    print "UNKNOWN response code : " . $client->responseCode() . " Error when executing query\n"; 
    $msg = $client->{_res}->decoded_content;
    $np->plugin_exit('UNKNOWN',$msg);
}
my $rep = $client->{_res}->decoded_content;
my $response_json = from_json($rep);
verb(Dumper($response_json));
my $total = int($response_json->{'total'});
if ($total > 0) {
    #Get % usage
    my $usage_lvl = (int($response_json->{'used'}*100)/int($total)); 
    $msg = "credits used " . substr($usage_lvl,0,5) . "%";
    $np->add_perfdata(label => "Usage", value => substr($usage_lvl,0,5),uom => '%', warning => $o_warning, critical => $o_critical);
    if (defined($o_warning) && defined($o_critical)) {
        $np->set_thresholds(warning => $o_warning, critical => $o_critical);
        my $status = $np->check_threshold($usage_lvl);
        $np->plugin_exit('CRITICAL',$msg) if ($status==2);
        $np->plugin_exit('WARNING',$msg) if ($status==1);
        $np->plugin_exit('OK',$msg); 
    } else {
        $np->plugin_exit('OK',$msg);
    }
} else {
    $msg = "UNKNOWN Total credit = 0";
    $np->plugin_exit('UNKNOWN',$msg);
}
