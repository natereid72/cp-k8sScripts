# cp-k8sScripts - Repo of helpful scripts for Crossplane testing

### Bring your own cluster and use these scripts to test Crossplane. These scripts are tested on MacOS to work with 'traditional' Kubernetes and KinD clusters.

### argo-cp-all-in-one.sh

Usage: ./argo-cp-all-in-one.sh [arogCD admin password]

Installs argo CD, then appllies argo CD applications to the cluster that install Gatekeeper, Crossplane, and the Crossplane XRDs and Composition for an AKS cluster. 

The argoCD applications include a `platofrm` config that (after manual sync) installs an Azure ProviderConfig. That config requires a Kubernetes seceret  per the instructions here [Azure Provider Secret Config](https://github.com/upbound/platform-ref-azure#configure-providers-in-your-platform) (Stopping at `kubectl create secret generic azure-account-creds -n upbound-system --from-file=credentials=./crossplane-azure-provider-key.json`). Future iterations of this repo will include other cloud provider options and respective ProviderConfig instructions.

### uxp.sh

Usage: ./uxp.sh

Installs UXP (Downstream Upbound version of Crossplane), with Composition Revision enabled.

### argoCD.sh

Usage: ./argoCD.sh [arogCD admin password]

Installs ArgoCD.

### makeK8sUser.sh

Usage: ./makeK8suser.sh [username] [namespace] [cluster name in kubeconfig (e.g. kind-kind)]

Creates a kube-apiserver user, grants them rights at namespace level. If namespace doesn't exits, creates namespace. Updates kube config file with context named same as username.


