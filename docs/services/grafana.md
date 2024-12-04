# Grafana

## Description

Grafana est utilisé pour visualiser les métriques collectées par Prometheus et autres sources de données. Il permet de créer des dashboards personnalisés pour surveiller les performances et la santé de vos services.

## Configuration

### Définition du Service dans `docker-compose.yml`

```yaml
grafana:
  image: grafana/grafana:latest
  container_name: grafana
  environment:
    - GF_SECURITY_ADMIN_USER=admin
    - GF_SECURITY_ADMIN_PASSWORD=admin_password  # Changez ceci pour des raisons de sécurité
  ports:
    - "3001:3001"
  volumes:
    - grafana-data:/var/lib/grafana
  networks:
    - shared-network
  restart: always
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.grafana.rule=Host(`grafana.domaine.com`)"
    - "traefik.http.routers.grafana.entrypoints=websecure"
    - "traefik.http.routers.grafana.tls.certresolver=cloudflare"
    - "traefik.http.routers.grafana.middlewares=authelia@docker,secureHeaders@docker"
```

### Points Clés

- **Interface Web** : Accessible via `grafana.domaine.com`.
- **Sécurité** : Les identifiants par défaut doivent être changés pour des raisons de sécurité.
- **Volumes** : Les données sont persistées dans `grafana-data`.

### Dockerfile

Le `Dockerfile` dans le répertoire `grafana` (si personnalisé) peut être configuré pour installer des plugins ou des dashboards spécifiques. Cependant, l'exemple ci-dessus utilise l'image officielle de Grafana sans modifications.

### Utilisation

1. **Construction de l'Image Docker**

   ```bash
   docker-compose build grafana
   ```

2. **Démarrage du Service**

   ```bash
   docker-compose up -d grafana
   ```

3. **Accéder à l'Interface Web**

   Ouvrez votre navigateur et naviguez vers [https://grafana.domaine.com](https://grafana.domaine.com). Connectez-vous avec les identifiants définis dans le fichier `.env`.

### Sécurité

- **Mots de Passe Forts** : Changez le mot de passe admin par défaut (`admin_password`) pour un mot de passe sécurisé.
- **Accès Restreint** : Limitez l'accès à Grafana uniquement aux utilisateurs autorisés via le réseau Docker.
- **HTTPS** : Assurez-vous que l'accès à Grafana se fait via HTTPS pour sécuriser les communications.

### Sauvegarde et Restauration

#### Sauvegarde

Sauvegardez le volume `grafana-data` pour conserver les dashboards, les configurations et les plugins.

```bash
docker run --rm \
  -v grafana-data:/var/lib/grafana \
  -v $(pwd)/backup:/backup \
  alpine tar czf /backup/grafana-data.tar.gz -C /var/lib/grafana .
```

#### Restauration

Pour restaurer les données, utilisez la commande suivante :

```bash
docker run --rm \
  -v grafana-data:/var/lib/grafana \
  -v $(pwd)/backup:/backup \
  alpine tar xzf /backup/grafana-data.tar.gz -C /var/lib/grafana
```

### Monitoring

Configurez Grafana pour se connecter à Prometheus en tant que source de données :

1. **Ajouter une Source de Données**
   - Naviguez vers **Configuration > Data Sources**.
   - Ajoutez **Prometheus** avec l'URL `http://prometheus:9090`.

2. **Importer des Dashboards**
   - Utilisez des dashboards prédéfinis ou créez des dashboards personnalisés pour visualiser les métriques de vos services.

### Alertes

Configurez des alertes dans Grafana pour être informé des anomalies détectées par Prometheus.

#### Exemple de Configuration d'Alerte

1. **Créer un Dashboard**
2. **Ajouter un Panel**
3. **Configurer les Alertes dans le Panel**

---
```