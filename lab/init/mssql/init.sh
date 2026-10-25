#!/bin/bash
# Attend SQL Server, crée la base et le compte de la monétique, puis charge les données.
set -e
S="/opt/mssql-tools18/bin/sqlcmd -C -S sqlserver -U sa -P $MSSQL_SA_PASSWORD -b"
for i in $(seq 60); do $S -Q "SELECT 1" >/dev/null 2>&1 && break; sleep 3; done
$S -Q "IF DB_ID('teranga_monetique') IS NULL CREATE DATABASE teranga_monetique; IF SUSER_ID('teranga_mon') IS NULL CREATE LOGIN teranga_mon WITH PASSWORD = 'Teranga#Mon2026', CHECK_POLICY = OFF"
$S -d teranga_monetique -i /init/teranga_monetique.sql
$S -d teranga_monetique -Q "IF USER_ID('teranga_mon') IS NULL CREATE USER teranga_mon FOR LOGIN teranga_mon; ALTER ROLE db_datareader ADD MEMBER teranga_mon; ALTER ROLE db_datawriter ADD MEMBER teranga_mon; ALTER ROLE db_ddladmin ADD MEMBER teranga_mon; GRANT SHOWPLAN TO teranga_mon"
echo "SQL Server : base teranga_monetique prête."
