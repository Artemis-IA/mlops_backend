# Fichiers `.env`

Le fichier `.env` contient les variables d'environnement nécessaires à la configuration des services Docker. Un exemple de fichier `.env` est fourni dans `.env.example`. Assurez-vous de copier ce fichier et de définir les valeurs appropriées avant de lancer les services.

## Copier le Fichier `.env`

```bash
cp .env.example .env
```

## Variables d'Environnement

### Exemple de `.env`

```env
# PostgreSQL
PG_MAJOR=16
POSTGRE_USER=your_username
POSTGRE_PASSWORD=your_password
POSTGRE_DB=your_database
POSTGRE_PORT=5432
POSTGRE_HOST=postgre

# MinIO
MINIO_ROOT_USER=your_minio_user
MINIO_ROOT_PASSWORD=your_minio_password
MINIO_PORT=9000
MINIO_CONSOLE_PORT=9001
MINIO_API_URL=http://minio:9000

# MLflow
MLFLOW_BACKEND_STORE_URI=postgresql://your_username:your_password@postgre:5432/your_database
MLFLOW_ARTIFACT_ROOT=s3://mlflow/artifacts
MLFLOW_S3_ENDPOINT_URL=http://minio:9000
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
MLFLOW_PORT=5000

# Label Studio
LABEL_STUDIO_PORT=8080
LABEL_STUDIO_BUCKET_ENDPOINT_URL=http://minio:9000
LABEL_STUDIO_BUCKET_ACCESS_KEY=your_minio_user
LABEL_STUDIO_BUCKET_SECRET_KEY=your_minio_password
POSTGRE_HOST=postgre
POSTGRE_PORT=5432
POSTGRE_USER=your_username
POSTGRE_PASSWORD=your_password
POSTGRE_DB=your_database
DJANGO_CSRF_TRUSTED_ORIGINS=https://labelstudio.domaine.com

# Neo4j
NEO4J_AUTH=neo4j/your_password

# Grafana
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=admin_password  # Changez ceci pour des raisons de sécurité

# Traefik (si applicable)
# Ajoutez ici vos variables Traefik si nécessaire
```

### Description des Variables

- **PostgreSQL** :
  - `PG_MAJOR` : Version majeure de PostgreSQL.
  - `POSTGRE_USER` : Nom d'utilisateur pour PostgreSQL.
  - `POSTGRE_PASSWORD` : Mot de passe pour PostgreSQL.
  - `POSTGRE_DB` : Nom de la base de données.
  - `POSTGRE_PORT` : Port sur lequel PostgreSQL écoute.

- **MinIO** :
  - `MINIO_ROOT_USER` : Nom d'utilisateur pour MinIO.
  - `MINIO_ROOT_PASSWORD` : Mot de passe pour MinIO.
  - `MINIO_PORT` : Port principal de MinIO.
  - `MINIO_CONSOLE_PORT` : Port pour l'interface console de MinIO.
  - `MINIO_API_URL` : URL de l'API MinIO.

- **MLflow** :
  - `MLFLOW_BACKEND_STORE_URI` : URI du backend store pour MLflow (PostgreSQL).
  - `MLFLOW_ARTIFACT_ROOT` : Chemin racine pour les artefacts MLflow.
  - `MLFLOW_S3_ENDPOINT_URL` : URL de l'endpoint S3 compatible avec MinIO.
  - `AWS_ACCESS_KEY_ID` : ID de clé d'accès AWS pour MinIO.
  - `AWS_SECRET_ACCESS_KEY` : Clé d'accès secrète AWS pour MinIO.
  - `MLFLOW_PORT` : Port sur lequel MLflow écoute.

- **Label Studio** :
  - `LABEL_STUDIO_PORT` : Port pour Label Studio.
  - `LABEL_STUDIO_BUCKET_ENDPOINT_URL` : URL de l'endpoint du bucket pour Label Studio.
  - `LABEL_STUDIO_BUCKET_ACCESS_KEY` : Clé d'accès pour le bucket.
  - `LABEL_STUDIO_BUCKET_SECRET_KEY` : Clé secrète pour le bucket.
  - `POSTGRE_*` : Variables de connexion à PostgreSQL.
  - `DJANGO_CSRF_TRUSTED_ORIGINS` : Origines fiables pour CSRF dans Django.

- **Neo4j** :
  - `NEO4J_AUTH` : Informations d'authentification pour Neo4j.

- **Grafana** :
  - `GF_SECURITY_ADMIN_USER` : Nom d'utilisateur admin pour Grafana.
  - `GF_SECURITY_ADMIN_PASSWORD` : Mot de passe admin pour Grafana (à modifier).

Assurez-vous de **ne pas versionner** votre fichier `.env` si vous utilisez un système de contrôle de version comme Git, afin de protéger vos informations sensibles.
```
