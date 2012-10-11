#!/usr/bin/perl -w

#use strict;

############################################################
#  sendbatchpurls.pl
#
#  David Wood (david@zepheira.com)
#  January 2010
#
#  Script to send PURLz v1.x batch loading XML files to a PURLz server.
#
#  Copyright 2010 Zepheira LLC.  Licensed under the Apache License,
#  Version 2.0 (the "License"); you may not use this file except in compliance
#  with the License. You may obtain a copy of the License at
#  http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law
#  or agreed to in writing, software distributed under the License is distributed
#  on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
#  express or implied. See the License for the specific language governing
#  permissions and limitations under the License.
#
###########################################################
use LWP::UserAgent;
use HTTP::Cookies;
use HTTP::Request::Common qw(GET PUT POST);

###############################
# CHANGE THESE VARS AS NEEDED #
###############################
my $server = 'localhost:8080';
my $userid = 'userid';
my $passwd = 'password';
my $authurl = "http://$server/admin/login/login-submit.bsh";
my $workurl = "http://$server/admin/purls";
my $cookiefile = 'lwpcookies.txt';
my $useoldfile = 0;
my $xml = "";
my $directory = "batch_files";

# set up user agent with a cookie jar
my $res;
my $req;
my $ua = LWP::UserAgent->new();
my $cookie_jar = HTTP::Cookies->new(
  file     => 'lwpcookies.txt',
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
open LOG, ">purl_creations.log" or die "Couldn't open log file: $!\n";


# Make a new request for each file in the directory.
@files = <$directory/*> or die "ERROR: Can't open directory $directory for reading: $!\n";;
foreach $file (@files) {

  # Get content from file
  local $/=undef;
  open FILE, $file or die "Couldn't open file $file: $!\n";
  binmode FILE;
  $xml = <FILE>;
  close FILE;

  # DBG
  if ( $debug ) { print STDERR "make update request\n"; }

  my $response = $ua->request(POST $workurl,
    Content_Type => 'text/xml',
    Content => $xml);

  #print $response->error_as_HTML unless $response->is_success;

  # Report results.
  my $report = $response->as_string;
  if ( $report =~ m/<purl-batch total=\"50\"/ ) {
    print "$file OK\n";
    print LOG "$file OK\n";
  } else {
    print "\nERROR:  $file: $report\n\n";
    print LOG "\nERROR:  $file: $report\n\n";
  }
}

close(LOG);
