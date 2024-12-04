# Sauvegardes

Il est essentiel de mettre en place des stratégies de sauvegarde régulières pour garantir la disponibilité des données critiques. Cette section décrit les méthodes de sauvegarde et de restauration pour chaque service de votre backend Dockerisé.

## PostgreSQL

### Sauvegarde

Utilisez `pg_dump` pour effectuer des sauvegardes régulières de la base de données.

#### Commande de Sauvegarde

```bash
docker exec -t postgre pg_dumpall -c -U your_username > backup.sql
```

#### Automatisation avec Cron

Créez une tâche cron pour automatiser les sauvegardes.

1. **Éditez la Crontab**

   ```bash
   crontab -e
   ```

2. **Ajoutez la Tâche Cron**

   ```cron
   0 2 * * * docker exec -t postgre pg_dumpall -c -U your_username > /path/to/backups/backup_$(date +\%F).sql
   ```

### Restauration

Pour restaurer une sauvegarde, utilisez la commande suivante :

```bash
docker exec -i postgre psql -U your_username -d your_database < backup.sql
```

## MinIO

### Sauvegarde

Activez la réplication ou utilisez des outils comme `mc` (MinIO Client) pour synchroniser les données vers un autre emplacement.

#### Utilisation de `mc` pour la Sauvegarde

```bash
docker exec -it minio-client mc mirror minio/your-bucket /path/to/backup
```

### Restauration

Pour restaurer les données, inversez la commande de synchronisation.

```bash
docker exec -it minio-client mc mirror /path/to/backup minio/your-bucket
```

## Neo4j

### Sauvegarde

Utilisez les outils intégrés de Neo4j pour créer des snapshots réguliers de la base de données.

#### Commande de Sauvegarde

```bash
docker exec -it neo4j bin/neo4j-admin dump --database=neo4j --to=/data/neo4j.dump
docker cp neo4j:/data/neo4j.dump ./backup/neo4j.dump
```

### Restauration

Pour restaurer une sauvegarde, utilisez la commande suivante :

```bash
docker exec -it neo4j bin/neo4j-admin load --database=neo4j --from=/data/neo4j.dump --force
```

## MLflow

### Sauvegarde

Les artefacts MLflow sont stockés dans MinIO. Utilisez le client MinIO pour sauvegarder les artefacts.

#### Commande de Sauvegarde

```bash
docker exec -it minio-client mc mirror minio/mlflow/artifacts /path/to/backup
```

### Restauration

Pour restaurer les artefacts, utilisez la commande suivante :

```bash
docker exec -it minio-client mc mirror /path/to/backup minio/mlflow/artifacts
```

## Label Studio

### Sauvegarde

Les données Label Studio sont stockées dans le volume `label-studio-data`. Sauvegardez ce volume régulièrement.

#### Commande de Sauvegarde

```bash
docker run --rm \
  -v label-studio-data:/label-studio/data \
  -v $(pwd)/backup:/backup \
  alpine tar czf /backup/label-studio-data.tar.gz -C /label-studio/data .
```

### Restauration

Pour restaurer les données, utilisez la commande suivante :

```bash
docker run --rm \
  -v label-studio-data:/label-studio/data \
  -v $(pwd)/backup:/backup \
  alpine tar xzf /backup/label-studio-data.tar.gz -C /label-studio/data
```

## Grafana

### Sauvegarde

Sauvegardez le volume `grafana-data` pour conserver les dashboards, les configurations et les plugins.

#### Commande de Sauvegarde

```bash
docker run --rm \
  -v grafana-data:/var/lib/grafana \
  -v $(pwd)/backup:/backup \
  alpine tar czf /backup/grafana-data.tar.gz -C /var/lib/grafana .
```

### Restauration

Pour restaurer les données, utilisez la commande suivante :

```bash
docker run --rm \
  -v grafana-data:/var/lib/grafana \
  -v $(pwd)/backup:/backup \
  alpine tar xzf /backup/grafana-data.tar.gz -C /var/lib/grafana
```

## Bonnes Pratiques de Sauvegarde

- **Fréquence** : Définissez une fréquence de sauvegarde appropriée (quotidienne, hebdomadaire) en fonction de la criticité des données.
- **Automatisation** : Automatisez les sauvegardes en utilisant des scripts et des tâches cron pour éviter les oublis.
- **Stockage Sécurisé** : Stockez les sauvegardes dans un emplacement sécurisé, idéalement hors site, pour protéger contre les pertes de données locales.
- **Vérification des Sauvegardes** : Testez régulièrement les sauvegardes en effectuant des restaurations pour vous assurer de leur intégrité.
- **Rotation des Sauvegardes** : Mettez en place une politique de rétention pour supprimer les anciennes sauvegardes et économiser de l'espace de stockage.

## Conclusion

Une stratégie de sauvegarde bien définie garantit la résilience de votre infrastructure et la disponibilité continue des données critiques. Assurez-vous de suivre les meilleures pratiques pour minimiser les risques de perte de données.

