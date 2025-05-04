#!/bin/bash

ARGOCD_SERVER="localhost:8080"
USERNAME="admin"
PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
APP_NAME="metrics-app"
PROJECT="default"
REPO_URL="https://github.com/rsingh0101/sre-assignment.git"
REVISION="main"
PATH_IN_REPO="metrics-app"
DEST_SERVER="https://kubernetes.default.svc"
DEST_NAMESPACE="metrics-app"
PATH_VALUES_IN_REPO="metrics-app/metrics-app.yaml"

ARGO_SERVER=$(kubectl get po -n argocd --no-headers -l  app.kubernetes.io/name=argocd-server | awk '{print $1}')
# Login to ArgoC
kubectl exec -it -n argocd $ARGO_SERVER -- argocd login "$ARGOCD_SERVER" --username "$USERNAME" --password "$PASSWORD" --insecure --plaintext

# Create the Argo CD app
kubectl exec -it -n argocd $ARGO_SERVER -- argocd app create "$APP_NAME" \
  --repo "$REPO_URL" \
  --path "$PATH_IN_REPO" \
  --revision "$REVISION" \
  --dest-server "$DEST_SERVER" \
  --dest-namespace "$DEST_NAMESPACE" \
  --values "$PATH_VALUES_IN_REPO" \
  --project "$PROJECT" \
  --sync-policy automated \
  --auto-prune \
  --self-heal 

sleep 5
# Sync the app
kubectl exec -it -n argocd $ARGO_SERVER -- argocd app sync "$APP_NAME"