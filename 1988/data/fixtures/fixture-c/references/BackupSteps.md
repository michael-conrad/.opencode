# BackupSteps

Backup procedure for data persistence.

1. Stop the application service
2. Dump the database: `pg_dump -U admin mydb > backup.sql`
3. Compress the dump: `gzip backup.sql`
4. Copy to remote storage: `aws s3 cp backup.sql.gz s3://backups/`
5. Verify checksum: compare md5 of local and remote
6. Start the application service
7. Clean up local backup files older than 7 days
