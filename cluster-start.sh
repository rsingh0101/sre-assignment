CLUSTER_NAME=mycluster
DOMAIN=mycluster.com
kind create cluster --name mycluster --config cluster.yaml --image kindest/node:v1.33.0
echo "Health checking for kind based cluster"
MAX_RETRIES=10
SLEEP_SECONDS=5

for i in $(seq 1 $MAX_RETRIES); do
  echo "Attempt $i: Checking if cluster '$CLUSTER_NAME' is up..."

  if kubectl cluster-info --context kind-${CLUSTER_NAME} >/dev/null 2>&1 && \
     kubectl get nodes --context kind-${CLUSTER_NAME} 2>/dev/null | grep -q ' Ready'; then
    echo "Cluster '$CLUSTER_NAME' is up and nodes are ready."
    echo "Setting up ingress for cluster"
    helm upgrade --install my-ingress ./ingress-nginx --set controller.service.type=NodePort --set controller.service.nodePorts.http=30000 --set controller.service.nodePorts.https=30001 -f ./ingress-nginx/values.yaml -n ingress-nginx --create-namespace
    echo "Creating custom coredns for a domain"
    cat << EOF > coredns-cm.yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: coredns
    data:
      Corefile: |
        .:53 {
          errors
          health{
            lameduck 5s
          }
          ready
          kubernetes cluster.local in-addr.arpa ip6.arpa {
            pods insecure
            fallthrough in-addr.arpa ip6.arpa
            ttl 30
          }
          file /etc/coredns/$DOMAIN.db $DOMAIN
          prometheus :9153
          forward . /etc/resolv.conf {
            max_concurrent 1000
          }
          cache 30
          loop
          reload
          loadbalance
        }
EOF
    cat << EOF >> coredns-cm.yaml
      $DOMAIN.db: |
        ; $DOMAIN file
        $DOMAIN.    IN    SOA    sns.dns.icann.org. noc.dns.icann.org. 2015082541 7200 3600 1209600 3600
EOF
    for ((i=0;i<=1;i++)) ; do
      NODE=$(kubectl get no -o jsonpath="{.items[$((i))].status.addresses[0].address}")
      echo "        *.$DOMAIN.    IN    A    $NODE" >> coredns-cm.yaml
    done   
    kubectl apply -f coredns-cm.yaml -n kube-system
    # PATCH='{"spec":{"template": {"spec":{"volumes":[{"name":"config-volume","configĦap":{"name":"coredns", "defaultMode":420,"items": [{"key":"Corefile","path":"Corefile"),[{"key":"$DOMAIN.db","path":"$DOMAIN.db"}]}}]}}}}'
    PATCH='{
        "spec": {
            "template": {
            "spec": {
                "volumes": [
                {
                    "name": "config-volume",
                    "configMap": {
                    "name": "coredns",
                    "defaultMode": 420,
                    "items": [
                        {"key": "Corefile", "path": "Corefile"},
                        {"key": "'"$DOMAIN"'.db", "path": "'"$DOMAIN"'.db"}
                    ]
                    }
                }
                ]
            }
            }
        }
        }'
    kubectl patch deployment coredns -n kube-system -p "$PATCH"
    # CONTROLLER_PATCH='{"spec":{"template":["spec":{"containers":[{"name":"controller","args":["/nginx-ingress-controller","--publish-service-$(POD_NAMESPACE)/my-ingress-ingress-nginx-controller","--election-id=my-ingress-ingress-nginx-Leader","--controller-class=k8s.io/ingress-nginx", "--ingress-class=nginx","--configmap=$(POD_NAMESPACE)/my-ingress-ingress-nginx-controller","--validating-webhook=:8443","--validating-webhook-certificate=/usr/local/certificates/cert","--validating-webhook-key=/usr/local/certificates/key","--enable-ssl-passthrough"]}]} }}}'
    CONTROLLER_PATCH='{
        "spec": {
            "template": {
            "spec": {
                "containers": [
                {
                    "name": "controller",
                    "args": [
                    "/nginx-ingress-controller",
                    "--publish-service=$(POD_NAMESPACE)/my-ingress-ingress-nginx-controller",
                    "--election-id=my-ingress-ingress-nginx-Leader",
                    "--controller-class=k8s.io/ingress-nginx",
                    "--ingress-class=nginx",
                    "--configmap=$(POD_NAMESPACE)/my-ingress-ingress-nginx-controller",
                    "--validating-webhook=:8443",
                    "--validating-webhook-certificate=/usr/local/certificates/cert",
                    "--validating-webhook-key=/usr/local/certificates/key",
                    "--enable-ssl-passthrough"
                    ]
                }
                ]
            }
            }
        }
        }'
    kubectl patch deployment my-ingress-ingress-nginx-controller -n ingress-nginx -p "$CONTROLLER_PATCH"
    echo "Setting up Argocd in the cluster"
    helm upgrade --install argocd ./argo-cd/ -f ./argo-cd/values.yaml -n argocd --create-namespace
    sleep 10
    ./argo-cd.sh
    exit 0
  fi

  echo "Cluster not ready yet. Retrying in ${SLEEP_SECONDS}s..."
  sleep $SLEEP_SECONDS
done

echo "Cluster '$CLUSTER_NAME' is not healthy after $MAX_RETRIES attempts."
exit 1

