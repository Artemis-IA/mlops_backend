# MLflow

## Description

MLflow est utilisé pour la gestion du cycle de vie des modèles de machine learning, incluant le suivi des expériences, la gestion des modèles et le déploiement.

## Configuration

### Définition du Service dans `docker-compose.yml`

```yaml
mlflow:
  container_name: mlflow
  build:
    context: ./mlflow
    dockerfile: Dockerfile
  env_file:
    - .env
  environment:
    - MLFLOW_BACKEND_STORE_URI=${MLFLOW_BACKEND_STORE_URI}
    - MLFLOW_ARTIFACT_ROOT=${MLFLOW_ARTIFACT_ROOT}
    - MLFLOW_S3_ENDPOINT_URL=${MLFLOW_S3_ENDPOINT_URL}
    - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
    - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
  ports:
    - "${MLFLOW_PORT}:${MLFLOW_PORT}"
  volumes:
    - ./mlflow:/mlflow
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.mlflow.rule=Host(`mlflow.domaine.com`)"
    - "traefik.http.routers.mlflow.entrypoints=websecure"
    - "traefik.http.routers.mlflow.tls.certresolver=cloudflare"
    - "traefik.http.routers.mlflow.middlewares=authelia@docker,secureHeaders@docker"
  networks:
    - shared-network
  restart: always
```

### Points Clés

- **Interface Web** : Accessible via `mlflow.domaine.com`.
- **Stockage des Artefacts** : Utilise MinIO comme backend de stockage compatible S3.
- **Sécurité** : Gestion des certificats TLS et des middlewares via Traefik.
- **Volumes** : Les données MLflow sont persistées dans `mlflow-data`.

### Dockerfile

Le `Dockerfile` dans le répertoire `mlflow` configure l'image MLflow.

#### Exemple de Dockerfile

```dockerfile
FROM python:3.9-slim

# Installer les dépendances
RUN apt-get update && \
    apt-get install -y build-essential && \
    pip install --no-cache-dir mlflow boto3

# Copier les scripts et configurations
COPY entrypoint.sh /app/entrypoint.sh
COPY create_bucket.py /app/create_bucket.py

# Définir le répertoire de travail
WORKDIR /app

# Entrypoint
RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]
```

#### Exemple de `entrypoint.sh`

```bash
#!/bin/bash
set -e

# Attendre que PostgreSQL soit prêt
./wait-for-it.sh postgre:5432 -- echo "PostgreSQL is up"

# Lancer MLflow
mlflow server \
  --backend-store-uri ${MLFLOW_BACKEND_STORE_URI} \
  --default-artifact-root ${MLFLOW_ARTIFACT_ROOT} \
  --host 0.0.0.0 \
  --port ${MLFLOW_PORT}
```

### Utilisation

1. **Construction de l'Image Docker**

   ```bash
   docker-compose build mlflow
   ```

2. **Démarrage du Service**

   ```bash
   docker-compose up -d mlflow
   ```

3. **Accéder à l'Interface Web**

   Ouvrez votre navigateur et naviguez vers [https://mlflow.domaine.com](https://mlflow.domaine.com).

### Sécurité

- **Mots de Passe Forts** : Utilisez des mots de passe complexes pour les accès AWS (MinIO).
- **Chiffrement** : Activez le chiffrement des données au repos et en transit si nécessaire.
- **Contrôle d'Accès** : Configurez des politiques d'accès pour limiter les permissions aux utilisateurs et services.

### Sauvegarde et Restauration

#### Sauvegarde

Les artefacts MLflow sont stockés dans MinIO. Utilisez le client MinIO pour sauvegarder les artefacts.

```bash
docker exec -it minio-client mc mirror minio/mlflow/artifacts /path/to/backup
```

#### Restauration

Pour restaurer les artefacts, utilisez la commande suivante :

```bash
docker exec -it minio-client mc mirror /path/to/backup minio/mlflow/artifacts
```

### Monitoring

Intégrez MLflow avec Prometheus pour surveiller les métriques de suivi des expériences et des modèles. Configurez les exporters nécessaires dans `prometheus.yml`.

---
