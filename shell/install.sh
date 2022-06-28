#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

OE_VERSION=15.0
OE_HOME="/opt/odoo15/odoo"
OE_CUSTOM_ADDONS="/opt/odoo15/odoo-custom-addons"
OE_USER="odoo15"

print_usage () {
  echo "You can access to odoo:"
  echo "  Host: localhost"
  echo "  Port: 8069"
  echo "  Username: admin"
  echo "  Password: admin"
  echo ""
}

apt-get update -y
apt-get dist-upgrade -y

apt-get install -y git python3-pip build-essential wget python3-dev python3-venv \
python3-wheel libfreetype6-dev libxml2-dev libzip-dev libldap2-dev libsasl2-dev \
python3-setuptools node-less libjpeg-dev zlib1g-dev libpq-dev \
libxslt1-dev libldap2-dev libtiff5-dev libjpeg8-dev libopenjp2-7-dev \
liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev postgresql

# Necesarios odoo-argentina-ce
sudo apt install libssl-dev -y
sudo apt install swig -y

useradd -m -d /opt/odoo15 -U -r -s /bin/bash $OE_USER

su - postgres -c "createuser -s odoo15"

wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb 2> /dev/null

apt-get install ./wkhtmltox_0.12.5-1.bionic_amd64.deb -y

#--------------------------------------------------
# Install ODOO
#--------------------------------------------------
echo -e "\n==== Installing ODOO Server ===="
git clone --depth 1 --branch $OE_VERSION https://www.github.com/odoo/odoo $OE_HOME/ 2> /dev/null
chown -R odoo15:odoo15 $OE_HOME

#--------------------------------------------------
# Install Dependencies
#--------------------------------------------------
echo -e "\n--- Installing Python 3 + pip3 --"
pip3 install wheel

echo -e "\n---- Install python packages/requirements ----"
pip3 install -r $OE_HOME/requirements.txt

# Modules
echo -e "\n---- Create custom module directory ----"
su $OE_USER -c "mkdir $OE_CUSTOM_ADDONS"
git clone https://github.com/ingadhoc/odoo-argentina-ce.git $OE_CUSTOM_ADDONS/odoo-argentina-ce 2> /dev/null
git clone -b $OE_VERSION https://github.com/OCA/contract $OE_CUSTOM_ADDONS/contract 2> /dev/null
git clone -b $OE_VERSION https://github.com/OCA/dms $OE_CUSTOM_ADDONS/dms 2> /dev/null
git clone -b $OE_VERSION https://github.com/OCA/web /tmp/oca_web 2> /dev/null # Solo necesitamos web_drop_target 
mv /tmp/oca_web/web_drop_target $OE_CUSTOM_ADDONS/web_drop_target
git clone -b $OE_VERSION https://github.com/OCA/social /tmp/oca_social 2> /dev/null # Solo necesitamos mail_preview_base
mv /tmp/oca_social/mail_preview_base $OE_CUSTOM_ADDONS/mail_preview_base
git clone -b $OE_VERSION https://github.com/OCA/reporting-engine /tmp/oca_reporting 2> /dev/null # Solo necesitamos report_xlsx
mv /tmp/oca_reporting/report_xlsx $OE_CUSTOM_ADDONS/report_xlsx
chown -R $OE_USER:$OE_USER $OE_CUSTOM_ADDONS

echo -e "\n---- Install python packages/requirements for addons ----"
pip3 install -r $OE_CUSTOM_ADDONS/odoo-argentina-ce/requirements.txt

echo -e "* Creating server config file"
cat << EOF > /etc/odoo15.conf
[options]
; This is the password that allows database operations:
admin_passwd = my_admin_passwd
db_host = False
db_port = False
db_user = odoo15
db_password = False
addons_path = /opt/odoo15/odoo/addons,/opt/odoo15/odoo-custom-addons,/opt/odoo15/odoo-custom-addons/odoo-argentina-ce,/opt/odoo15/odoo-custom-addons/contract,/opt/odoo15/odoo-custom-addons/dms,/opt/odoo15/odoo-custom-addons/report_xlsx
EOF

cat << EOF > /etc/systemd/system/odoo15.service
[Unit]
Description=Odoo15
Requires=postgresql.service
After=network.target postgresql.service

[Service]
Type=simple
SyslogIdentifier=odoo15
PermissionsStartOnly=true
User=odoo15
Group=odoo15
ExecStart=/usr/bin/python3 /opt/odoo15/odoo/odoo-bin -c /etc/odoo15.conf
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

systemctl enable odoo15

su $OE_USER -c "/opt/odoo15/odoo/odoo-bin -c /etc/odoo15.conf -d hcd -i project,crm,purchase,sale_management,account,hr,stock,board,website,website_slides,website_hr_recruitment,helpdesk,mail,contacts,web_drop_target,mail_preview_base,dms,contract,l10n_ar_afipws,l10n_ar_afipws_fe,l10n_ar,report_xlsx,l10n_ar_reports --without-demo=all --load-language es_AR --stop-after-init" 2> /dev/null

systemctl start odoo15

echo "Successfully created Odoo dev virtual machine."
echo ""
print_usage

