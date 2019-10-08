CREATE STREAM weird ( \
weird STRUCT< \
ts DOUBLE(14,4), \
"id.orig_h" VARCHAR, \
"id.orig_p" INTEGER, \
"id.resp_h" VARCHAR, \
"id.resp_p" INTEGER, \
name VARCHAR, \
notice BOOLEAN, \
peer STRING>)
WITH (KAFKA_TOPIC='weird', VALUE_FORMAT='JSON');