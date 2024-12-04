# MinIO

## Description

MinIO est utilisé comme solution de stockage objet compatible avec S3, permettant de stocker les artefacts et autres fichiers.

## Configuration

### Définition du Service dans `docker-compose.yml`

```yaml
minio:
  container_name: minio
  image: minio/minio:latest
  env_file:
    - .env
  environment:
    - MINIO_ROOT_USER=${MINIO_ROOT_USER}
    - MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD}
    - MINIO_PORT=${MINIO_PORT}
    - MINIO_CONSOLE_PORT=${MINIO_CONSOLE_PORT}
    - MINIO_SERVER_URL=http://minio:${MINIO_PORT}
  command: server --address :${MINIO_PORT} --console-address :${MINIO_CONSOLE_PORT} /data
  ports:
    - "${MINIO_PORT}:${MINIO_PORT}"
    - "${MINIO_CONSOLE_PORT}:${MINIO_CONSOLE_PORT}"
  volumes:
    - minio-data:/data
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.minio.rule=Host(`minio.domaine.com`)"
    - "traefik.http.routers.minio.entrypoints=websecure"
    - "traefik.http.routers.minio.tls.certresolver=cloudflare"
    - "traefik.http.routers.minio.middlewares=authelia@docker,secureHeaders@docker"
  networks:
    - shared-network
  restart: always
```

### Points Clés

- **Interface Web** : Accessible via `minio.domaine.com`.
- **Sécurité** : Utilisation de Traefik pour gérer les certificats TLS via Cloudflare et des middlewares pour l'authentification et les en-têtes sécurisés.
- **Volumes** : Les données sont persistées dans `minio-data`.

### Utilisation

Pour interagir avec MinIO, vous pouvez utiliser le client MinIO ou des outils compatibles S3.

#### Accéder à l'Interface Web

Ouvrez votre navigateur et naviguez vers [https://minio.domaine.com](https://minio.domaine.com). Connectez-vous avec les identifiants définis dans le fichier `.env`.

#### Utiliser le Client MinIO

Le service `minio-client` est configuré pour interagir avec MinIO. Vous pouvez exécuter des commandes via ce conteneur pour gérer vos buckets et objets.

### Sécurité

- **Mots de Passe Forts** : Utilisez des mots de passe complexes pour `MINIO_ROOT_USER` et `MINIO_ROOT_PASSWORD`.
- **Chiffrement** : Activez le chiffrement des données au repos et en transit si nécessaire.
- **Contrôle d'Accès** : Configurez des politiques d'accès pour limiter les permissions aux utilisateurs et services.

### Sauvegarde et Restauration

#### Sauvegarde

Utilisez `mc` (MinIO Client) pour synchroniser les données vers un autre emplacement.

```bash
docker exec -it minio-client mc mirror minio/your-bucket /path/to/backup
```

#### Restauration

Pour restaurer les données, inversez la commande de synchronisation.

```bash
docker exec -it minio-client mc mirror /path/to/backup minio/your-bucket
```

### Monitoring

Intégrez MinIO avec Prometheus pour surveiller les métriques de stockage. Configurez les exporters nécessaires dans `prometheus.yml`.

---
