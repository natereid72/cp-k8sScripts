# Usage: ./argo-cp-all-in-one.sh [argo admin password]
#
# Use `chmod +x ./argo-cp-all-in-one.sh` to mark executable.
#
[ $# -eq 0 ] && { echo "Usage: ./argoCD+Gatekeeper.sh [argo admin password]"; exit 1; }
kubectl create namespace argocd
until kubectl get ns argocd -o 'jsonpath={..status.phase}' | grep -m 1 "Active" ; do : ; done
# Use following line for released version
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo "Hang tight, waiting for argoCD server to become ready. When you see the port-forward console open, you can access the argoCD UI at https://localhost:8080 with username admin and the password you provided."
until kubectl get pods -l app.kubernetes.io/name=argocd-server -n argocd -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}' | grep -m 1 "True"; do : ; done
osascript -e 'tell app "Terminal" to do script "kubectl port-forward svc/argocd-server -n argocd 8080:443"'
export ARGO_ADMIN_PW=$1
export ARGO_NEW_PW=$(htpasswd -bnB "" $ARGO_ADMIN_PW | tr -d ':\n' | sed 's/$2y/$2a/')
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "'$ARGO_NEW_PW'", 
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"}}'
unset ARGO_NEW_PW
unset ARGO_ADMIN_PW
kubectl apply -f https://raw.githubusercontent.com/natereid72/gitops/main/main/main.yaml
