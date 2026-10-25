#!/bin/bash
# Charge la comptabilité de la Banque Téranga dans le schéma TERANGA_GL (créé par APP_USER).
sqlplus -s teranga_gl/TerangaGl2026@//localhost:1521/FREEPDB1 @/container-entrypoint-initdb.d/teranga_gl.sql
