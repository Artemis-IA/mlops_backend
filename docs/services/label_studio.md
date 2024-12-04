# Label Studio

## Description

Label Studio est utilisé pour l'annotation de données, facilitant la création de datasets pour l'entraînement des modèles de machine learning.

## Configuration

### Définition du Service dans `docker-compose.yml`

```yaml
label-studio:
  container_name: label-studio
  build:
    context: ./label-studio
    dockerfile: Dockerfile
  env_file:
    - .env
  environment:
    - LABEL_STUDIO_PORT=${LABEL_STUDIO_PORT}
    - LABEL_STUDIO_BUCKET_ENDPOINT_URL=${LABEL_STUDIO_BUCKET_ENDPOINT_URL}
    - LABEL_STUDIO_BUCKET_ACCESS_KEY=${LABEL_STUDIO_BUCKET_ACCESS_KEY}
    - LABEL_STUDIO_BUCKET_SECRET_KEY=${LABEL_STUDIO_BUCKET_SECRET_KEY}
    - LABEL_STUDIO_ROOT_URL=/labelstudio/
    - DJANGO_CSRF_TRUSTED_ORIGINS=https://labelstudio.domaine.com
    - CSRF_COOKIE_SECURE=1
    - POSTGRE_HOST=${POSTGRE_HOST}
    - POSTGRE_PORT=${POSTGRE_PORT}
    - POSTGRE_USER=${POSTGRE_USER}
    - POSTGRE_PASSWORD=${POSTGRE_PASSWORD}
    - POSTGRE_DB=${POSTGRE_DB}
  ports:
    - "${LABEL_STUDIO_PORT}:${LABEL_STUDIO_PORT}"
  extra_hosts:
    - "host.docker.internal:host-gateway"
  volumes:
    - label-studio-data:/label-studio/data
    - ./label-studio/create_bucket.py:/label-studio/create_bucket.py
    - ./label-studio/cors.json:/label-studio/cors.json
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.labelstudio.rule=Host(`labelstudio.domaine.com`)"
    - "traefik.http.routers.labelstudio.entrypoints=websecure"
    - "traefik.http.routers.labelstudio.tls.certresolver=cloudflare"
    - "traefik.http.routers.labelstudio.middlewares=authelia@docker,secureHeaders@docker"
  networks:
    - shared-network
  restart: always
```

### Points Clés

- **Interface Web** : Accessible via `labelstudio.domaine.com`.
- **Intégration avec MinIO** : Utilise MinIO pour le stockage des artefacts.
- **Sécurité** : Configuration des en-têtes CSRF sécurisés et utilisation de Traefik pour TLS.
- **Volumes** : Les données et scripts sont persistés dans `label-studio-data` et montés depuis le répertoire local.

### Dockerfile

Le `Dockerfile` dans le répertoire `label-studio` configure l'image Label Studio.

#### Exemple de Dockerfile

```dockerfile
FROM python:3.9-slim

# Installer les dépendances
RUN apt-get update && \
    apt-get install -y build-essential && \
    pip install --no-cache-dir label-studio

# Copier les scripts et configurations
COPY entrypoint.sh /app/entrypoint.sh
COPY create_bucket.py /app/create_bucket.py
COPY cors.json /app/cors.json

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

# Créer le bucket S3 si nécessaire
python create_bucket.py

# Lancer Label Studio
label-studio start /label-studio/data --host 0.0.0.0 --port ${LABEL_STUDIO_PORT} --export-annotations
```

#### Exemple de `create_bucket.py`

```python
import os
from minio import Minio
from minio.error import S3Error

def create_bucket():
    minio_endpoint = os.getenv('LABEL_STUDIO_BUCKET_ENDPOINT_URL')
    access_key = os.getenv('LABEL_STUDIO_BUCKET_ACCESS_KEY')
    secret_key = os.getenv('LABEL_STUDIO_BUCKET_SECRET_KEY')

    client = Minio(
        minio_endpoint,
        access_key=access_key,
        secret_key=secret_key,
        secure=False
    )

    bucket_name = "labelstudio"

    if not client.bucket_exists(bucket_name):
        client.make_bucket(bucket_name)
        print(f"Bucket '{bucket_name}' créé avec succès.")
    else:
        print(f"Bucket '{bucket_name}' existe déjà.")

if __name__ == "__main__":
    try:
        create_bucket()
    except S3Error as e:
        print(f"Erreur lors de la création du bucket : {e}")
```

### Utilisation

1. **Construction de l'Image Docker**

   ```bash
   docker-compose build label-studio
   ```

2. **Démarrage du Service**

   ```bash
   docker-compose up -d label-studio
   ```

3. **Accéder à l'Interface Web**

   Ouvrez votre navigateur et naviguez vers [https://labelstudio.domaine.com](https://labelstudio.domaine.com).

### Sécurité

- **Mots de Passe Forts** : Utilisez des mots de passe complexes pour les accès MinIO.
- **CSRF Protection** : Configuration des en-têtes CSRF sécurisés pour protéger contre les attaques CSRF.
- **Chiffrement** : Activez le chiffrement des données au repos et en transit si nécessaire.

### Sauvegarde et Restauration

#### Sauvegarde

Les données Label Studio sont stockées dans le volume `label-studio-data`. Sauvegardez ce volume régulièrement.

```bash
docker run --rm \
  -v label-studio-data:/data \
  -v $(pwd)/backup:/backup \
  alpine tar czf /backup/label-studio-data.tar.gz /data
```

#### Restauration

Pour restaurer les données, utilisez la commande suivante :

```bash
docker run --rm \
  -v label-studio-data:/data \
  -v $(pwd)/backup:/backup \
  alpine tar xzf /backup/label-studio-data.tar.gz -C /data
```

### Monitoring

Intégrez Label Studio avec Prometheus pour surveiller les métriques de l'application. Configurez les exporters nécessaires dans `prometheus.yml`.

---
