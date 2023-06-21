#!/bin/bash
docker run -d --name sde_bd -e POSTGRES_PASSWORD=@sde_password012 -e POSTGRES_USER=test_sde -e POSTGRES_DB=demo -p 6543:5432 -v /sde_test_db//sql//init_db://var//lib//pgsql//data postgres:14.2;
sleep 5;
docker exec sde_db psql -U test_sde -d demo -f //sde_test_db/sql/init_db/demo.sql;
