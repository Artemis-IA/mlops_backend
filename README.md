# 🚇 Backend MLOps

## Bases de Données & Stockage Objet: PostgreSQL/PGVector, Neo4J, Minio
## Middleware Models & Data managment : MLflow & Label Studio/ML Backend
 ## Monitoring  & Intégrations : Prometheus, Grafana, Postgres Exporter, Neo4J Exporter

Bienvenue dans ce projet MLOps complet, conçu pour offrir un environnement de travail unifié autour du cycle de vie des données et des modèles de Machine Learning. De l’acquisition et l’annotation des données, à l’entraînement, la mise en production, le suivi expérimental, le monitoring et la visualisation, cette plateforme met en place une architecture cohérente, conteneurisée via **Docker Compose**.

#### Pour plus de détails, veuillez consulter la [**Documentation & Guide du Projet**](https://artemis-ia.github.io/mlops_backend/).

---

## 🎯 Objectifs du Projet

L’objectif est de proposer un écosystème MLOps complet :

- **Annotation des données** : Label Studio pour étiqueter vos datasets (images, texte, audio, vidéo).
- **Expérimentation & Suivi ML** : MLflow pour logger vos expériences, hyperparamètres, métriques, et stocker les artefacts modèles.
- **Stockage des Artefacts & Données** : MinIO, un stockage objet compatible S3, centralise les données (datasets, modèles, logs).
- **Bases de Données** :  
  - PostgreSQL comme backend pour MLflow et Label Studio.  
  - Neo4j comme base de données graphe pour explorer les relations complexes entre données, expériences et ressources.
- **Monitoring & Observabilité** : Prometheus pour collecter des métriques, PGMonitor et Neo4j-Exporter pour superviser les bases de données, Grafana pour créer des tableaux de bord interactifs.
- **Backends ML** (Commentés pour l’instant) : Intégration de serveurs ML backends (ex. BERT, EasyOCR, HuggingFace) afin d’activer l’apprentissage actif et l’inférence automatique dans Label Studio.

L’ensemble s’intègre dans un workflow itératif, du prétraitement des données à l’entraînement en passant par l’annotation, la mise en place de boucles d’apprentissage actif, et la surveillance continue de l’infrastructure.

---

## 🛠️ Composants & Services

Le fichier `docker-compose.yml` orchestre l’ensemble des services décrits ci-dessous. Tous sont connectés sur un réseau partagé `shared-network`.

1. **PostgreSQL (`postgre`)**
   - **Rôle** : Base de données relationnelle.
   - **Utilisation** : Backend principal de MLflow (stockage des métadonnées d’expériences, tracking) et Label Studio (stockage des projets, des annotations).
   - **Ports & Variables** : Définis dans `.env` (`POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`, `POSTGRES_PORT`).
   - **Volumes** : `postgre-data` pour la persistance des données.
   - **Init** : Script `init_db.sql.template` pour la création du schéma initial.

2. **PGMonitor (`pgmonitor`)**
   - **Rôle** : Exporter Prometheus pour PostgreSQL.
   - **Utilisation** : Collecte des métriques de la base de données PostgreSQL, fournies à Prometheus.
   - **Environnement** : Défini par `DATA_SOURCE_NAME` pointant vers PostgreSQL.

3. **MinIO (`minio`)**
   - **Rôle** : Stockage objet compatible S3.
   - **Utilisation** : Conserver artefacts MLflow, datasets Label Studio, etc.
   - **Ports & Variables** : Dans `.env` (`MINIO_ROOT_USER`, `MINIO_ROOT_PASSWORD`, `MINIO_PORT`, `MINIO_CONSOLE_PORT`).
   - **Volumes** : `minio-data` pour persister les données.
   - **Healthcheck** : Vérifie la disponibilité du service MinIO.

4. **MinIO-Client (`minio-client`)**
   - **Rôle** : Client CLI pour interagir avec MinIO (création buckets, configuration CORS).
   - **Environnement** : (`MINIO_ENDPOINT`, `MINIO_ROOT_USER`, `MINIO_ROOT_PASSWORD`) à partir du `.env`.
   - **Volumes** : Monte un `cors.json` pour configurer les CORS sur MinIO.

