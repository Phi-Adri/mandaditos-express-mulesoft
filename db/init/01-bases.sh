#!/bin/bash
# MDX-001: una base de datos por System API, cada una con su propio usuario.
# Corre una sola vez: cuando el contenedor arranca con el volumen vacío.
# Las claves llegan como variables de entorno (docker-compose.yml las toma del archivo .env).
# Las tablas NO van aquí: las crea la historia que crea el proyecto de cada API.
set -e

crear_base() {   # $1 = nombre de la base, $2 = clave de su usuario
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-SQL
    CREATE USER $1_sapi WITH PASSWORD '$2';
    CREATE DATABASE $1 OWNER $1_sapi;
    REVOKE CONNECT ON DATABASE $1 FROM PUBLIC;   -- nadie más puede entrar a esta base
SQL
}

crear_base clientes  "$CLIENTES_SAPI_PASSWORD"
crear_base tiendas   "$TIENDAS_SAPI_PASSWORD"
crear_base catalogo  "$CATALOGO_SAPI_PASSWORD"
crear_base pedidos   "$PEDIDOS_SAPI_PASSWORD"
crear_base pagos     "$PAGOS_SAPI_PASSWORD"
crear_base logistica "$LOGISTICA_SAPI_PASSWORD"
