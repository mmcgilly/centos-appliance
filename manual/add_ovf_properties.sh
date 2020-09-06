#!/bin/bash

OUTPUT_PATH="../output-vmware-iso"

rm -f ${OUTPUT_PATH}/${CENTOS_APPLIANCE_NAME}/${CENTOS_APPLIANCE_NAME}.mf

sed "s/{{VERSION}}/${CENTOS_VERSION}/g" ${CENTOS_OVF_TEMPLATE} > centos.xml

if [ "$(uname)" == "Darwin" ]; then
    sed -i .bak1 's/<VirtualHardwareSection>/<VirtualHardwareSection ovf:transport="com.vmware.guestInfo">/g' ${OUTPUT_PATH}/${CENTOS_APPLIANCE_NAME}/${CENTOS_APPLIANCE_NAME}.ovf
    sed -i .bak2 "/    <\/vmw:BootOrderSection>/ r centos.xml" ${OUTPUT_PATH}/${CENTOS_APPLIANCE_NAME}/${CENTOS_APPLIANCE_NAME}.ovf
    sed -i .bak3 '/^      <vmw:ExtraConfig ovf:required="false" vmw:key="nvram".*$/d' ${OUTPUT_PATH}/${CENTOS_APPLIANCE_NAME}/${CENTOS_APPLIANCE_NAME}.ovf
    sed -i .bak4 "/^    <File ovf:href=\"${CENTOS_APPLIANCE_NAME}-file1.nvram\".*$/d" ${OUTPUT_PATH}/${CENTOS_APPLIANCE_NAME}/${CENTOS_APPLIANCE_NAME}.ovf
else
    sed -i 's/<VirtualHardwareSection>/<VirtualHardwareSection ovf:transport="com.vmware.guestInfo">/g' ${OUTPUT_PATH}/${CENTOS_APPLIANCE_NAME}/${CENTOS_APPLIANCE_NAME}.ovf
    sed -i "/    <\/vmw:BootOrderSection>/ r centos.xml" ${OUTPUT_PATH}/${CENTOS_APPLIANCE_NAME}/${CENTOS_APPLIANCE_NAME}.ovf
    sed -i '/^      <vmw:ExtraConfig ovf:required="false" vmw:key="nvram".*$/d' ${OUTPUT_PATH}/${CENTOS_APPLIANCE_NAME}/${CENTOS_APPLIANCE_NAME}.ovf
    sed -i "/^    <File ovf:href=\"${CENTOS_APPLIANCE_NAME}-file1.nvram\".*$/d" ${OUTPUT_PATH}/${CENTOS_APPLIANCE_NAME}/${CENTOS_APPLIANCE_NAME}.ovf
fi

ovftool ${OUTPUT_PATH}/${CENTOS_APPLIANCE_NAME}/${CENTOS_APPLIANCE_NAME}.ovf ${OUTPUT_PATH}/${FINAL_CENTOS_APPLIANCE_NAME}.ova
rm -rf ${OUTPUT_PATH}/${CENTOS_APPLIANCE_NAME}
rm -f centos.xml
