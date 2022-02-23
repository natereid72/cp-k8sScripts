# cp-k8sScripts - Repo of helpful scripts for Crossplane testing

### Bring your own cluster and use these scripts to test Crossplane. These scripts are tested to work with 'traditional' Kubernetes and KinD clusters.

### uxp.sh

Usage: ./uxp.sh

Installs UXP (Downstream Upbound version of Crossplane), with Composition Revision enabled.

### argoCD.sh

Usage: ./argoCD.sh [arogCD admin password]

Installs ArgoCD and OPA Gatekeeper into existing cluster. Defines ArgoCD applications based on platform-ref-azure and a Gatekeeper policy for a `dev` namepsace that restricts cluster XRC node size to `small`.

The argoCD applications include a `platofrm` config that (after manual sync) installs an Azure ProviderConfig. That config requires a Kubernetes seceret per the instructions here [Azure Provider Secret Config](https://github.com/upbound/platform-ref-azure#configure-providers-in-your-platform). Future iterations of this repo will inclide other cloud provider option and respective ProviderConfig instructions.

### makeK8sUser.sh

Usage: ./makeK8suser.sh [user name] [namespace] [cluster name in kubeconfig (e.g. kind-kind)]

Creates a kube-apoiserver user, grants them rights at namespace level. If namespace doesn't exits, creates namespace. Updated kube config file with context named same as user name.


