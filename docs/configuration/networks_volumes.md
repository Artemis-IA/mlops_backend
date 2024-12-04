# Réseaux et Volumes Docker

## Réseaux

Le projet utilise un réseau Docker externe nommé `shared-network`. Cela permet aux différents services de communiquer entre eux de manière isolée.

### Création du Réseau Docker

Avant de lancer les services, assurez-vous que le réseau `shared-network` existe. Sinon, créez-le avec la commande suivante :

```bash
docker network create shared-network
```

## Volumes

Des volumes Docker persistants sont définis pour conserver les données des services entre les redémarrages des conteneurs. Voici la liste des volumes utilisés :

- `postgre-data`
- `minio-data`
- `label-studio-data`
- `gliner-data`
- `mlflow-data`
- `neo4j_data`
- `neo4j_logs`
- `grafana-data`

### Définition des Volumes dans `docker-compose.yml`

```yaml
volumes:
  postgre-data:
  minio-data:
  label-studio-data:
  gliner-data:
  mlflow-data:
  neo4j_data:
  neo4j_logs:
  grafana-data:
```

### Description des Volumes

- **postgre-data** : Stocke les données de PostgreSQL.
- **minio-data** : Stocke les données de MinIO.
- **label-studio-data** : Stocke les données de Label Studio.
- **gliner-data** : (Si utilisé) Stocke les données du service Gliner.
- **mlflow-data** : Stocke les données de MLflow.
- **neo4j_data** : Stocke les données de Neo4j.
- **neo4j_logs** : Stocke les logs de Neo4j.
- **grafana-data** : Stocke les données de Grafana.

### Gestion des Volumes

Les volumes permettent de persister les données indépendamment du cycle de vie des conteneurs. Cela garantit que les données ne sont pas perdues lors des mises à jour ou des redémarrages des services.

## Utilisation des Réseaux et Volumes

Chaque service dans le `docker-compose.yml` est connecté au réseau `shared-network` et utilise les volumes définis pour la persistance des données. Par exemple, pour PostgreSQL :

```yaml
postgre:
  container_name: postgre
  ...
  volumes:
    - postgre-data:/var/lib/postgresql/data
  networks:
    - shared-network
```

Assurez-vous que chaque service est correctement configuré pour utiliser les volumes et les réseaux définis, garantissant ainsi une communication fluide et une persistance des données.
