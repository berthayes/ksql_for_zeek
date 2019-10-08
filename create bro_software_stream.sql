CREATE STREAM software ( \
software STRUCT<
ts DOUBLE(16,6), \
host VARCHAR, \
software_type VARCHAR, \
name VARCHAR, \
"version.minor" INTEGER, \
"version.minor2" INTEGER, \
"version.minor3" INTEGER, \
unparsed_version VARCHAR>) \
WITH (KAFKA_TOPIC='software', VALUE_FORMAT='JSON');