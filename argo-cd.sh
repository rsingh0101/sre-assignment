#!/bin/bash

ARGOCD_SERVER="argocd.mycluster.com"
USERNAME="admin"
PASSWORD= $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
APP_NAME="metrics-app"
PROJECT="default"
REPO_URL="https://github.com/your-org/your-repo.git"
REVISION="main"
PATH_IN_REPO="charts/metrics-app"
DEST_SERVER="https://kubernetes.default.svc"
DEST_NAMESPACE="metrics-app"

# Login to ArgoCD
argocd login "$ARGOCD_SERVER" --username "$USERNAME" --password "$PASSWORD" --insecure

# Create the Argo CD app
argocd app create "$APP_NAME" \
  --repo "$REPO_URL" \
  --path "$PATH_IN_REPO" \
  --revision "$REVISION" \
  --dest-server "$DEST_SERVER" \
  --dest-namespace "$DEST_NAMESPACE" \
  --project "$PROJECT" \
  --sync-policy automated \
  --auto-prune \
  --self-heal

# Sync the app
argocd app sync "$APP_NAME"
