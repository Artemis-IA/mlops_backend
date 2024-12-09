import os
import boto3
from botocore.exceptions import NoCredentialsError, EndpointConnectionError
from dotenv import load_dotenv

# Load .env variables
load_dotenv()

# Retrieve environment variables
MINIO_ENDPOINT = os.getenv('MLFLOW_S3_ENDPOINT_URL', 'http://192.168.208.4:9000').replace('http://', '')
MINIO_ROOT_USER = os.getenv('MINIO_ROOT_USER', 'minio')
MINIO_ROOT_PASSWORD = os.getenv('MINIO_ROOT_PASSWORD', 'minio123')
BUCKET_NAME = 'labelstudio'
LOCAL_IMAGE_FOLDER = '/home/pi/Documents/IF-SRV/dataset-cac40-img'

# Set up MinIO client
s3 = boto3.client('s3',
                  endpoint_url=f'http://{MINIO_ENDPOINT}',
                  aws_access_key_id=MINIO_ROOT_USER,
                  aws_secret_access_key=MINIO_ROOT_PASSWORD,
                  region_name=os.getenv('AWS_DEFAULT_REGION', 'eu-west-1'),
                  use_ssl=False,
                  verify=False)

# Function to upload a directory of images to MinIO
def upload_directory_to_minio(local_directory, bucket_name):
    for root, dirs, files in os.walk(local_directory):
        for filename in files:
            local_path = os.path.join(root, filename)
            relative_path = os.path.relpath(local_path, local_directory)
            minio_path = os.path.join(bucket_name, relative_path)
            try:
                s3.upload_file(local_path, bucket_name, minio_path)
                print(f"Uploaded {local_path} to {minio_path}")
            except NoCredentialsError:
                print(f"Credentials not available for MinIO at {MINIO_ENDPOINT}")
            except EndpointConnectionError as e:
                print(f"Could not connect to the MinIO at {MINIO_ENDPOINT}: {e}")

# Start the upload process
if __name__ == '__main__':
    if not os.path.isdir(LOCAL_IMAGE_FOLDER):
        print("The specified local directory does not exist.")
    else:
        upload_directory_to_minio(LOCAL_IMAGE_FOLDER, BUCKET_NAME)
