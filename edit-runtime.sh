#!/bin/bash
set -e

cat <<EOT > pcf-prometheus-pipeline/runtime.yml
releases:
- name: node-exporter
  version: ((node_exporter_version))

addons:
- name: node_exporter
  include:
    stemcell:
    - os: ubuntu-trusty
    - os: ubuntu-xenial
  jobs:
  - name: node_exporter
    release: node-exporter
EOT


source pcf-prometheus-pipeline/pipeline/tasks/common.sh

login_to_director pcf-bosh-creds

echo "Uploading Node exporter Release..."
bosh -n upload-release node-exporter-release/node-exporter-*.tgz

node_exporter_version=$(cat node-exporter-release/version)
bosh -n update-runtime-config --name=node_exporter pcf-prometheus-pipeline/runtime.yml -v node_exporter_version=${node_exporter_version}

