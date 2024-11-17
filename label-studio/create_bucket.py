import requests

# Configuration
LABEL_STUDIO_URL = "http://label-studio:8081"
API_KEY = "your_label_studio_api_key"
BUCKET_NAME = "labelstudio-input"
TARGET_BUCKET_NAME = "labelstudio-output"
MINIO_ENDPOINT = "http://minio:9000"
ACCESS_KEY = "minio_access_key"
SECRET_KEY = "minio123"

HEADERS = {"Authorization": f"Token {API_KEY}"}

# Configurer la source de stockage
def configure_source_storage():
    payload = {
        "type": "s3",
        "title": "Source Storage",
        "bucket": BUCKET_NAME,
        "prefix": "",
        "use_blob_urls": True,
        "presign": True,
        "credentials": {
            "AWS_ACCESS_KEY_ID": ACCESS_KEY,
            "AWS_SECRET_ACCESS_KEY": SECRET_KEY
        },
        "url": MINIO_ENDPOINT
    }
    response = requests.post(
        f"{LABEL_STUDIO_URL}/api/storages/s3", json=payload, headers=HEADERS
    )
    print("Source Storage:", response.status_code, response.json())

# Configurer la cible de stockage
def configure_target_storage():
    payload = {
        "type": "s3",
        "title": "Target Storage",
        "bucket": TARGET_BUCKET_NAME,
        "prefix": "",
        "credentials": {
            "AWS_ACCESS_KEY_ID": ACCESS_KEY,
            "AWS_SECRET_ACCESS_KEY": SECRET_KEY
        },
        "url": MINIO_ENDPOINT
    }
    response = requests.post(
        f"{LABEL_STUDIO_URL}/api/storages/s3", json=payload, headers=HEADERS
    )
    print("Target Storage:", response.status_code, response.json())

# Exécution
if __name__ == "__main__":
    configure_source_storage()
    configure_target_storage()
