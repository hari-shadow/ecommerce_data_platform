# Airbyte Connections

## Source: Neon Postgres
- Host: ep-icy-glade-aoek3rb2.c-2.ap-southeast-1.aws.neon.tech
- Database: neondb
- Replication Method: CDC (Logical Replication)
- Replication Slot: airbyte_slot
- Publication: airbyte_publication

## Destination: AWS S3
- Bucket: ecommerce-bronze-bucket
- Path: olist/
- Format: Parquet
- Region: ap-southeast-2

## Connection
- Name: neon-postgres-to-s3-bronze
- Schedule: Every 1 hour
- Sync Mode: Append Historical Changes