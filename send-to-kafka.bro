@load packages/metron-bro-plugin-kafka

redef Kafka::topic_name = "";
redef Kafka::tag_json = T;

# ^^ setting the topic to nothing and
# adding a JSON tag to each event is necessary for sending to the correct topic
# also because the field names with a dot e.g. orig.ip_h are otherwise not 
# handled correctly
# This creates a STRUCT that we'll clean with a KSQL query later

# Kafka server info goes here
redef Kafka::kafka_conf = table(
        ["metadata.broker.list"] = "192.168.1.108:29092"
        );

event bro_init() 
{
    # handles HTTP
    local http_filter: Log::Filter = [
        $name = "kafka-http",
        $writer = Log::WRITER_KAFKAWRITER,
        $path = "http"
    ];
    Log::add_filter(HTTP::LOG, http_filter);

    # handles DNS
    local dns_filter: Log::Filter = [
        $name = "kafka-dns",
        $writer = Log::WRITER_KAFKAWRITER,
        $path = "dns"
    ];
    Log::add_filter(DNS::LOG, dns_filter);
    # handles CONN
    local conn_filter: Log::Filter = [
        $name = "kafka-conn",
        $writer = Log::WRITER_KAFKAWRITER,
        $path = "conn"
    ];
    Log::add_filter(Conn::LOG, conn_filter);

    # handles Files
    local files_filter: Log::Filter = [
        $name = "kafka-files",
        $writer = Log::WRITER_KAFKAWRITER,
        $path = "files"
    ];
    Log::add_filter(Files::LOG, files_filter);

    # Handles DHCP
    local dhcp_filter: Log::Filter = [
        $name = "kafka-dhcp",
        $writer = Log::WRITER_KAFKAWRITER,
        $path = "dhcp"
    ];
    Log::add_filter(DHCP::LOG, dhcp_filter);

    # handles software
    local software_filter: Log::Filter = [
        $name = "kafka-software",
        $writer = Log::WRITER_KAFKAWRITER,
        $path = "software"
    ];
    Log::add_filter(Software::LOG, software_filter);
    
    # handles weird
    local weird_filter: Log::Filter = [
        $name = "kafka-weird",
        $writer = Log::WRITER_KAFKAWRITER,
        $path = "weird"
    ];
    Log::add_filter(Weird::LOG, weird_filter);

    # handles x509
    local x509_filter: Log::Filter = [
        $name = "kafka-x509",
        $writer = Log::WRITER_KAFKAWRITER,
        $path = "x509"
    ];
    Log::add_filter(X509::LOG, x509_filter);

    # handles ssl
    local ssl_filter: Log::Filter = [
        $name = "kafka-ssl",
        $writer = Log::WRITER_KAFKAWRITER,
        $path = "ssl"
    ];
    Log::add_filter(SSL::LOG, ssl_filter);

    # handle known_services
    local known_services_filter: Log::Filter = [
	$name = "kafka-known-services",
	$writer = Log::WRITER_KAFKAWRITER,
	$path = "known_services"
    ];
    Log::add_filter(Known::SERVICES_LOG, known_services_filter);
}

