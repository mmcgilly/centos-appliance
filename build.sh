#!/bin/bash -x

echo "Building CentOS OVA Appliance ..."
rm -f output-vmware-iso/*.ova

if [[ "$1" -gt "-1" ]] && [[ $1 == "dev" ]]; then
    echo "Applying packer build to centos-dev.json ..."
    date
    packer build -var-file=centos-builder.json -var-file=centos-version.json centos-dev.json
    date
else
    echo "Applying packer build to centos.json ..."
    date
    packer build -var-file=centos-builder.json -var-file=centos-version.json centos.json
    date
fi