5. **Neo4j (`neo4j`)**
   - **Rôle** : Base de données graphe.
   - **Utilisation** : Explorer les relations complexes entre entités (données, expériences, modèles, etc.).
   - **Ports & Variables** : `NEO4J_WEB_PORT`, `NEO4J_BOLT_PORT`, `NEO4J_AUTH`.
   - **Volumes** : `neo4j_data` & `neo4j_logs` pour stocker données et logs de Neo4j.
   - **Plugins** : APOC (activé par `NEO4J_PLUGINS=["apoc"]`).

6. **Neo4j-Metrics (`neo4j-metrics`)**
   - **Rôle** : Exporter Prometheus pour Neo4j.
   - **Utilisation** : Fournir des métriques Neo4j à Prometheus.
   - **Ports & Variables** : Configurés via `.env` (`NEO4J_METRICS_PORT`, etc.).
   - **Source** : 🌟 Made with [Neo4j Exporter](https://github.com/petrov-e/neo4j_exporter) thanks to [Egor Petrov](https://github.com/petrov-e)

7. **MLflow (`mlflow`)**
   - **Rôle** : Suivi d’expériences ML, stockage d’artefacts, versionnage de modèles.
   - **Intégrations** :
     - Backend store : PostgreSQL
     - Artifact Store : MinIO (via `MLFLOW_S3_ENDPOINT_URL`)
   - **Ports & Variables** : `MLFLOW_PORT`, `MLFLOW_BACKEND_STORE_URI`, `MLFLOW_ARTIFACT_ROOT`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`.
   - **Volumes** : Dossier `./mlflow` monté dans le container pour scripts et configuration.
   
8. **Label Studio (`label-studio`)**
   - **Rôle** : Outil d’annotation de données.
   - **Utilisation** : Annotations d’images, texte, audio, vidéo. Intégration avec MinIO (stockage datasets) et PostgreSQL (métadonnées).
   - **Ports & Variables** : `LABEL_STUDIO_PORT`, `LABEL_STUDIO_BUCKET_ENDPOINT_URL`, `LABEL_STUDIO_BUCKET_ACCESS_KEY`, `LABEL_STUDIO_BUCKET_SECRET_KEY`.
   - **Volumes** : `label-studio-data` pour stocker données locales, plus `create_bucket.py` & `cors.json` pour configurer MinIO.
   - **Note** : Label Studio peut être connecté à des ML backends pour l’apprentissage actif.

9. **Prometheus (`prometheus`)**
   - **Rôle** : Collecte et agrégation de métriques.
   - **Utilisation** : Récupère les métriques de PGMonitor, Neo4j-Metrics, etc.
   - **Volumes** : `./metrics/prometheus.yml` pour configuration.
   - **Ports & Variables** : `PROMETHEUS_PORT`.

10. **Grafana (`grafana`)**
    - **Rôle** : Visualisation de métriques et création de tableaux de bord.
    - **Utilisation** : Relier à Prometheus comme datasource, construire des dashboards pour suivre l’état de l’environnement.
    - **Ports & Variables** : `GRAFANA_PORT`.
    - **Volumes** : `grafana-data` (externe), et `./metrics/grafana/provisioning` pour charger automatiquement datasources & dashboards.

11. **ML Backends (commentés)**  
    - **Rôle** : Fournir des modèles ML (ex. BERT, EasyOCR, HuggingFace LLM) connectés à Label Studio via une API REST.
    - **Utilisation** : Apprentissage actif, préannotations, suggestions automatiques.
    - **Comment activer ?** : Décommenter la section correspondante dans `docker-compose.yml` et configurer les variables d’environnement requises.
    - **Volumes & Cache** : Possibilité de monter un volume HuggingFace cache pour réutiliser les modèles, `./data/server` pour données locales du backend ML.

---

## 🌍 Arborescence du Projet

```bash
mlops_backend/
├── docker-compose.yml
├── .env                 # Variables d’environnement
├── postgre/             # Base de données PostgreSQL & extension PGVector
│   ├── Dockerfile
│   ├── entrypoint.sh
│   └── init_db.sql.template # Template d'initialisation SQL utilisant envsubset
├── mlflow/              # Tracking server & Suivi artefacts des modèles
│   ├── Dockerfile
│   ├── entrypoint.sh
│   └── wait-for-it.sh
├── minio-client/       # Stockage objet pour MLFlow (artifacs), Label-Studio, & l'[API WeaveStruct](https://artemis-ia.github.io/mlops_backend/).
│   ├── Dockerfile
│   └── entrypoint.sh
├── label-studio/       # Interface de labellisation et suivi des données
│   ├── Dockerfile
│   ├── entrypoint.sh
│   ├── create_bucket.py
│   └── cors.json
├── neo4j_exporter/      # Exporter Neo4j -> Prometheus
│   ├── Dockerfile
│   └── ...
├── metrics/
│   ├── prometheus.yml   # Config Prometheus
│   └── grafana/
│       └── provisioning # Config Grafana (datasources, dashboards)
├── label-studio-ml-backend/
│   ├── bert_classifier/
│   ├── gliner/
│   ├── huggingface_llm/
│   └── ... (autres backends ML)
└── ...
```

---

## 🛠️ Installation & Configuration

### 1. Clonage du Dépôt

```bash
git clone https://github.com/Artemis-IA/mlops_backend.git
cd mlops_backend
```

### 2. Fichier d’Environnement

```bash
# Copier le fichier d'exemple et l'éditer
cp .env.example .env
nano .env  # ou vim .env
```

```bash
cp .env.example .env
nano .env
```

Variables à adapter :
- **PostgreSQL** : `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`, `POSTGRES_PORT`
- **MinIO** : `MINIO_ROOT_USER`, `MINIO_ROOT_PASSWORD`, `MINIO_PORT`, `MINIO_CONSOLE_PORT`
- **MLflow** : `MLFLOW_PORT`, `MLFLOW_BACKEND_STORE_URI`, `MLFLOW_ARTIFACT_ROOT`
- **Label Studio** : `LABEL_STUDIO_PORT`, `LABEL_STUDIO_BUCKET_*`, `POSTGRE_*`
- **Neo4j** : `NEO4J_WEB_PORT`, `NEO4J_BOLT_PORT`, `NEO4J_AUTH`
- **Prometheus, Grafana** : `PROMETHEUS_PORT`, `GRAFANA_PORT`

### 3. Lancement des Services

Construisez et lancez tous les services :

```bash
docker compose up --build -d
```

### 4. Vérifications

Contrôlez le bon fonctionnement :

```bash
docker compose ps
docker logs <nom_service>
```

---

## 🔧 Utilisation des Services

- **MLflow** :  
  Accédez à `http://localhost:<MLFLOW_PORT>`  
  Suivez les expériences, enregistrez des métriques et des modèles, et consultez l’historique d’entraînement.

- **Label Studio** :  
  Accédez à `http://localhost:<LABEL_STUDIO_PORT>`  
  Créez des projets, importez des données, annotez-les, et préparez des datasets de haute qualité.

- **MinIO** :  
  Accédez à `http://localhost:<MINIO_CONSOLE_PORT>`  
  Gérer vos buckets, stocker des artefacts MLflow (modèles, checkpoints) et les données Label Studio.

- **Neo4j** :  
  Accédez à `http://localhost:<NEO4J_WEB_PORT>`  
  Analyser et visualiser vos données sous forme de graphe, découvrir des relations complexes.

- **Prometheus** :  
  Accédez à `http://localhost:<PROMETHEUS_PORT>`  
  Visualiser les métriques brutes issues de PostgreSQL, Neo4j et potentiellement d’autres services.

- **Grafana** :  
  Accédez à `http://localhost:<GRAFANA_PORT>`  
  Identifiants par défaut : admin / admin_password (défini dans l’`env`)  
  Créez des dashboards personnalisés, surveillez la santé du système, la performance des entraînements et l’utilisation des ressources.

---

## 🧠 Flux de Travail Intégré

1. **Annotation & Données** :  
   Utilisez Label Studio pour étiqueter vos données. Les données et leurs labels sont stockés dans MinIO et PostgreSQL.

2. **Entraînement & Expérimentation (MLflow)** :  
   Lancez vos entraînements (en local ou dans un cluster), loguez les résultats vers MLflow.  
   MLflow utilise PostgreSQL pour stocker les métadonnées et MinIO pour les artefacts.

3. **Visualisation & Analyses** :  
   - Inspectez les résultats dans MLflow (versionnement de modèles, comparaison d’expériences).
   - Interrogez Neo4j pour des analyses relationnelles.
   - Supervisez l’état global (CPU, RAM, latence DB, usage des buckets) dans Grafana & Prometheus.

4. **Apprentissage Actif** :  
   Intégrez les ML Backends (ex. BERT) dans Label Studio.  
   Les modèles prédisent des labels sur de nouvelles données, vous corrigez dans Label Studio, et bouclez ainsi pour améliorer les modèles.

5. **Itération Continue** :  
   Répétez le cycle : plus de données annotées, plus d’expériences suivies, meilleure observabilité, boucle d’amélioration continue jusqu’à la mise en production.

---

## 📂 Persistance des Données

Les données critiques sont conservées dans des volumes Docker :

```yaml
volumes:
  postgre-data:       # Données PostgreSQL
  minio-data:         # Données MinIO
  label-studio-data:  # Données Label Studio
  neo4j_data:         # Données Neo4j
  neo4j_logs:         # Logs Neo4j
  grafana-data:       # Données Grafana (dashboards, config)
  mlflow-data:        # Données MLflow (option si monté)
```

**Remarque** : `grafana-data` est marqué comme volume externe pour éviter les pertes accidentelles. Adaptez vos stratégies de backup/restauration selon vos besoins.

---

## ⚠️ Dépannage & Problèmes Courants

- **Problème PostgreSQL** :  
  Vérifiez les identifiants dans `.env`, assurez-vous que le container PostgreSQL est sain (`docker logs postgre`).

- **Connexion MLflow-PostgreSQL** :  
  Assurez-vous que `MLFLOW_BACKEND_STORE_URI` pointe vers la base PostgreSQL (ex: `postgresql://POSTGRES_USER:POSTGRES_PASSWORD@postgre:POSTGRES_PORT/POSTGRES_DB`).

- **Accès MinIO** :  
  Vérifiez `MINIO_ROOT_USER` et `MINIO_ROOT_PASSWORD`.  
  Assurez-vous que les ports sont correctement exposés et non bloqués.

- **Dashboards Grafana Vides** :  
  Vérifiez que Prometheus est fonctionnel et que les datasources sont chargées.  
  Consultez `docker logs grafana` pour vérifier la bonne initialisation.

- **ML Backends Inactifs** :  
  Ils sont commentés par défaut. Décommentez la section correspondante dans `docker-compose.yml`, assurez-vous des variables (clé API Label Studio, etc.), et relancez `docker compose up -d`.

---

## 🏗 Contribuer & Évolutions Futures

- Ajout de nouveaux ML backends pour étendre les capacités (OCR, NLP, Vision).
- Intégration de CI/CD pour déploiement automatique des modèles.
- Extension des dashboards Grafana et exploitation de Neo4j pour des analyses plus poussées.
- Intégration d’outils de sécurité, de gouvernance et de contrôle qualité des données.

---

## 📜 Licence

Ce projet est distribué sous licence MIT. Reportez-vous au fichier [LICENSE](LICENSE) pour les détails.

---

Cette plateforme tends à proposer un socle complet pour orchestrer des workflows ML : de la préparation et l’annotation de données, jusqu’au suivi expérimental, au monitoring, à l’amélioration continue, et à la mise en place d’un pipeline MLOps.