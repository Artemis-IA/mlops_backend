# MinIO Client

## Description

Le client MinIO est utilisé pour interagir avec le serveur MinIO, notamment pour le téléchargement de buckets et la gestion des objets.

## Configuration

### Définition du Service dans `docker-compose.yml`

```yaml
minio-client:
  container_name: minio-client
  build:
    context: ./minio-client
    dockerfile: Dockerfile
  env_file:
    - .env
  environment:
    - MINIO_ENDPOINT=${MINIO_API_URL}
    - MINIO_ROOT_USER=${MINIO_ROOT_USER}
    - MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD}
  ports:
    - "${MINIO_CLIENT_PORT}:${MINIO_CLIENT_PORT}"
  volumes:
    - ./label-studio/cors.json:/label-studio/cors.json
  networks:
    - shared-network
  depends_on:
    - minio
  restart: always
```

### Points Clés

- **Dépendance** : Dépend du service MinIO.
- **Volumes** : Monte le fichier `cors.json` pour la gestion des CORS.

### Dockerfile

Le `Dockerfile` dans le répertoire `minio-client` configure l'image du client MinIO.

#### Exemple de Dockerfile

```dockerfile
FROM python:3.9-slim

# Installer mc (MinIO Client)
RUN apt-get update && \
    apt-get install -y wget && \
    wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc && \
    chmod +x /usr/local/bin/mc

# Installer les dépendances Python
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copier les scripts
COPY bucket_upload.py /app/bucket_upload.py

# Définir le répertoire de travail
WORKDIR /app

# Entrypoint
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]
```

#### Exemple de `entrypoint.sh`

```bash
#!/bin/bash
set -e

# Configurer mc avec les informations d'environnement
mc alias set myminio ${MINIO_ENDPOINT} ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD}

# Exécuter le script Python
python bucket_upload.py
```

#### Exemple de `bucket_upload.py`

```python
import os
import json
from minio import Minio
from minio.error import S3Error

def upload_bucket_configuration():
    minio_endpoint = os.getenv('MINIO_ENDPOINT')
    access_key = os.getenv('MINIO_ROOT_USER')
    secret_key = os.getenv('MINIO_ROOT_PASSWORD')

    client = Minio(
        minio_endpoint,
        access_key=access_key,
        secret_key=secret_key,
        secure=False
    )

    # Charger la configuration CORS
    with open('cors.json') as f:
        cors_config = json.load(f)

    # Appliquer la configuration CORS au bucket
    client.set_bucket_cors('your-bucket-name', cors_config)

if __name__ == "__main__":
    try:
        upload_bucket_configuration()
        print("Configuration CORS appliquée avec succès.")
    except S3Error as e:
        print(f"Erreur lors de l'application de la configuration CORS : {e}")
```

### Utilisation

1. **Construction de l'Image Docker**

   ```bash
   docker-compose build minio-client
   ```

2. **Démarrage du Service**

   ```bash
   docker-compose up -d minio-client
   ```

3. **Exécution des Scripts**

   Le conteneur `minio-client` exécutera automatiquement le script `bucket_upload.py` lors du démarrage pour configurer les CORS.

### Sécurité

- **Mots de Passe Forts** : Utilisez des mots de passe complexes pour `MINIO_ROOT_USER` et `MINIO_ROOT_PASSWORD`.
- **Accès Restreint** : Limitez les permissions du client MinIO uniquement aux opérations nécessaires.

### Surveillance

Intégrez le client MinIO avec Prometheus pour surveiller les métriques d'interaction avec le serveur MinIO.

---
```