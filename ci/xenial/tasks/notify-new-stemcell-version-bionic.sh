#!/usr/bin/env bash

set -e -x

: "${SLACK_URL:?}"

[ -f published-stemcell/version ] || exit 1

published_stemcell_version=$(cat published-stemcell/version)
curl -X POST --data "payload={\"text\": \"New Community Bionic Stemcell ${published_stemcell_version} is coming!\"}" "${SLACK_URL}"
