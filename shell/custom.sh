#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

OE_VERSION=15.0
OE_HOME="/opt/odoo15/odoo"
OE_CUSTOM_ADDONS="/opt/odoo15/odoo-custom-addons"
OE_USER="odoo15"

ln -s /vagrant/addons/employee_extended /opt/odoo15/odoo-custom-addons/employee_extended
ln -s /vagrant/addons/coordinacion /opt/odoo15/odoo-custom-addons/coordinacion

echo "* Adding custom addons"
sed '/^addons_path/ s/$/,\/opt\/odoo15\/odoo-custom-addons\/employee_extended,\/opt\/odoo15\/odoo-custom-addons\/coordinacion/' /etc/odoo15.conf > /tmp/odoo15.conf
mv /tmp/odoo15.conf /etc/odoo15.conf

systemctl stop odoo15

su $OE_USER -c "/opt/odoo15/odoo/odoo-bin -c /etc/odoo15.conf -d hcd -i employee_extended,coordinacion --without-demo=all --load-language es_AR --stop-after-init" 2> /dev/null

systemctl start odoo15

echo "Successfully added custom addons."
echo ""

