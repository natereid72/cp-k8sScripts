# Usage: ./argoCD+Gatekeeper.sh [argo admin password]
#
# Use `chmod +x ./makeK8sUser.sh` to mark executable.
#
# Installs ArgoCD and OPA Gatekeeper. Three apps are created in ArgoCD, two for Crossplane and one for Gatekeeper.
# Install UXP before installing this script.
#
[ $# -eq 0 ] && { echo "Usage: ./argoCD+Gatekeeper.sh [argo admin password]"; exit 1; }
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.7/deploy/gatekeeper.yaml
kubectl create namespace argocd
sleep 2
until kubectl get ns | grep -m 1 "argocd"; do : ; done
# Use following line for RC version
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.3.0-rc4/manifests/install.yaml
# Use following line for released version
#kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo "Hang tight, waiting for argoCD server to become ready. When you see the port-forward console open, you can access the argoCD UI at https://localhost:8080 with username admin and the password you provided."
until kubectl get pods -l app.kubernetes.io/name=argocd-server -n argocd -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}' | grep -m 1 "True"; do : ; done
osascript -e 'tell app "Terminal" to do script "kubectl port-forward svc/argocd-server -n argocd 8080:443"'
export ADMIN_PW=$1
export NEW_PW=$(htpasswd -bnB "" $ADMIN_PW | tr -d ':\n' | sed 's/$2y/$2a/')
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "'$NEW_PW'", 
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"}}'
unset NEW_PW
unset ADMIN_PW
cat <<EOF | kubectl apply -f -
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: aks-platform
  namespace: argocd
spec:
  destination:
    server: https://kubernetes.default.svc
  project: default
  source:
    directory:
      jsonnet: {}
      recurse: true
    path: platform
    repoURL: https://github.com/natereid72/gitops.git
    targetRevision: HEAD
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: aks-cluster
  namespace: argocd
spec:
  destination:
    server: https://kubernetes.default.svc
  project: default
  source:
    path: aks/xr
    repoURL: https://github.com/natereid72/gitops.git
    targetRevision: HEAD
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-policy
  namespace: argocd
spec:
  destination:
    server: https://kubernetes.default.svc
  project: default
  source:
    directory:
      jsonnet: {}
      recurse: true
    path: policy
    repoURL: https://github.com/natereid72/gitops.git
    targetRevision: HEAD
EOF

