#!/bin/bash

# Bootstrap script

set -euo pipefail

if [ -e /root/ran_customization ]; then
    exit
else

    DEBUG_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.debug")
    DEBUG=$(echo "${DEBUG_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    LOG_FILE=/var/log/bootstrap.log
    if [ ${DEBUG} == "True" ]; then
        LOG_FILE=/var/log/centos-customization-debug.log
        set -x
        exec 2> ${LOG_FILE}
        echo
        echo "### WARNING -- DEBUG LOG CONTAINS ALL EXECUTED COMMANDS WHICH INCLUDES CREDENTIALS -- WARNING ###"
        echo "### WARNING --             PLEASE REMOVE CREDENTIALS BEFORE SHARING LOG            -- WARNING ###"
        echo
    fi

    HOSTNAME_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.hostname")
    IP_ADDRESS_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.ipaddress")
    NETMASK_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.netmask")
    GATEWAY_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.gateway")
    DNS_SERVER_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.dns")
    DNS_DOMAIN_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.domain")
    ROOT_PASSWORD_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.root_password")
    ROOT_SSHKEYS_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.ssh_authorized_keys")

    ##################################
    ### No User Input, assume DHCP ###
    ##################################
    if [ -z "${HOSTNAME_PROPERTY}" ]; then
        cat > /etc/systemd/network/${NETWORK_CONFIG_FILE} << __CUSTOMIZE_CENTOS__
[Match]
Name=e*

[Network]
DHCP=yes
IPv6AcceptRA=no
__CUSTOMIZE_CENTOS__
    #########################
    ### Static IP Address ###
    #########################
    else
        HOSTNAME=$(echo "${HOSTNAME_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
        IP_ADDRESS=$(echo "${IP_ADDRESS_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
        NETMASK=$(echo "${NETMASK_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
        GATEWAY=$(echo "${GATEWAY_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
        DNS_SERVER=$(echo "${DNS_SERVER_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
        DNS_DOMAIN=$(echo "${DNS_DOMAIN_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')

        echo -e "\e[92mConfiguring Static IP Address ..." > /dev/console
        nmcli connection add con-name ens160 ifname ens160 type ethernet ipv4.addresses ${IP_ADDRESS}/${NETMASK}
        nmcli connection modify ens160 ipv4.method manual
        nmcli connection modify ens160 ipv4.gateway ${GATEWAY}
        nmcli connection modify ens160 ipv4.dns ${DNS_SERVER}
        nmcli connection modify ens160 ipv4.dns-search ${DNS_DOMAIN}
        

    echo -e "\e[92mConfiguring hostname ..." > /dev/console
    nmcli general hostname ${HOSTNAME}
    
    echo -e "\e[92mRestarting Network ..." > /dev/console
    nmcli connection up ens160
    fi

    echo -e "\e[92mConfiguring root password ..." > /dev/console
    ROOT_PASSWORD=$(echo "${ROOT_PASSWORD_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    echo "root:${ROOT_PASSWORD}" | /usr/sbin/chpasswd
    
    echo -e "\e[92mAdding root ssh_authorized_keys ..." > /dev/console
    ROOT_SSHKEYS=$(echo "${ROOT_SSHKEYS_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    mkdir --mode=700 /root/.ssh/
    echo "${ROOT_SSHKEYS}" >> /root/.ssh/authorized_keys
    
    echo -e "\e[92mDisabling IPv6 ..." > /dev/console
    sysctl -w net.ipv6.conf.all.disable_ipv6=1
    sysctl -w net.ipv6.conf.default.disable_ipv6=1

    # Ensure we don't run customization again
    touch /root/ran_customization
fi
