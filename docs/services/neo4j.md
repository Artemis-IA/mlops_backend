# Neo4j

## Description

Neo4j est utilisé comme base de données graph pour gérer les relations complexes entre les données. Il permet de modéliser et de requêter des graphes de données de manière efficace.

## Configuration

### Définition du Service dans `docker-compose.yml`

```yaml
neo4j:
  image: neo4j:latest
  container_name: neo4j
  ports:
    - "7474:7474"  # Interface web Neo4j
    - "7687:7687"  # Protocole Bolt
  environment:
    - NEO4J_AUTH=${NEO4J_AUTH}
    - NEO4J_PLUGINS=["apoc"]
  volumes:
    - neo4j_data:/data
    - neo4j_logs:/logs
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.neo4j.rule=Host(`neo4j.domaine.com`)"
    - "traefik.http.routers.neo4j.entrypoints=websecure"
    - "traefik.http.routers.neo4j.tls.certresolver=cloudflare"
    - "traefik.http.routers.neo4j.middlewares=authelia@docker,secureHeaders@docker"
    - "traefik.http.services.neo4j.loadbalancer.server.port=7474"  # Correction effectuée
  networks:
    - shared-network
  restart: unless-stopped
```

### Points Clés

- **Interface Web** : Accessible via `neo4j.domaine.com`.
- **Sécurité** : Utilisation de Traefik pour gérer les certificats TLS et les middlewares de sécurité.
- **Plugins** : Le plugin `apoc` est installé pour étendre les fonctionnalités de Neo4j.
- **Volumes** : Les données et les logs sont persistés dans `neo4j_data` et `neo4j_logs` respectivement.

### Installation des Plugins

Le plugin `apoc` est un ensemble d'outils pour Neo4j qui fournit des procédures et des fonctions supplémentaires. Assurez-vous qu'il est correctement installé et configuré.

#### Configuration des Plugins

1. **Télécharger le Plugin `apoc`**

   Téléchargez la dernière version d'`apoc` depuis [GitHub](https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases) et placez-le dans le répertoire des plugins de Neo4j.

2. **Configurer Neo4j pour Charger les Plugins**

   Ajoutez les configurations suivantes dans le fichier `neo4j.conf` si nécessaire :

   ```ini
   dbms.security.procedures.unrestricted=apoc.*
   dbms.security.procedures.allowlist=apoc.*
   ```

### Utilisation

1. **Accéder à l'Interface Web**

   Ouvrez votre navigateur et naviguez vers [https://neo4j.domaine.com](https://neo4j.domaine.com). Connectez-vous avec les identifiants définis dans le fichier `.env`.

2. **Interagir avec la Base de Données**

   Utilisez l'interface web ou les outils comme `cypher-shell` pour exécuter des requêtes Cypher et gérer vos graphes de données.

### Sécurité

- **Mots de Passe Forts** : Utilisez des mots de passe complexes pour `NEO4J_AUTH`.
- **Accès Restreint** : Limitez l'accès à Neo4j uniquement aux services qui en ont besoin via le réseau Docker.

### Sauvegarde et Restauration

#### Sauvegarde

Utilisez les outils intégrés de Neo4j pour créer des snapshots réguliers de la base de données.

```bash
docker exec -it neo4j bin/neo4j-admin dump --database=neo4j --to=/data/neo4j.dump
docker cp neo4j:/data/neo4j.dump ./backup/neo4j.dump
```

#### Restauration

Pour restaurer une sauvegarde, utilisez la commande suivante :

```bash
docker exec -it neo4j bin/neo4j-admin load --database=neo4j --from=/data/neo4j.dump --force
```

### Monitoring

Intégrez Neo4j avec Prometheus pour surveiller les métriques de la base de données. Configurez les exporters nécessaires dans `prometheus.yml`.

---
```
