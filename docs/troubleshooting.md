# Dépannage

Cette section couvre les problèmes courants que vous pourriez rencontrer avec votre backend Dockerisé et fournit des solutions pour les résoudre.

## 1. Services qui ne démarrent pas

### Symptômes

- Le conteneur ne démarre pas.
- Le service est en état `Exited`.

### Solutions

#### Vérifier les Logs du Conteneur

Consultez les logs du conteneur pour identifier les erreurs spécifiques.

```bash
docker-compose logs <service_name>
```

**Exemple :**

```bash
docker-compose logs postgre
```

#### Vérifier les Variables d'Environnement

Assurez-vous que toutes les variables d'environnement nécessaires sont correctement définies dans le fichier `.env`.

#### Vérifier les Dépendances

Assurez-vous que les services dont dépend le conteneur sont en cours d'exécution.

```yaml
depends_on:
  - minio
```

## 2. Problèmes de Connexion entre Services

### Symptômes

- Les services ne peuvent pas se connecter entre eux.
- Erreurs de connexion dans les logs.

### Solutions

#### Vérifier le Réseau Docker

Assurez-vous que tous les services sont connectés au même réseau Docker (`shared-network`).

```bash
docker network inspect shared-network
```

#### Vérifier les Variables d'Environnement

Vérifiez que les variables d'environnement pour les hôtes et les ports sont correctement définies.

#### Tester la Connectivité

Utilisez des outils comme `ping` ou `telnet` à l'intérieur des conteneurs pour tester la connectivité.

```bash
docker exec -it <container_name> ping <service_name>
docker exec -it <container_name> telnet <service_name> <port>
```

## 3. Certificats TLS Invalides

### Symptômes

- Erreurs de certificat lors de l'accès aux services via HTTPS.
- Avertissements de navigateur concernant la sécurité.

### Solutions

#### Vérifier la Configuration de Traefik

Assurez-vous que Traefik est correctement configuré pour gérer les certificats TLS via Cloudflare.

#### Vérifier les DNS

Assurez-vous que les sous-domaines utilisés pointent correctement vers votre serveur Traefik.

#### Renouvellement des Certificats

Assurez-vous que les certificats TLS sont valides et renouvelés automatiquement.

```bash
docker logs traefik
```

## 4. Performance Dégradée

### Symptômes

- Les services sont lents à répondre.
- Haute utilisation des ressources (CPU, mémoire).

### Solutions

#### Surveiller les Ressources

Utilisez Grafana et Prometheus pour identifier les goulets d'étranglement.

#### Optimiser les Configurations des Services

Ajustez les configurations des services pour mieux utiliser les ressources disponibles.

#### Augmenter les Ressources Allouées

Allouez plus de CPU et de mémoire aux conteneurs si nécessaire.

```yaml
services:
  postgre:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: '4G'
```

## 5. Problèmes de Réseau

### Symptômes

- Services ne peuvent pas être atteints via les URLs configurées.
- Erreurs de réseau dans les logs.

### Solutions

#### Vérifier la Configuration des Labels Traefik

Assurez-vous que les labels Traefik sont correctement définis pour chaque service.

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.service_name.rule=Host(`service.mlops.bzh`)"
  - "traefik.http.routers.service_name.entrypoints=websecure"
  - "traefik.http.routers.service_name.tls.certresolver=cloudflare"
  - "traefik.http.routers.service_name.middlewares=authelia@docker,secureHeaders@docker"
```

#### Redémarrer Traefik

Redémarrez le conteneur Traefik pour appliquer les modifications de configuration.

```bash
docker-compose restart traefik
```

#### Vérifier les Règles de Pare-feu

Assurez-vous que les règles de pare-feu permettent le trafic sur les ports nécessaires.

## 6. Erreurs dans les Scripts d'Initialisation

### Symptômes

- Les scripts d'initialisation ne s'exécutent pas correctement.
- Les services ne sont pas configurés comme prévu.

### Solutions

#### Vérifier les Permissions des Scripts

Assurez-vous que les scripts d'initialisation ont les permissions d'exécution.

```bash
chmod +x /path/to/script.sh
```

#### Vérifier les Logs

Consultez les logs des conteneurs pour identifier les erreurs spécifiques lors de l'exécution des scripts.

```bash
docker-compose logs <service_name>
```

#### Tester les Scripts Localement

Exécutez les scripts manuellement à l'intérieur des conteneurs pour identifier les problèmes.

```bash
docker exec -it <service_name> /bin/bash
./script.sh
```

## 7. Problèmes de Stockage Persistant

### Symptômes

- Les données ne sont pas persistées entre les redémarrages des conteneurs.
- Volumes Docker ne sont pas montés correctement.

### Solutions

#### Vérifier les Montages de Volumes

Assurez-vous que les volumes Docker sont correctement montés dans le fichier `docker-compose.yml`.

```yaml
volumes:
  postgre-data:
    driver: local
```

#### Vérifier les Permissions des Volumes

Assurez-vous que les permissions des répertoires montés permettent l'écriture par les conteneurs.

```bash
chmod -R 755 /path/to/volume
```

#### Inspecter les Volumes Docker

Vérifiez l'état des volumes Docker.

```bash
docker volume inspect postgre-data
```

## Conclusion

Le dépannage efficace repose sur une identification précise des symptômes et une approche systématique pour résoudre les problèmes.
