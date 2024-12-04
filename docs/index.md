# Introduction

Bienvenue dans la documentation du **Backend MLOps du projet [Weavestruct](https://github.com/Artemis-IA/weavestruct)**  projet **MLOps**. Cette documentation fournit une vue d'ensemble complète de la configuration, des services, et des meilleures pratiques pour gérer et maintenir cette infrastructure Dockerisée.

## Table des Matières

- [Prérequis](prerequisites.md)
- [Structure du Projet](project_structure.md)
- [Configuration](configuration/env_files.md)
  - [Fichiers `.env`](configuration/env_files.md)
  - [Réseaux et Volumes Docker](configuration/networks_volumes.md)
- [Services](services/postgresql.md)
  - [PostgreSQL](services/postgresql.md)
  - [MinIO](services/minio.md)
  - [MinIO Client](services/minio_client.md)
  - [Neo4j](services/neo4j.md)
  - [MLflow](services/mlflow.md)
  - [Label Studio](services/label_studio.md)
  - [Prometheus](services/prometheus.md)
  - [Grafana](services/grafana.md)
- [Déploiement](deployment.md)
- [Sécurité](security.md)
- [Surveillance et Monitoring](monitoring.md)
- [Sauvegardes](backups.md)
- [Dépannage](troubleshooting.md)
- [Contribution](contribution.md)
- [Licence](license.md)