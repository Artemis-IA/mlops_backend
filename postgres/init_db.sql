-- init_db.sql

-- Création de l'utilisateur et de la base de données pour MLflow
CREATE USER mlflow_user WITH PASSWORD 'mlflow_password';
CREATE DATABASE mlflow_db;
GRANT ALL PRIVILEGES ON DATABASE mlflow_db TO mlflow_user;

-- Création de l'utilisateur et de la base de données pour Label Studio
CREATE USER labelstudio_user WITH PASSWORD 'labelstudio_password';
CREATE DATABASE labelstudio_db;
GRANT ALL PRIVILEGES ON DATABASE labelstudio_db TO labelstudio_user;
