# TODO: replace this entire script with minikube/helm Go bindings so the user doesn't have to install minikube and helm.

#!/usr/bin/env bash

set -eof pipefail

MINIKUBE_CONFIG='registry.url=$(REGISTRY_SERVICE_HOST),registry.authtoken=e30K,ingress.basedomain=k8s.local'

minikube addons enable registry
if [[ -z "${DRAFT_INIT_INGRESS_ENABLED}" ]]; then
    minikube addons enable ingress
fi

helm init
# TODO: replace with `helm init --wait`: https://github.com/kubernetes/helm/pull/3238
echo -e "--> Waiting for 15 seconds for tiller to start..."
echo -e "!!! NOTE: If this fails, please check the cluster's status with\n"
echo -e "\t$ kubectl -n kube-system get pods\n"
echo -e "!!! Once tiller's up and running, re-run \`draft init\` again and it should resolve itself."
sleep 15

if [ -v "DRAFT_INIT_UPGRADE" ]; then
    helm upgrade draft $1 --set=${MINIKUBE_CONFIG}
else
    helm install $1 --name draft --namespace=${DRAFT_INIT_DRAFT_NAMESPACE} --set=${MINIKUBE_CONFIG}
fi

echo "Draftd has been installed into your Minikube cluster."
