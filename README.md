# KSQL for Zeek
### How I'm currently sending Zeek IDS data directly Apache Kafka and running KSQL queries on it


### Configure Bro
1. Download Bro
https://www.zeek.org/downloads/bro-2.6.4.tar.gz
* Note: Zeek 3.0 will probably work - not tested yet
* Bert is not an early adopter

1. Compile Bro from source
* https://docs.zeek.org/en/stable/install/install.html
* might not be absolutely necessary as long as you HAVE the source for the version you're using
* E.g. if using Deb/RPM, make sure you also have the source package


1. Download Apache Metron plugin
* https://github.com/apache/metron-bro-plugin-kafka
* Follow directions on readme to install plugin


1. Edit $BRO_DIR/share/bro/site/local.bro
(.e.g. /usr/local/bro/share/bro/site/local.bro)

Add/edit the following lines (json might be in there already):
```
@load policy/tuning/json-logs
@load send-to-kafka
```

json-logs ensures JSON formatting of data
send-to-kafka is your config file for sending data to Kafka.


1. Create this file for Kafka logging - e.g. /usr/local/bro/share/bro/site/send-to-kafka.bro
* see https://github.com/berthayes/ksql_for_zeek/blob/master/send-to-kafka.bro


1. For each log type in Bro/Zeek, create a topic in Kafka
e.g, DNS, HTTP, SSL, etc.

1. After topics are created and log file editing is done, reload/restart Bro/Zeek with
``` #broctl deploy ```

1. Make sure you're getting events in Kafka

### Create a stream with a KSQL query
Note that the event is nested JSON, so you need to use STRUCT to create the event value
* see https://github.com/berthayes/ksql_for_zeek/blob/master/create_bro_dns_stream.sql

Now you can query the stream with KSQL

```
ksql> SELECT DNS->"id.orig_h", DNS->"query", DNS->QTYPE_NAME, DNS->"id.resp_h", DNS->"id.resp_p" FROM DNS;
192.168.1.9 | ftp-chi.osuosl.org | A | 1.1.1.1 | 53
192.168.1.9 | _http._tcp.security.debian.org | SRV | 1.1.1.1 | 53
192.168.1.9 | _http._tcp.ftp.us.debian.org | SRV | 1.1.1.1 | 53
192.168.1.9 | prod.debian.map.fastly.net | A | 1.1.1.1 | 53
192.168.1.9 | prod.debian.map.fastly.net | AAAA | 1.1.1.1 | 53
192.168.1.9 | ftp-chi.osuosl.org | AAAA | 1.1.1.1 | 53
192.168.1.10 | api-8abd3fd5.duosecurity.com | A | 192.168.1.1 | 53
```

Because of the STRUCT required of nested JSON, we need to use the -> operator and because of the dots in some fields,
we need to put them in quotes.  Unsightly and problematic, because KSQL
has a hard time with dots in the field names if it's not in a STRUCT.

So let's create another stream that is a little prettier and easier to work with.
Perhaps this stream is formatted for your SIEM?
* see https://github.com/berthayes/ksql_for_zeek/blob/master/create_clean_dns_stream.sql

Now let's query the clean DNS stream
Here's an example - look for IPV6 hostname lookups:

```
ksql> SELECT SRC_IP, Q, QTYPE_NAME, DEST_IP, DEST_PORT, ANSWERS FROM CLEAN_DNS WHERE QTYPE_NAME='AAAA' AND ANSWERS IS NOT NULL;
192.168.1.9 | www.yelp.com | AAAA | 1.1.1.1 | 53 | [yelp-com.map.fastly.net]
192.168.1.9 | www.dailymail.co.uk | AAAA | 1.1.1.1 | 53 | [www.dailymail.co.uk-v1.edgekey.net, e4526.j.akamaiedge.net]
192.168.1.9 | facebook.com | AAAA | 1.1.1.1 | 53 | [2a03:2880:f134:183:face:b00c:0:25de]
192.168.1.9 | facebook.com | AAAA | 1.1.1.1 | 53 | [2a03:2880:f134:183:face:b00c:0:25de]
192.168.1.9 | www.facebook.com | AAAA | 1.1.1.1 | 53 | [star-mini.c10r.facebook.com, 2a03:2880:f134:183:face:b00c:0:25de]
192.168.1.9 | www.washingtonpost.com | AAAA | 1.1.1.1 | 53 | [50992.edgekey.net, e9631.j.akamaiedge.net]
192.168.1.9 | www.xnxx.com | AAAA | 1.1.1.1 | 53 | [xnxx.com]
```




