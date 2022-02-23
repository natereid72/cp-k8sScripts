# cp-k8sScripts - Repo of helpful scripts for Crossplane testing

### uxp.sh

Usage: ./uxp.sh

Installs UXP (Downstream Upbound version of Crossplane), with Composition Revision enabled.

### argoCD.sh

Usage: ./argoCD.sh [arogCD admin password]

Installs ArgoCD and OPA Gatekeeper into existing cluster. Defines ArgoCD applications based on platform-ref-azure and a Gatekeeper policy for a `dev` namepsace that restricts cluster XRC node size to `small`.

### makeK8sUser.sh

Usage: ./makeK8suser.sh [user name] [namespace] [cluster name in kubeconfig (e.g. kind-kind)]

Creates a kube-apoiserver user, grants them rights at namespace level. If namespace doesn't exits, creates namespace. Updated kube config file with context named same as user name.


