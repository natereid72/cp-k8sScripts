kubectl create namespace upbound-system
helm repo add upbound-stable https://charts.upbound.io/stable && helm repo update
helm install uxp --namespace upbound-system upbound-stable/universal-crossplane --devel --set args='{--enable-composition-revisions}'
