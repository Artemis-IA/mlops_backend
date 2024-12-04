# Surveillance et Monitoring

Avec **Prometheus** et **Grafana**, vous disposez d'une solution robuste pour surveiller les performances et la santé de vos services Dockerisés. Cette section détaille comment configurer et utiliser ces outils pour une surveillance efficace.

## Prometheus

### Description

Prometheus collecte des métriques à partir des différents services et les stocke pour une analyse ultérieure.

### Configuration

Le fichier de configuration `prometheus.yml` situé dans le répertoire `metrics` définit les cibles de surveillance.

#### Exemple de `prometheus.yml`

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'docker'
    static_configs:
      - targets: ['postgre:5432', 'minio:9000', 'neo4j:7474', 'mlflow:5000', 'label-studio:8080', 'grafana:3001']
```

### Collecte des Métriques

Assurez-vous que chaque service expose les métriques nécessaires via des endpoints compatibles avec Prometheus. Par exemple, PostgreSQL peut utiliser **postgres_exporter**, et Neo4j peut utiliser **neo4j_exporter**.

#### Installation des Exporters

1. **PostgreSQL Exporter**

   Ajoutez le service `postgres_exporter` dans votre `docker-compose.yml`.

   ```yaml
   postgres_exporter:
     image: prometheuscommunity/postgres-exporter
     environment:
       - DATA_SOURCE_NAME=postgresql://your_username:your_password@postgre:5432/your_database?sslmode=disable
     networks:
       - shared-network
     restart: always
   ```

2. **Neo4j Exporter**

   Ajoutez le service `neo4j_exporter` dans votre `docker-compose.yml`.

   ```yaml
   neo4j_exporter:
     image: mercari/neo4j_exporter
     environment:
       - NEO4J_URI=bolt://neo4j:7687
       - NEO4J_USER=neo4j
       - NEO4J_PASSWORD=your_password
     networks:
       - shared-network
     restart: always
   ```

### Alertes

Configurez des alertes dans `alert_rules.yml` pour être informé des anomalies ou des défaillances.

#### Exemple d'Alerte

```yaml
groups:
  - name: example
    rules:
      - alert: HighCPUUsage
        expr: process_cpu_seconds_total > 0.8
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage has been above 80% for more than 5 minutes."
```

### Visualisation avec Grafana

Configurez Grafana pour se connecter à Prometheus en tant que source de données et créez des dashboards personnalisés pour visualiser les métriques collectées.

#### Ajouter une Source de Données dans Grafana

1. **Naviguez vers** : **Configuration > Data Sources**.
2. **Ajoutez** : **Prometheus**.
3. **Configurez l'URL** : `http://prometheus:9090`.
4. **Enregistrez et Testez** la connexion.

#### Créer des Dashboards

1. **Importez des Dashboards Prédéfinis** : Utilisez des dashboards disponibles sur [Grafana Dashboards](https://grafana.com/grafana/dashboards).
2. **Créez des Dashboards Personnalisés** : Ajoutez des panels spécifiques pour suivre les indicateurs clés de vos services.

### Monitoring des Services

Surveillez les services suivants :

- **PostgreSQL** : Suivez les connexions, la charge CPU, la mémoire utilisée, etc.
- **MinIO** : Surveillez l'utilisation du stockage, le nombre de requêtes, les erreurs.
- **Neo4j** : Suivez les transactions, la mémoire utilisée, les performances des requêtes.
- **MLflow** : Surveillez les expériences, les artefacts, les modèles déployés.
- **Label Studio** : Surveillez les annotations, les utilisateurs actifs, les performances.
- **Grafana** : Surveillez l'utilisation des ressources, les plugins actifs, les dashboards.
- **Prometheus** : Surveillez l'état de la collecte des métriques, la performance du serveur.

### Bonnes Pratiques

- **Définir des Seuils Appropriés** : Configurez des seuils réalistes pour les alertes afin de réduire les fausses alertes.
- **Documenter les Dashboards** : Ajoutez des descriptions aux dashboards pour faciliter leur compréhension par les membres de l'équipe.
- **Automatiser les Alertes** : Configurez des intégrations avec des outils de notification (comme Slack, PagerDuty) pour recevoir les alertes en temps réel.

### Conclusion

Une configuration efficace de Prometheus et Grafana permet une surveillance proactive de votre infrastructure, assurant ainsi une disponibilité et une performance optimales de vos services Dockerisés.
