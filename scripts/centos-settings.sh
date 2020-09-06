#!/bin/bash -eux

##
## Misc configuration
##

echo '> Disable IPv6'
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf

echo '> Applying latest Updates...'
yum -y update

echo '> Installing Additional Packages...'
yum install -y perl

echo '> Done'
