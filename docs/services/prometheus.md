# Prometheus

## Description

Prometheus est utilisé pour la surveillance des métriques de vos services Dockerisés. Il collecte des données de performance et de santé, permettant une analyse et une alerte en temps réel.

## Configuration

### Définition du Service dans `docker-compose.yml`

```yaml
prometheus:
  image: prom/prometheus:latest
  container_name: prometheus
  volumes:
    - ./metrics/prometheus.yml:/etc/prometheus/prometheus.yml
  ports:
    - "9090:9090"
  extra_hosts:
    - "host.docker.internal:host-gateway"
  networks:
    - shared-network
  restart: always
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.prometheus.rule=Host(`prometheus.domaine.com`)"
    - "traefik.http.routers.prometheus.entrypoints=websecure"
    - "traefik.http.routers.prometheus.tls.certresolver=cloudflare"
    - "traefik.http.routers.prometheus.middlewares=authelia@docker,secureHeaders@docker"
```

### Points Clés

- **Interface Web** : Accessible via `prometheus.domaine.com`.
- **Configuration** : Utilise `prometheus.yml` pour définir les cibles de surveillance.
- **Sécurité** : Utilisation de Traefik pour gérer les certificats TLS et les middlewares de sécurité.

### Fichier de Configuration `prometheus.yml`

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'docker'
    static_configs:
      - targets: ['postgre:5432', 'minio:9000', 'neo4j:7474', 'mlflow:5000', 'label-studio:8080', 'grafana:3001']
```

### Utilisation

1. **Construction de l'Image Docker**

   ```bash
   docker-compose build prometheus
   ```

2. **Démarrage du Service**

   ```bash
   docker-compose up -d prometheus
   ```

3. **Accéder à l'Interface Web**

   Ouvrez votre navigateur et naviguez vers [https://prometheus.domaine.com](https://prometheus.domaine.com).

### Sécurité

- **Mots de Passe Forts** : Si des accès administratifs sont configurés, utilisez des mots de passe complexes.
- **Accès Restreint** : Limitez l'accès à Prometheus uniquement aux services qui en ont besoin via le réseau Docker.

### Sauvegarde et Restauration

#### Sauvegarde

Sauvegardez le fichier de configuration `prometheus.yml` et les données de Prometheus si nécessaire.

```bash
docker cp prometheus:/etc/prometheus/prometheus.yml ./backup/prometheus.yml
```

#### Restauration

Pour restaurer la configuration, copiez le fichier sauvegardé dans le conteneur.

```bash
docker cp ./backup/prometheus.yml prometheus:/etc/prometheus/prometheus.yml
docker restart prometheus
```

### Monitoring

Prometheus collecte des métriques de tous les services définis dans `prometheus.yml`. Assurez-vous que chaque service expose les métriques nécessaires via des endpoints compatibles.

### Alertes

Configurez des règles d'alerte dans `alert_rules.yml` pour être informé des anomalies ou des défaillances.

#### Exemple d'Alerte dans `alert_rules.yml`

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

### Intégration avec Grafana

Connectez Prometheus à Grafana pour visualiser les métriques collectées. Configurez les dashboards nécessaires dans Grafana pour suivre les indicateurs clés.

---
