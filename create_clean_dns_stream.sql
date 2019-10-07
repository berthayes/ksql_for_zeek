CREATE STREAM clean_dns AS \
SELECT DNS->ts AS ts,\
DNS->uid AS uid, \
DNS->"id.orig_h" AS src_ip, \
DNS->"id.orig_p" AS src_port, \
DNS->"id.resp_h" AS dest_ip, \
DNS->"id.resp_p" AS dest_port, \
DNS->proto AS proto, \
DNS->trans_id AS trans_id, \
DNS->"query" AS Q, \
DNS->qclass as qclass, \
DNS->qclass_name as qclass_name, \
DNS->qtype as qtype, \
DNS->qtype_name as qtype_name, \
DNS->rcode as rcode, \
DNS->rcode_name as rcode_name, \
DNS->AA as AA, \
DNS->TC as TC, \
DNS->RD as RD, \
DNS->Z as Z, \
DNS->answers as answers, \
DNS->TTLS as TTLS, \
DNS->rejected as rejected
from DNS;

