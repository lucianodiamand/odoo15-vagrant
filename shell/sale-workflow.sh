#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

OE_VERSION=15.0
OE_HOME="/opt/odoo15/odoo"
OE_CUSTOM_ADDONS="/opt/odoo15/odoo-custom-addons"
OE_USER="odoo15"

git clone -b $OE_VERSION https://github.com/OCA/sale-workflow /tmp/oca_sale-workflow 2> /dev/null # Solo necesitamos sale_start_end_dates
mv /tmp/oca_sale-workflow/sale_start_end_dates $OE_CUSTOM_ADDONS

chown -R $OE_USER:$OE_USER $OE_CUSTOM_ADDONS

echo "* Adding sale_satart_end_dates addon"
sed '/^addons_path/ s/$/,\/opt\/odoo15\/odoo-custom-addons\/sale_start_end_dates/' /etc/odoo15.conf > /tmp/odoo15.conf
mv /tmp/odoo15.conf /etc/odoo15.conf

systemctl stop odoo15

su $OE_USER -c "/opt/odoo15/odoo/odoo-bin -c /etc/odoo15.conf -d hcd -i sale_start_end_dates --without-demo=all --load-language es_AR --stop-after-init" 2> /dev/null

systemctl start odoo15

echo "Successfully added sale_start_end_dates addon."
echo ""

