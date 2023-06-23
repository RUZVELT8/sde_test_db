#!/bin/bash
docker run -d --name sde_db_2 -e POSTGRES_PASSWORD=@sde_password012 -e POSTGRES_USER=test_sde -e POSTGRES_DB=demo -p 6543:5432 -v C:/Users/AAbiev/sde_school_project/sde_test_db/sql/init_db:/var/lib/pgsql/data postgres:14.2;
sleep 5;
docker exec sde_db_2 psql -U test_sde -d demo -f //var/lib/pgsql/data/demo.sql;
