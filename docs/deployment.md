# Déploiement

Pour déployer votre backend Dockerisé, suivez les étapes détaillées ci-dessous. Cette section couvre le clonage du dépôt, la configuration des variables d'environnement, la création du réseau Docker, et le lancement des services avec Docker Compose.

## Étapes de Déploiement

### 1. Cloner le Dépôt

Commencez par cloner le dépôt GitHub sur votre machine locale.

```bash
git clone https://github.com/Artemis-IA/mlops_backend.git
cd mlops_backend
```

### 2. Configurer les Variables d'Environnement

Copiez le fichier `.env.example` en `.env` et modifiez les valeurs selon vos besoins.

```bash
cp .env.example .env
```

Ouvrez le fichier `.env` avec votre éditeur préféré et définissez les valeurs appropriées pour chaque variable.

### 3. Créer le Réseau Docker

Si le réseau `shared-network` n'existe pas, créez-le avec la commande suivante :

```bash
docker network create shared-network
```

### 4. Lancer les Services avec Docker Compose

Utilisez Docker Compose pour construire les images et démarrer les conteneurs.

```bash
docker-compose up -d
```

Cette commande construira les images Docker nécessaires et démarrera les conteneurs en arrière-plan.

### 5. Vérifier l'État des Services

Assurez-vous que tous les services sont en cours d'exécution et fonctionnent correctement.

```bash
docker-compose ps
```

Vous devriez voir une liste de tous les services avec leur état actuel.

### 6. Accéder aux Interfaces Web

Une fois les services démarrés, accédez aux interfaces web via les URLs configurées :

- **PostgreSQL** : Accessible via le port défini (par exemple, `5432`) pour les connexions internes.
- **MinIO** : [https://minio.domaine.com](https://minio.domaine.com)
- **Neo4j** : [https://neo4j.domaine.com](https://neo4j.domaine.com)
- **MLflow** : [https://mlflow.domaine.com](https://mlflow.domaine.com)
- **Label Studio** : [https://labelstudio.domaine.com](https://labelstudio.domaine.com)
- **Prometheus** : [https://prometheus.domaine.com](https://prometheus.domaine.com)
- **Grafana** : [https://grafana.domaine.com](https://grafana.domaine.com)

### 7. Tester les Services

Assurez-vous que chaque service fonctionne comme prévu en accédant à leurs interfaces web et en vérifiant les connexions.

### 8. Gestion des Logs

Pour visualiser les logs d'un service spécifique, utilisez la commande suivante :

```bash
docker-compose logs <service_name>
```

Par exemple, pour voir les logs de PostgreSQL :

```bash
docker-compose logs postgre
```

### 9. Arrêter les Services

Pour arrêter tous les services, utilisez :

```bash
docker-compose down
```

Si vous souhaitez également supprimer les volumes, ajoutez l'option `-v` :

```bash
docker-compose down -v
```

### 10. Mettre à Jour les Services

Pour mettre à jour les services après avoir modifié les configurations ou les Dockerfiles, reconstruisez les images et redémarrez les conteneurs.

```bash
docker-compose build
docker-compose up -d
```

### Conseils de Déploiement

- **Automatisation** : Utilisez des scripts CI/CD pour automatiser le déploiement et les mises à jour.
- **Surveillance** : Configurez des alertes dans Prometheus et Grafana pour surveiller la santé des services.
- **Sécurité** : Assurez-vous que toutes les connexions sont sécurisées via HTTPS et que les mots de passe sont forts et bien gérés.
- **Sauvegardes** : Mettez en place des sauvegardes régulières pour toutes les bases de données et les volumes de données critiques.

-

### **Développement ou Production ? **

1. **Dev Local (sans Traefik)** :
   ```bash
   docker-compose -f docker-compose.yml -f docker-compose.override.yml up
   ```

2. **Prod avec Traefik** :
   ```bash
   docker-compose -f docker-compose.yml -f docker-compose.traefik.yml up
   ``` 

---

Avec ces trois fichiers, vous pouvez gérer un environnement de développement local sans Traefik, ainsi qu'un environnement de production avec Traefik, tout en utilisant la même base de configuration et le fichier `.env`.