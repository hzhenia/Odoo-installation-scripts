#!/bin/bash

###################################################################
## Please note that this script is yet to be tested            ####
## on most debian based distro but expect errors and           ####
## you can always go step by step executing the commands.      ####
## If you choose so, note, that where there is $odoouser,       ###
## replace with the "odoouser" account. With that in mind,      ### 
## shit happens!!!.  :-( ..... )-:                              ###  
###################################################################

#################################################
## NB:                                        ###
## -------                                    ###
## For a better version, try goo.gl/aXWe8P    ###
##                                            ###                                            
#################################################
echo ""
echo "     Odoo 10 Installation Script"
echo "-----------------------------------------------"
echo "(+) Author: Kev"
echo "(+) Date: 1/12/2017"
echo "(+) OTB Africa"
echo "-----------------------------------------------"
echo ""
echo ""
echo "Odoo installation Details"
echo "-----------------------------------------------"
read -p "1.) Enter odoo user:"  odoouser
read -p "3.) odoo version:" version
echo ""
echo "NB"
echo "----"
echo "$odoouser, please note that for installation the path /opt/odoo is used."
echo "The assumption is that you want to install multiple versions of odoo so"
echo "you had already installed odoo before in /opt"
echo ""
echo "-----------------------------------------------"
echo ""
echo "(+)Creating the new user $odoouser..."
#Create a new user in the system to operate on odoo framework.
sudo adduser --system --quiet --shell=/bin/bash --home=opt/odoo/"$odoouser" --gecos '$odoouser' --group "$odoouser"
echo ""
echo "Finished!"
echo "-----------------------------------------------"


#create a directory for configuration files and logging
echo "(+)Creating config and log directory..."
sudo mkdir /etc/"$odoouser" && mkdir /var/log/"$odoouser"
echo ""
echo "Finished!"
echo "-----------------------------------------------"



#install odoo dependancies
echo "(+)Installing postgres, node js, python dependancies and linux libs..."
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install postgresql postgresql-server-dev-9.5 
build-essential python-imaging python-lxml python-ldap python-dev 
libldap2-dev libsasl2-dev npm nodejs git python-setuptools 
libxml2-dev libxslt1-dev libjpeg-dev python-pip gdebi -y
echo ""
echo "Finished!"
echo "-----------------------------------------------"


#Git clone odoo to the directory
echo "(+)Cloning odoo from github to /opt/odoo/$odoouser"
git clone --depth=1 --branch="$version" https://github.com/odoo/odoo.git /opt/odoo/"$odoouser"
echo ""
echo "Finished!"
echo "-----------------------------------------------"


#Change group and ownership of odoo and install python required modules.
echo "(+)Change dir ownership and assign group access rights to $odoouser..."
sudo chown "$odoouser":"odoouser" /opt/odoo/"$odoouser" -R
sudo chown "odoouser":"odoouser" /var/log/"$odoouser"/ -R 
cd /opt/odoo/"odoouser"
echo"Done"
echo "-----------------------------------------------"
echo ""
echo "(+)Installing odoo python dependancies from pip"
sudo pip install --upgrade pip 
sudo pip install -r requirements.txt
echo ""
echo "Finished!"
echo "-----------------------------------------------"

#Install node js and related modules and create sys links
echo "(+)Install node js modules needed for web view etc..."
sudo npm install -g less less-plugin-clean-css -y
sudo ln -s /usr/bin/nodejs /usr/bin/node
echo ""
echo "Finished!"
echo "-----------------------------------------------"

#Install wkhtmltopdf
echo "(+)Now we install a tool to make pdfs, please note that this can be tricky so best to visit"
echo "   https://wkhtmltopdf.org/downloads.html for your system/PC and install."
echo "" 
cd /tmp && wget http://ftp.debian.org/debian/pool/main/w/wkhtmltopdf/wkhtmltopdf-dbg_0.12.3.2-3_amd64.deb
sudo gdebi -n wkhtmltopdf-dbg_0.12.3.2-3_amd64.deb
sudo rm wkhtmltopdf-dbg_0.12.3.2-3_amd64.deb
echo ""
echo "Finished!"
echo "-----------------------------------------------"

#Sys Link the required wkhtmltopdf binaries
echo "(+)--> Create sys links of the binaries..."
sudo ln -s /usr/local/bin/wkhtmltopdf /usr/bin/ 
sudo ln -s /usr/local/bin/wkhtmltoimage /usr/bin/
echo ""
echo "Finished!"
echo "-----------------------------------------------"


#Create odoo prosgres user in DB
sudo su - postgres -c "createuser -s $odoouser" 
echo ""
echo "Finished!"
echo "-----------------------------------------------"


#Generate config file and move it to /etc/odoo
echo "(+)Making Odoo work like a charm by, creating config file and moving it to /etc/$odoouser"
echo""
sudo su - odoo -c "/opt/odoo/$odoouser/odoo-bin --addons-path=/opt/odoo/$odoouser/addons -s --stop-after-init"

sudo mv /opt/odoo/"$odoouser"/.odoorc /etc/odoo/odoo.conf  
echo ""
echo "Finished!"
echo "-----------------------------------------------"


#Making odoo a service
echo "(+) Make odoo a service..."
sudo cp /opt/odoo/"$odoouser"/debian/init /etc/init.d/odoo-bin && chmod +x /etc/init.d/odoo-bin

sudo ln -s /opt/odoo/"odoouser"/odoo-bin /usr/bin/odoo

sudo update-rc.d -f odoo-bin start
echo ""
echo "Finished!"
echo "-----------------------------------------------"

#finally test if this shit is working :/
echo "(+)If odoo works well until this point without any editing, Your good!"
echo "   but,...."
echo ""
sudo su "$odoouser" -s /bin/bash
odoo-bin -w "$odoouser"
echo ""
echo "Finished!"
echo "-----------------------------------------------"
echo ""
echo "Over and Out!!!!!!"






