export PROJECT_ID=$(gcloud config list --format 'value(core.project)')
export CLOUDSQL_SERVICE_ACCOUNT=cloudsql-service-account
gcloud iam service-accounts create $CLOUDSQL_SERVICE_ACCOUNT --project=$PROJECT_ID
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$CLOUDSQL_SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com"  \
    --role="roles/cloudsql.admin"

gcloud iam service-accounts keys create $CLOUDSQL_SERVICE_ACCOUNT.json \
    --iam-account=$CLOUDSQL_SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
    --project=$PROJECT_ID

kubectl create secret generic cloudsql-instance-credentials \
    --from-file=credentials.json=$CLOUDSQL_SERVICE_ACCOUNT.json
    
kubectl create secret generic cloudsql-db-credentials \
    --from-literal=username=postgres \
    --from-literal=password=supersecret! \
    --from-literal=dbname=gmemegen_db

gcloud auth configure-docker ${REGION}-docker.pkg.dev
gcloud artifacts repositories create $REPO \
    --repository-format=docker --location=$REGION

kubectl expose deployment gmemegen \
    --type "LoadBalancer" \
    --port 80 --target-port 8080