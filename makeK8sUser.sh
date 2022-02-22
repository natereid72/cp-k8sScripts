# Usage: makeK8sUser.sh [username] [cluster name]
#
# Example, if you want to create a user called test1 in your kind cluster called kind-kind,
# you'd type ./makeK8sUser.sh test1 kind-kind
#
# This will create an API user, a nsamespace by the same name, a role and rolebinding for that user
# to have permissions in the namespace only, update your kube config file with the user as a new context.
#
# After creaing a user, use kubectx or kubectl config use-context to switch to the new user.
#
[ $# -eq 0 ] && { echo "Usage: ./makeK8suser.sh [user name] [name space] [cluster name on kubeconfig]"; exit 1; }
kubectl create ns $2
openssl genrsa -out $1.key 2048
openssl req -new -key $1.key -out $1.csr -subj "/C=US/ST=none/L=none/O=users/OU=none/CN=$1"
export CSR_REQ=$(cat $1.csr | base64 | tr -d "\n")
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: $1
spec:
  request: $CSR_REQ
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF
unset CSR_REQ
kubectl certificate approve $1
kubectl get csr $1 -o jsonpath='{.status.certificate}'| base64 -d > $1.crt
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: read-write
  namespace: $2
rules:
- apiGroups:
  - ""
  - extensions
  - apps
  - batch
  - autoscaling
  - azure.platformref.crossplane.io
  resources: ["*"]
  verbs:
  - get
  - list
  - watch
  - create
  - update
  - patch
  - delete
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: namespace-binding
  namespace: $2
roleRef:
  kind: Role
  name: read-write
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: User
  name: $1
  apiGroup: rbac.authorization.k8s.io
EOF
kubectl config set-credentials $1 --client-key=$1.key --client-certificate=$1.crt --embed-certs=true --cluster=$3
kubectl config set-context $1 --cluster=$3 --user=$1 --namespace=$2
