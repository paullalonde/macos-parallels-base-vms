#!/bin/bash

set -eu

SELF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function usage() {
  echo "usage: make-base-vm.sh <options>"                        1>&2
  echo "options:"                                                1>&2
  echo "  --os <name>  Required. The name of macOS to install."  1>&2
  echo "               On of: catalina, bigsur, monterey."       1>&2
  exit 20
}

OS=''

while [[ $# -gt 0 ]]
do
  case "$1" in
    --os)
    OS="$2"
    shift
    shift
    ;;

    *)
    usage
  esac
done

if [[ -z "${OS}" ]]; then
  usage
fi

case "${OS}" in
  catalina|bigsur|monterey)
  ;;

  *)
  echo "Unsupported OS '${OS}'." 1>&2
  exit 21
esac

pushd "${SELF_DIR}" >/dev/null

rm -rf build

PACKER_DIR=packer
PACKER_FILE="${PACKER_DIR}/packer.pkr.hcl"
CONF_FILE="${PACKER_DIR}/conf/${OS}.pkrvars.hcl"
SECRETS_FILE="${PACKER_DIR}/conf/secrets.pkrvars.hcl"

if [[ ! -f "${SECRETS_FILE}" ]]; then
  echo "Cannot locate Packer variables file '${SECRETS_FILE}'." 1>&2
  exit 1
fi

packer fmt -check -diff "${PACKER_FILE}"
packer init "${PACKER_FILE}"
packer build \
  -var-file="${CONF_FILE}" \
  -var-file="${SECRETS_FILE}" \
  "${PACKER_FILE}"

popd >/dev/null
