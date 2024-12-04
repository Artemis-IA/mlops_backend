# PostgreSQL

## Description

PostgreSQL est utilisé comme base de données relationnelle pour stocker les données de votre application.

## Configuration

### Définition du Service dans `docker-compose.yml`

```yaml
postgre:
  container_name: postgre
  build:
    context: ./postgre
    dockerfile: Dockerfile
    args:
      PG_MAJOR: ${PG_MAJOR}
  env_file:
    - .env
  environment:
    - POSTGRES_USER=${POSTGRE_USER}
    - POSTGRES_PASSWORD=${POSTGRE_PASSWORD}
    - POSTGRES_DB=${POSTGRE_DB}
  ports:
    - "${POSTGRE_PORT}:${POSTGRE_PORT}"
  volumes:
    - postgre-data:/var/lib/postgresql/data
  networks:
    - shared-network
  restart: always
```

### Points Clés

- **Volumes** : Les données sont persistées dans `postgre-data`.
- **Ports** : Par défaut, PostgreSQL utilise le port `5432`.
- **Variables d'Environnement** : Définies dans le fichier `.env`.

### Scripts d'Initialisation

Les scripts `init_db.pgsql.template` et `init_db.sql.template` sont utilisés pour initialiser la base de données lors du premier démarrage.

### Dockerfile

Le `Dockerfile` dans le répertoire `postgre` configure l'image PostgreSQL, y compris l'installation de `pgvector` via `install_pgvector.sh`.

#### Exemple de Dockerfile

```dockerfile
FROM postgres:${PG_MAJOR}

# Installation de pgvector
COPY install_pgvector.sh /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/install_pgvector.sh
```

#### Exemple de `install_pgvector.sh`

```bash
#!/bin/bash
set -e

# Installer les dépendances nécessaires
apt-get update
apt-get install -y postgresql-server-dev-all git build-essential

# Cloner et installer pgvector
git clone https://github.com/pgvector/pgvector.git
cd pgvector
make && make install

# Nettoyage
cd ..
rm -rf pgvector
apt-get remove -y git build-essential
apt-get autoremove -y
apt-get clean
```

### Utilisation

1. **Construction de l'Image Docker**

   ```bash
   docker-compose build postgre
   ```

2. **Démarrage du Service**

   ```bash
   docker-compose up -d postgre
   ```

3. **Vérification du Fonctionnement**

   Accédez à PostgreSQL via le port défini (par exemple, `5432`) et vérifiez les bases de données et les tables créées.

### Sécurité

- **Mots de Passe Forts** : Utilisez des mots de passe complexes pour `POSTGRES_USER` et `POSTGRES_PASSWORD`.
- **Accès Limité** : Limitez l'accès à PostgreSQL uniquement aux services qui en ont besoin via le réseau Docker.

### Sauvegarde et Restauration

#### Sauvegarde

Utilisez `pg_dump` pour effectuer des sauvegardes régulières de la base de données.

```bash
docker exec -t postgre pg_dumpall -c -U your_username > backup.sql
```

#### Restauration

Pour restaurer une sauvegarde, utilisez la commande suivante :

```bash
docker exec -i postgre psql -U your_username -d your_database < backup.sql
```

### Monitoring

Intégrez PostgreSQL avec Prometheus pour surveiller les métriques de la base de données. Configurez les exporters nécessaires dans `prometheus.yml`.

---
