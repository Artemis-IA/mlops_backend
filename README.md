
# 📊 MLFLOW + Label Studio + ML Backend: End-to-End ML Experiment Tracking & Data Annotation

Welcome to the **MLFlow-LabelStudio-ML Backend** project, an integrated platform designed to streamline machine learning experiment tracking, data labeling, and model management in a cohesive, containerized environment. This setup leverages **MLflow**, **Label Studio**, and a variety of machine learning backends to deliver a full-stack ML lifecycle management system.

## 🛠️ Key Components
This environment is built using **Docker Compose** to orchestrate multiple services:
- **MLFlow** – For experiment tracking, logging, and artifact storage.
- **PostgreSQL** – As a backend store for MLFlow to keep track of experiments.
- **MinIO** – An S3-compatible object storage system for model artifacts and datasets.
- **Label Studio** – A powerful tool for data annotation and labeling with seamless integration to ML models.
- **Label Studio ML Backend** – Facilitates automatic predictions and active learning with ML models like BERT, EasyOCR, and others.

---

## 🎯 Project Goals

This project aims to provide a unified workflow for machine learning practitioners:

- **Track ML Experiments**: Use MLFlow to log your experiments, store model artifacts, and version your models.
- **Annotate Data**: Leverage Label Studio to annotate datasets and feed them into your ML experiments.
- **Active Learning**: Connect ML models to Label Studio using Label Studio ML backend to generate predictions, refine annotations, and create a feedback loop to improve model performance.
  
With this environment, you can run and track models, annotate data, and iteratively improve the models by coupling ML backends for tasks like text classification, image recognition, and object detection.

---

## 🌍 Environment Overview

```bash
.
├── docker-compose.yml
├── mlflow                           # MLFlow
│   ├── Dockerfile
│   ├── entrypoint.sh
│   └── wait-for-it.sh
├── postgres                         # PostgreSQL
│   ├── Dockerfile
│   ├── entrypoint.sh
│   └── init_db.sql
├── minio-client                     # MinIO
│   ├── Dockerfile
│   └── entrypoint.sh
├── label-studio                     # Label Studio setup
│   ├── Dockerfile
│   └── entrypoint.sh
├── label-studio-ml-backend          # ML backends for automatic model predictions
│   ├── bert_classifier
│   ├── easyocr
│   ├── flair
│   ├── huggingface_llm
│   └── ... (more backends)
└── .env                             # .env
```

---

## 🛠️ Installation & Setup

### 1. **Clone the Repository**
```bash
git clone <repository_url>
cd MLFLOW-server
```

### 2. **Configure Environment Variables**
Create a `.env` file by copying the template and adjusting values as needed:
```bash
cp .env.example .env
```
Update fields like `POSTGRES_USER`, `POSTGRES_PASSWORD`, `MLFLOW_PORT`, and other required environment variables.

### 3. **Build and Launch the Services**
Use Docker Compose to build and run all services in the background:
```bash
docker compose up --build -d
```

### 4. **Verify the Setup**
Check if all services are running properly:
```bash
docker compose ps
docker logs <service_name>
```

---

## 🔧 Usage Instructions

### 🌟 **MLFlow (Experiment Tracking)**
- Access MLFlow at `http://localhost:5002`
- Track ML experiments, model versions, and store artifacts with MinIO as the backend.

### ✏️ **Label Studio (Data Annotation)**
- Access Label Studio at `http://localhost:8081`
- Create projects, import datasets, and annotate them for training models.
  
### ⚙️ **Label Studio ML Backend (Active Learning)**
- Set up active learning workflows by connecting ML models to Label Studio.
- Utilize pre-configured ML backends (like BERT, EasyOCR) to generate predictions on new data.
  
### 🗃 **MinIO (Object Storage)**
- Access MinIO at `http://localhost:9000`
- Store MLFlow artifacts, Label Studio datasets, and more in an S3-compatible object storage.

---

## 🧠 Integrated Workflow

1. **Label Your Data** in **Label Studio**.
2. **Train Your Model** using MLFlow, tracking each experiment and its results.
3. **Connect Models to Label Studio** via the ML Backend for active learning, where models generate predictions, and humans validate/correct them.
4. **Iterate** on this process by improving your model with more annotated data and tracking new experiments in MLFlow.

---

## 📂 Data Persistence & Volumes
All persistent data is stored in Docker volumes:
```yaml
volumes:
  postgres-data:         # PostgreSQL data
  minio-data:            # MinIO object storage
  label-studio-data:     # Label Studio media and project data
  mlflow-data:           # MLFlow experiment tracking data
```

---

## ⚠️ Common Issues

- **PostgreSQL not starting**: Ensure your `.env` file contains valid `POSTGRES_USER`, `POSTGRES_PASSWORD`, and `POSTGRES_DB` values.
- **MLFlow connection issues**: Double-check the `MLFLOW_BACKEND_STORE_URI` in your `.env` file to make sure it's configured correctly to connect to PostgreSQL.
- **MinIO bucket not found**: Make sure that MinIO is properly set up and accessible using the credentials in the `.env` file.

---

## 📜 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.