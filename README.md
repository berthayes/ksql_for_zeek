
Download Bro 2.6 
https://www.zeek.org/downloads/bro-2.6.4.tar.gz
	* Note Zeek 3.0 will probably work?
	* Bert is not an early adopter

Compiled Bro from source
	* might not be absolutely necessary as long as you HAVE the source for the version you're using
	* E.g. if using Deb/RPM, make sure you also have the source package


Download Apache Metron plugin
	* https://github.com/apache/metron-bro-plugin-kafka
	* Follow directions on readme to install plugin


Edit $BRO_DIR/share/bro/site/local.bro
(.e.g. /usr/local/bro/share/bro/site/local.bro)

Make sure JSON formatting for logs is turned on - check for this line in local.bro
@load policy/tuning/json-logs


Sending logs to Kafka topics is easier to manage if it's done in a separate file

Create a file for Kafka logging - e.g. /usr/local/bro/share/bro/site/send-to-kafka.bro
include this file in you local.bro as above
@load send-to-lab-kafka

For each log type in Bro/Zeek, create a topic in Kafka
e.g, DNS, HTTP, SSL, etc.

After topics are created and log file editing is done, reload/restart Bro/Zeek with
# broctl deploy

Make sure you're getting events in Kafka

Create a stream with a KSQL query
Note that the event is nested JSON, so you need to use STRUCT to create the event value
	* see create_bro_dns_stream.sql

Now you can query the stream with KSQL

ksql> SELECT DNS->"id.orig_h", DNS->"query", DNS->QTYPE_NAME, DNS->"id.resp_h", DNS->"id.resp_p" FROM DNS;
192.168.1.9 | ftp-chi.osuosl.org | A | 1.1.1.1 | 53
192.168.1.9 | _http._tcp.security.debian.org | SRV | 1.1.1.1 | 53
192.168.1.9 | _http._tcp.ftp.us.debian.org | SRV | 1.1.1.1 | 53
192.168.1.9 | prod.debian.map.fastly.net | A | 1.1.1.1 | 53
192.168.1.9 | prod.debian.map.fastly.net | AAAA | 1.1.1.1 | 53
192.168.1.9 | ftp-chi.osuosl.org | AAAA | 1.1.1.1 | 53
192.168.1.10 | api-8abd3fd5.duosecurity.com | A | 192.168.1.1 | 53

Because of the STRUCT required of nested JSON, we need to use the -> and because of the dots in some fields,
we need to put them in quotes.  Unsightly and problematic, because KSQL
has a hard time with dots in the field names if it's not in a STRUCT.

So let's create another stream that is a little prettier and easier to work with.
Perhaps this stream is formatted for your SIEM?
	* see create_clean_dns_stream.sql

Now let's query the clean DNS stream
Here's an example - look for IPV6 hostname lookups:

ksql> SELECT SRC_IP, Q, QTYPE_NAME, DEST_IP, DEST_PORT, ANSWERS FROM CLEAN_DNS WHERE QTYPE_NAME='AAAA' AND ANSWERS IS NOT NULL;
192.168.1.9 | www.yelp.com | AAAA | 1.1.1.1 | 53 | [yelp-com.map.fastly.net]
192.168.1.9 | www.dailymail.co.uk | AAAA | 1.1.1.1 | 53 | [www.dailymail.co.uk-v1.edgekey.net, e4526.j.akamaiedge.net]
192.168.1.9 | facebook.com | AAAA | 1.1.1.1 | 53 | [2a03:2880:f134:183:face:b00c:0:25de]
192.168.1.9 | facebook.com | AAAA | 1.1.1.1 | 53 | [2a03:2880:f134:183:face:b00c:0:25de]
192.168.1.9 | www.facebook.com | AAAA | 1.1.1.1 | 53 | [star-mini.c10r.facebook.com, 2a03:2880:f134:183:face:b00c:0:25de]
192.168.1.9 | www.washingtonpost.com | AAAA | 1.1.1.1 | 53 | [50992.edgekey.net, e9631.j.akamaiedge.net]
192.168.1.9 | www.xnxx.com | AAAA | 1.1.1.1 | 53 | [xnxx.com]





