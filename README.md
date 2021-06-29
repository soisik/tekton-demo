# Tekton Demo

Demo Tekton capabilities building, deploying, testing, ... container images.

(WIP / pending further tests)

## Requirements

- your own fork of this repository
- a working Docker registry
- k8s nodes able to pull images from that registry
- cert-manager operator (generating certificate for Tekton EventListener Ingress / not mandatory, could be done in many different ways ...)

## Deploy Tekton

```sh
$ kubectl apply -f https://github.com/tektoncd/pipeline/releases/download/v0.25.0/release.yaml
$ kubectl apply -f https://github.com/tektoncd/triggers/releases/download/v0.14.2/release.yaml
$ kubectl apply -f https://github.com/tektoncd/triggers/releases/download/v0.14.2/interceptors.yaml
$ kubectl apply -f https://github.com/tektoncd/dashboard/releases/download/v0.17.0/tekton-dashboard-release.yaml
$ kubectl apply -f https://github.com/tektoncd/chains/releases/download/v0.2.0/release.yaml
```

## Patch Assets

- using a namespace other than `test-tekton`, there would be some changes to
  make on YAML files, make sure to replace `test-tekton` with your own namespace
  name
- make sure to replace `github-ci-el.example.com` occurences by the FQDN your
  Ingress Controllers would use, routing requests to Tekton EventListener
- similarily, replace `tekton-dashboard.example.com` with the FQDN your Ingress
  Controllers would use serving your Tekton Dashboard
- there's also a Secret in the `triggers-github` file that should be changed, to
  whatever token would be configured, on GitHub side, sending webhooks to your
  Tekton EventListener
- replace mentions of `registry.registry.svc.cluster.local:5000` by the address
  of your container images registry. it is assumed your kubernetes nodes would
  be able to pull images from it, without authenticating. and that Tekton jobs
  may push images, without authenticating.

## Install Assets

```sh
$ kubectl apply -f tekton/dashboard-certificate.yaml
$ kubectl apply -f tekton/dashboard-ingress.yaml
$ kubectl create ns test-tekton
$ kubectl apply -n test-tekton -f tekton/rbac-pipelines.yaml
$ kubectl apply -n test-tekton -f tekton/rbac-triggers.yaml
$ kubectl apply -n test-tekton -f tekton/task-build.yaml
$ kubectl apply -n test-tekton -f tekton/task-deploy.yaml
$ kubectl apply -n test-tekton -f tekton/task-test.yaml
$ kubectl apply -n test-tekton -f tekton/task-retag.yaml
$ kubectl apply -n test-tekton -f tekton/task-scanimage.yaml
$ kubectl apply -n test-tekton -f tekton/task-scanrepo.yaml
$ kubectl apply -n test-tekton -f tekton/pipeline-ci.yaml
$ kubectl apply -n test-tekton -f tekton/triggers-certificate.yaml
$ kubectl apply -n test-tekton -f tekton/triggers-github.yaml
$ kubectl apply -n test-tekton -f tekton/triggers-ingress.yaml
```

## Start Jobs Manually

Test build some random docker image (old Nexus3):

```sh
$ kubectl apply -n test-tekton -f tekton/taskrun-buildah.yaml
```

Test full pipeline building your own fork (make sure to set proper git repo
and container images registry URL using your own fork and registry):

```sh
$ kubectl create -n test-tekton tekton/pipelinerun-docker.yaml
```

## Start Jobs Automatically

Configure GitHub Webhook on your fork of this repository. Make sure your hook
secret matches the one defined in your `tekton/triggers-github.yaml`, webhook
endpoint should be the one defined in `tekton/triggers-ingress.yaml`, payload
content type should be `application/json`. Disable TLS certificate verification
if you are using self-signed certificates (as the defaults would, applying
`tekton/triggers-certificate.yaml`).

Commit and push some changes to your repository. Your Tekton EventListener
should receive a notification, triggering creation for some PipelineResources
and a PipelineRun, that would scan your code, build an image, deploy a copy
locally and run integration tests, scanning the image, re-tag it if all went
well then terminate the demo deployment. Hopefully.
