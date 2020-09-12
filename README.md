# Building a CentOS Virtual Appliance (OVA) using Packer

This repo builds a CentOS 8 virtual appliance for vSphere bundled as an OVA.
You can deploy the appliance and have it configured with no further action or need to login.

Key capabilities
* Configure hostname
* Configure IP settings
* Set root password
* Inject SSH keys for the root user
* SSH enabled
* Perl installed for VMware network customisation e.g. during SRM recovery

This project re-purposes almost all of the work from https://github.com/lamw/photonos-appliance

## Requirements

* MacOS or Linux Desktop
* vCenter Server or Standalone ESXi host 6.x or greater
* [VMware OVFTool](https://www.vmware.com/support/developer/ovf/)
* [Packer](https://www.packer.io/intro/getting-started/install.html)


> `packer` builds the OVA on a remote ESXi host via the [`vmware-iso`](https://www.packer.io/docs/builders/vmware-iso.html) builder. This builder requires the SSH service running on the ESXi host, the advanced setting `GuestIPHack` enabled and firewall ports open for VNC. The easiest way to configure all 3 is to VIB from [ https://github.com/umich-vci/packer-vib](https://github.com/umich-vci/packer-vib)
```
esxcli software acceptance set --level=CommunitySupported
esxcli software vib install -v https://github.com/umich-vci/packer-vib/releases/download/v1.0.0-1/packer.vib
```

## Build Instructions

Step 1 - Clone the git repository

```
git clone https://github.com/mmcgilly/centos-appliance.git
```

Step 2 - Edit the `centos-builder.json` file to configure the vSphere endpoint for building the CentOS appliance

```
{
  "builder_host": "192.168.30.10",
  "builder_host_username": "root",
  "builder_host_password": "VMware1!",
  "builder_host_datastore": "vsanDatastore",
  "builder_host_portgroup": "VM Network"
}
```
Also edit the `centos.json` file to add your vSphere endpoint so the packer VM can be unregistered after the build.
```
"variables": {
    "centos_ovf_template": "centos.xml.template",
    "ovftool_deploy_vcenter": "vcsa.lab.local",
    "ovftool_deploy_vcenter_username": "administrator@vsphere.local",
    "ovftool_deploy_vcenter_password": "VMware1!"
  }
```

**Note:** If you need to change the initial root password on the CentOS appliance, take a look at `centos-version.json` and `http/ks.cfg`.

Step 3 - Start the build by running the build script which simply calls Packer and the respective build files

```
./build.sh
````

If you wish to automatically deploy the CentOS appliance after successfully building the OVA. You can edit the `centos-dev.xml.template` file and change the `ovftool_deploy_*` variables and run `./build.sh dev` instead.
