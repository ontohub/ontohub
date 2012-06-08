#!/usr/bin/perl -w

#use strict;

############################################################
#  modifybatchpurls.pl
#
#  David Wood (david.wood@talis.com)
#  January 2011
#
#  Script to modify PURLs in a PURLz v1.x server.  PURLs are described in
#  the same XML format used by sendbatchpurls.pl.
#
#  Copyright 2011 Talis Inc.  Licensed under the Apache License,
#  Version 2.0 (the "License"); you may not use this file except in compliance
#  with the License. You may obtain a copy of the License at
#  http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law
#  or agreed to in writing, software distributed under the License is distributed
#  on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
#  express or implied. See the License for the specific language governing
#  permissions and limitations under the License.
#
###########################################################
package PURLz;
use LWP::UserAgent;
use HTTP::Cookies;
use HTTP::Request::Common qw(GET PUT POST);
use URI::Escape;

###########################################
# Complete/modify these variables
my $server = 'localhost:8080';  # Hostname:Port
my $userid = 'admin';
my $passwd = 'password';
my $directory = "batch_files";
###########################################

my $authurl = "http://$server/admin/login/login-submit.bsh";
my $workurl = "http://$server/admin/purl";
my $cookiefile = 'lwpcookies.txt';
my $useoldfile = 0;

my $debug = 0;

# set up user agent with a cookie jar
my $res;
my $req;
my $ua = LWP::UserAgent->new();
my $cookie_jar = HTTP::Cookies->new(
  file     => $cookiefile,
  autosave => 1,
  ignore_discard => 1,
);
$ua->cookie_jar($cookie_jar);

print STDERR "no old cookie jar file, so asking for new authorization\n"
   if ($useoldfile && ! -e $cookiefile);

print STDERR "set up cookie jar\n";
unless ($useoldfile && -e $cookiefile) {
  # try the authorization call, saving the cookie
  $req = POST($authurl, [id       => $userid,
                        passwd   => $passwd,
                        referrer => '/docs/index.html',
  ]);
  print STDERR "make auth request\n";
  $res = $ua->request($req);
  print STDERR "save cookie jar file\n";
  $cookie_jar->save();
  print STDERR "auth cookies retrieved:\n", $cookie_jar->as_string(), "\n";
}
print STDERR "load cookie jar from the file\n";
$cookie_jar->load();
$ua->cookie_jar($cookie_jar);
print STDERR "cookies loaded for update: \n", $cookie_jar->as_string(), "\n";

# Open log file.
open LOG, ">purl_modifications.log" or die "Couldn't open log file: $!\n";


# Get the contents of each file in the directory.
my @files = <$directory/*> or die "ERROR: Can't open directory $directory for reading: $!\n";;
foreach my $file (@files) {

  # Get content from file
  local $/=undef;
  open FILE, $file or die "Couldn't open file $file: $!\n";
  binmode FILE;
  
  # parse PURLs from the file;
  my $xml = <FILE>;
  my @purls = split(/<\/purl>/, $xml);
  
  foreach my $purl (@purls) {

      # DBG
      print "$purl\n\n" if $debug;
      
      my $params;
      my ($purlid, $type, $maintainers, $target, $seelaso);
      if ( $purl =~ /<purl\s*id=\"(.*)\"\s*type=\"(.*)\">/s ) {
          $purlid = $1;
          $params .= "type=$2&maintainers=";
          if ( $purl =~ /<maintainers>(.*)<\/maintainers>/s ) {
            my $maints = $1;
            while ($maints =~ /<uid>(.*?)<\/uid>/g) {
              $params .= "$1,";
            }
            while ($maints =~ /<gid>(.*?)<\/gid>/g) {
              $params .= "$1,";
            }
          }
          $params .= "&";
          if ( $purl =~ /<target\s*url=\"(.*)\"\/>/ ) {
              $params .= "target=" . uri_escape($1) . "&";
          } elsif ( $purl =~ /<seealso\s*url=\"(.*)\"\/>/ ) {
              $params .= "seealso=" . uri_escape($1);
          }
          $params =~ s/,&/&/;
          $params =~ s/&$//;
        
      } else {
          # Regexp failed to match.  Either a bad XML entry or the tail end of the file.
          next;
      }
      
      # DBG
      if ( $debug ) { print STDERR "make update request\n"; }

      my $url = $workurl . $purlid . '?' . $params;
      my $response = $ua->request(PUT $url);

      if ( $debug ) {
          print $response->error_as_HTML unless $response->is_success;
      }

      # Report results.
      my $report = $response->as_string;
      if ( $report =~ m/Updated resource/ ) {
        print "$purlid OK\n";
        print LOG "$purlid OK\n";
      } else {
        print "\nERROR:  $purlid: $report\n\n";
        print LOG "\nERROR:  $purlid: $report\n\n";
      }
  }
  
  close FILE;
}

close(LOG);
