## /etc/varnish/default.vcl / 20150504
## Marianne Spiller <github@spiller.me>
## v 3.0.5-2

backend default {
  .host = "127.0.0.1";
  .port = "8080";
  .connect_timeout = 600s;
  .first_byte_timeout = 600s;
  .between_bytes_timeout = 600s;
  .max_connections = 800;
 }

# Import Varnish Standard Module so I can serve custom error pages
import std;

# Set who is allowed to purge
acl purge {
  "localhost";
  "127.0.0.1";
  "92.222.22.102";
}

#----------------------------------------------------------------------
# vcl_recv
#
sub vcl_recv {
  # Ignore all "POST" requests - nothing cacheable there
   if (req.request == "POST") {
      return (pass);
  }

  # In the event of a backend overload (HA!), serve stale objects for up to two minutes
  set req.grace = 2m;

  #--------------------------------------------------------------------
  # Ignore these hosts
  # Great when I'm working on the blog
  ##
  ##	 if (req.http.host ~ "spiller.me") {
  ##	    return(pass);
  ##	  }
  ##	
  ##	  if (req.http.host ~ "www.spiller.me") {
  ##	    return(pass);
  ##	  }

  # No caching of the Wordpress "preview" sites
  if (req.url ~ "preview=true") {
	return(pass);
  }

  # Use the "purge" ACL we set earlier to allow purging from the LAN
  if (req.request == "PURGE") {
	if (!client.ip ~ purge) {
		error 405 "Not allowed.";
	}
	return (lookup);
  }

  # Static Elements should always go to the cache...
  if (req.url ~ "(?i)\.(png|gif|jpeg|jpg|ico|swf|css|js|html|htm|woff|ttf|eot|svg)(\?[a-zA-Z0-9\=\.\-]+)?$") {
	remove req.http.Cookie;
  }

  # I throw away *all* cookies from *both* Wordpress installations - except wp-admin
  if (req.http.host ~ "www.spiller.me|www.urban-exploring.eu") {
	if (req.url ~ "wp-(login|admin)") {
            return (pass);
	}

	  # Tell Varnish to use X-Forwarded-For, to set "real" IP addresses on all requests
	remove req.http.X-Forwarded-For;
	set req.http.X-Forwarded-For = req.http.rlnclientipaddr;
    }
}

#----------------------------------------------------------------------
# vcl_pass
#
sub vcl_pass {  
  set bereq.http.connection = "close";
  if (req.http.X-Forwarded-For) {
	set bereq.http.X-Forwarded-For = req.http.X-Forwarded-For;
  }
  else {
	set bereq.http.X-Forwarded-For = regsub(client.ip, ":.*", "");
  }
}

#----------------------------------------------------------------------
# vcl_pipe
#
sub vcl_pipe {  
  set bereq.http.connection = "close";
  if (req.http.X-Forwarded-For) {
	set bereq.http.X-Forwarded-For = req.http.X-Forwarded-For;
  }
  else {
	set bereq.http.X-Forwarded-For = regsub(client.ip, ":.*", "");
  }
}

#----------------------------------------------------------------------
# vcl_pipe
#
sub vcl_fetch {  
  set beresp.grace = 2m;
  if (req.http.host ~ "www.spiller.me") {
	if (!(req.url ~ "wp-(login|admin)")) {
	  remove beresp.http.set-cookie;
        }
  }

  # Strip cookies before static items are inserted into cache.
  if (req.url ~ "\.(png|gif|jpg|swf|css|js|ico|html|htm|woff|eof|ttf|svg)$") {
	remove beresp.http.set-cookie;
  }

  # Adjusting caching:
  # - cacheable objects stay for 24 hours
  # - objects declared as uncacheable stay for 60 seconds
  # - exception for the photo blog: its content stays for 5 days
  if (req.http.host ~ "www.urban-exploring.eu") {
	set beresp.ttl = 5d;
  }
  else {
	if (beresp.ttl < 24h) {
	  if (beresp.http.Cache-Control ~ "(private|no-cache|no-store)") {
	    set beresp.ttl = 60s;
	  }
	  else {
	    set beresp.ttl = 24h;
	  }
	}
  }
}


#----------------------------------------------------------------------
# vcl_hit
#
sub vcl_hit {  
  if (req.request == "PURGE") {
	purge;
	error 200 "Purged.";
  }
}

#----------------------------------------------------------------------
# vcl_miss
#
sub vcl_miss {  
  if (req.request == "PURGE") {
	purge;
	error 200 "Purged.";
  }
}

#----------------------------------------------------------------------
# vcl_error
#
sub vcl_error {  
  set obj.http.Content-Type = "text/html; charset=utf-8";
  set obj.http.MyError = std.fileread("/var/www/spillerme/varnisherr.html");
  synthetic obj.http.MyError;
  return(deliver);
}

#----------------------------------------------------------------------
# vcl_deliver
#
sub vcl_deliver {  
  # Display hit/miss info
  if (obj.hits > 0) {
	set resp.http.X-Cache = "HIT";
  }
  else {
	set resp.http.X-Cache = "MISS";
  }

  # Remove the Varnish header
  remove resp.http.X-Varnish;

  # Display my header
  set resp.http.X-sysadmama-is-awesome = "YAY";

  # Remove custom error header
  remove resp.http.MyError;
  return (deliver);
}
