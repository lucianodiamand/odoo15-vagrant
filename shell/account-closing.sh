#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

OE_VERSION=15.0
OE_HOME="/opt/odoo15/odoo"
OE_CUSTOM_ADDONS="/opt/odoo15/odoo-custom-addons"
OE_USER="odoo15"

git clone -b $OE_VERSION https://github.com/OCA/account-closing /tmp/oca_account-closing 2> /dev/null # Solo necesitamos account_invoice_start_end_dates
mv /tmp/oca_account-closing/account_invoice_start_end_dates $OE_CUSTOM_ADDONS

chown -R $OE_USER:$OE_USER $OE_CUSTOM_ADDONS

echo "* Adding account_invoice_start_end_dates addon"
sed '/^addons_path/ s/$/,\/opt\/odoo15\/odoo-custom-addons\/account_invoice_start_end_dates/' /etc/odoo15.conf > /tmp/odoo15.conf
mv /tmp/odoo15.conf /etc/odoo15.conf

systemctl stop odoo15

su $OE_USER -c "/opt/odoo15/odoo/odoo-bin -c /etc/odoo15.conf -d hcd -i account_invoice_start_end_dates --without-demo=all --load-language es_AR --stop-after-init" 2> /dev/null

systemctl start odoo15

echo "Successfully added account_invoice_start_end_dates addon."
echo ""

