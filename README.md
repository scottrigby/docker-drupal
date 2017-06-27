# Docker Drupal for Kubernetes
[![Docker Repository on Quay](https://quay.io/repository/scottrigby/php7-apache-drupal/status "Docker Repository on Quay")](https://quay.io/repository/scottrigby/php7-apache-drupal)

## Spec
 - PHP 7.0
 - Apache 2.4
 - Xdebug
 - Composer
 - supervisord

## Docker image
- Docker image is [quay.io/scottrigby/php7-apache-drupal:master](https://quay.io/repository/scottrigby/php7-apache-drupal?tab=tags)
- Dockerfile is in [github.com/scottrigby/docker-drupal](https://github.com/scottrigby/docker-drupal/tree/master/7.0/apache)
- The `master` image tag is built from a GitHub build trigger in Quay

## Helm chart
- Helm registry application is [quay.io/scottrigby/drupal:0.8.0](https://quay.io/application/scottrigby/drupal?tab=releases)
- Helm chart is in `helm` branch of [github.com/scottrigby/charts](https://github.com/scottrigby/charts/tree/quay/stable/drupal)
  (a fork patched with open PRs against [github.com/kubernetes/charts](https://github.com/kubernetes/charts/pulls/scottrigby))
- Helm registry application is built locally, from the GitHub charts fork, on a
  new branch `quay`, using the [Helm registry plugin](https://github.com/app-registry/appr-helm-plugin)

## Deploy to k8s
First see "Setup Minikube for local development" section below, or deploy on any running K8S cluster.
```bash
export ENV=test
# Modify "/helm-values.yaml" from this repo to suit your project needs, then:
helm registry install quay.io/scottrigby/drupal -f helm-values.yaml --name $ENV
```

## Setup Minikube for local development
### System compatibility
Note this script is for MacOS only. Linux and Windows should follow the [Minikube installation instructions](https://github.com/kubernetes/minikube/blob/master/README.md).
```bash
# Starts Minikube with xhyve driver, without manual intervention.
# If not present, installs homebrew, minikube, docker-machine-driver-xhyve.
# To-do: Keep an eye on the following GitHub issues/PRs. Once complete, this
#   workaround script will no longer be needed:
#   - https://github.com/kubernetes/minikube/issues/1400
#   - https://github.com/zchee/docker-machine-driver-xhyve/issues/178
#   - https://github.com/kubernetes/minikube/issues/1623
# Ref: https://gist.github.com/scottrigby/0d5e79afbc00a3650f043cb7d380080d
wget -O xhyve-minikube-start.sh https://gist.githubusercontent.com/scottrigby/0d5e79afbc00a3650f043cb7d380080d/raw/e135a1405d47b736faceb120dcd8c4ea5e3bd990/xhyve-minikube-start.sh
chmod +x xhyve-minikube-start.sh
./xhyve-minikube-start.sh
helm init

# To see progress, open the K8S UI.
minikube dashboard

# Wait a moment for tiller pod to be ready, then see "Deploy to k8s" section
# above.

# After deploying, wait a moment for drupal and mariadb containers to be ready,
# then visit the Drupal service.
open $(minikube service local-drupal --url | sed -n 1p)

# Note: when finished developing, pause with `minikube stop` or wipe clean with
# `minikube delete`.
```

## Develop Docker images locally with Minikube
```bash
# Reuse Docker Daemon in Minikube.
# Ref: https://github.com/kubernetes/minikube/blob/master/docs/reusing_the_docker_daemon.md
eval $(minikube docker-env)
# Build the image in Minikube using the same CLI session.
git clone git@github.com:scottrigby/docker-drupal.git
# For the Dockerfile to build properly you must currently have a "docroot"
# directory at "/7.0/apache/docroot". The existing directory is stock Drupal
# from `drush dl drupal-7.56 --drupal-project-rename=docroot`. Change the Drupal
# docroot files to suit your project needs.
# To-do: We will parameterize this in the future, to be less heavy-handed.
# When building locally you can call this whatever you wish. Change the IMAGE
# name:tag to anything you want, but also update the "image" value in
# "/helm-values.yaml" from this repo to match.
export IMAGE=cms-php7:local
time docker build -t $IMAGE -f 7.0/apache/Dockerfile 7.0/apache

# Wait a moment for tiller pod to be ready, then:
# Optional: adjust helm-values.yaml` to taste (including local mount options).
helm install ./helm-drupal/ -f helm-values.yaml --name local

# Wait a moment for drupal and mariadb containers to be ready, then:
open $(minikube service local-drupal --url | sed -n 1p)

# Cleanup when done.
helm delete local --purge
```
