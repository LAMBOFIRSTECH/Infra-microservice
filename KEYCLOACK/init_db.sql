--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE keycloak_service;
ALTER ROLE keycloak_service WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:i8b9gc8EveURzrr5kaTr7g==$Mj6OiUvoWBd3hR40m/BEiu/dRBXU0jQfJWW2cKGbY3Q=:dyPRLfdaJPA+hAEyZxCD6oSU/ogAaUGVA8YwrJu2xZI=';
CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:Mna30B1qw5tF+NQzVJkWyw==$lQhM9yA19YZfryfd7eZ7ihtS0iXtVGJs7Wh2NI540Ms=:mlg4Fg3ByjQG3Qc2VeFAariQIhxo0mlPfvq63dRIw/k=';

--
-- User Configurations
--

--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- PostgreSQL database dump complete
--

--
-- Database "keycloak_db" dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: keycloak_db; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE keycloak_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';
ALTER DATABASE keycloak_db OWNER TO postgres;

\connect keycloak_db

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

-- Création d'un schéma spécifique pour keycloak
CREATE SCHEMA keycloak_schema AUTHORIZATION keycloak_service;

-- Affectation du schéma par défaut pour keycloak_service :
ALTER ROLE keycloak_service SET search_path TO keycloak_schema, public;

--
-- Name: DATABASE keycloak_db; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON DATABASE keycloak_db TO keycloak_service;

--
-- Vault Admin Role + Permissions for Password Rotation
--

-- Création du compte utilisé par Vault
CREATE ROLE vault_admin;
ALTER ROLE vault_admin WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:afhiArRIg+IjNUmO0mmDGg==$NqV/Stu1h/vTbP7cJ7h22zw84zLHcvbveGzSsG8GQTY=:TLX4kuKGnwyhztVVy+Ct84x3sQufUvsBGScrMz2ylNY=';
GRANT CONNECT ON DATABASE keycloak_db TO vault_admin;

-- Donner à vaultadmin le droit de modifier keycloak_service
GRANT USAGE ON SCHEMA keycloak_schema TO vault_admin;
ALTER ROLE keycloak_service NOINHERIT;

-- Donner les droits de modification du mot de passe
GRANT keycloak_service TO vault_admin;
--
-- PostgreSQL database dump complete
--

--
-- Database "postgres" dump
--

\connect postgres

--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';

--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--
