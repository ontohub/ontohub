Basically one can run any HTTP-Proxy infront (frontend) of the ruby rack
application server (like puma or webrick), which in turn provides access to
the ontohub web application. These notes provides some hints wrt. the frontends
we use or collected from other contributors.

Apache HTTPd configuration
--------------------------
Setup your apache httpd as usual. If in doubts or you don't reall know, what
a directive mentioned below does or how to activate a certain httpd module,
please consult your OS distro vendor's manual.

Set the document root to ontohub's "public" directory (e.g.
"DocumentRoot /local/home/ontohub/ontohub/public").

Make sure, that the rewrite module is activated, enable the rewrite engine
("RewriteEngine On"), and put the follwing two blocks before any proxy
directives:

	# Maintenance mode
	RewriteCond /data/git/maintenance.txt -f
	RewriteCond %{REQUEST_URI} !^/(cgi-bin|icons|apache|error|server-)/
	RewriteRule . /error/HTTP_SERVICE_UNAVAILABLE.html.var [R=503,L]

	# remove ending slash
	RewriteRule ^(.+)/$ /$1 [R=301,L]

	# If there is already a {js|css}.gz file, do not deflate the original but
	# use the pre-compressed one as is instead.
	RewriteCond %{HTTP:Accept-Encoding} gzip
	RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI}.gz -s
	RewriteRule ^(.*\.(js|css))$ $1.gz [E=no-gzip,QSA,L]

The first block just says, that if the file /data/git/maintenance.txt exists
and the URL path of the request does not start with the given aka
"not-used-by-ontohub-web-app" prefix, it answers with an service error status
and the content of the file associated with the given URL path in the
RewriteRule. Note that ontohub's git service uses a similar approach - it
doesn't accept any command as long as ${git.data_dir}/maintenance.txt exist.
The value for ${git.data_dir} can usually be found in config/settings.local.yml
or, if this doesn't exist, in config/settings.yml. So using the same file in
the first RewriteCond is recommended, makes the services behave consistent.

The second block is there for unknown/historical reasons and the 3rd block
as shown in the comments above to avoid double compression.

Now make sure, that the proxy and proxy_http module is activated and
enable the httpd proxy using directives like:

	# per contract requests with these prefixes are served by the httpd itself
	ProxyPassMatch ^/(cgi-bin|icons|apache|error|server-|assets|static) !

	# Per default the ruby rack application server listen on port 3000 of all
	# configured network interfaces
	ProxyPass / http://localhost:3000/

	ProxyRequests Off
	ProxyPreserveHost On

	<Proxy * >Require all granted</Proxy>

Finally, one could add on-the-fly compression support for certain file aka
mime types. For this make sure, that the deflate as well as the filter module
is activated, and than add the corresponding lines to the httpd config. E.g.:

	AddOutputFilterByType DEFLATE text/html text/plain text/xml
	AddOutputFilterByType DEFLATE text/css
	AddOutputFilterByType DEFLATE application/x-javascript application/javascript application/ecmascript
	AddOutputFilterByType DEFLATE application/rss+xml

That's it.
