# Liquibase Seed
* Liquibase Installation instructions
* Update and verify DB details in liquibase.properties
* Migrate: ./migrate.sh 1.0 -m
* Rollback: ./migrate.sh 1.0 -r
* To generate changelogs : liquibase --driver=org.postgresql.Driver --changeLogFile=localdb.postgresql  --classpath=postgresql-9.4-1201-jdbc41.jar --url="jdbc:postgresql://localhost:5432/foo"  --username=bar --password= --defaultSchemaName=develop --classpath=/usr/local/opt/liquibase/lib/postgresql-42.2.15.jar generateChangeLog


Queries to reset DB:
SELECT * FROM databasechangelog;
DROP TABLE databasechangelog,databasechangeloglock;
DROP TABLE gym.students,gym.trainers;
DROP schema gym;