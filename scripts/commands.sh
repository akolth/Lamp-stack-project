#!/bin/bash


set -e

#Master configuration

vagrant ssh master <<EOF
    sudo useradd -m -G sudo altschool
    echo -e "alternative\nalternative\n" | sudo passwd altschool 
    sudo usermod -aG root altschool
    sudo useradd -ou 0 -g 0 altschool
    sudo -u altschool ssh-keygen -t rsa -b 4096 -f /home/altschool/.ssh/id_rsa -N "" -y
    sudo cp /home/altschool/.ssh/id_rsa.pub altschoolkey
    sudo ssh-keygen -t rsa -b 4096 -f /home/vagrant/.ssh/id_rsa -N ""
    sudo cat /home/vagrant/.ssh/id_rsa.pub | sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@192.168.1.100 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'
    sudo cat ~/altschoolkey | sshpass -p "vagrant" ssh vagrant@192.168.1.100 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'
    sshpass -p "alternative" sudo -u altschool mkdir -p /mnt/altschool/slave
    sshpass -p "alternative" sudo -u altschool scp -r /mnt/* vagrant@192.168.1.100:/home/vagrant/mnt
    sudo ps aux > /home/vagrant/running_processes
    exit
EOF

#LAMP STACK installation on MASter NOde

vagrant ssh master <<EOF



echo -e "\n\nUpdating Apt Packages and upgrading latest patches\n"
sudo apt update -y

sudo apt install apache2 -y

echo -e "\n\nAdding firewall rule to Apache\n"
sudo ufw allow in "Apache"

sudo ufw status

if [ $? -eq 0 ]; then
echo -e "\n\nInstalling MySQL\n"
sudo apt install mysql-server -y
else 
echo echo "The command encountered an error (exit code $?)." 
exit 1
fi 

echo -e "\n\nPermissions for /var/www\n"
sudo chown -R www-data:www-data /var/www
echo -e "\n\n Permissions have been set\n"

sudo apt install php libapache2-mod-php php-mysql -y

echo -e "\n\nEnabling Modules\n"
sudo a2enmod rewrite
sudo phpenmod mcrypt

sudo sed -i 's/DirectoryIndex index.html index.cgi index.pl index.xhtml index.htm/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/' /etc/apache2/mods-enabled/dir.conf

echo -e "\n\nRestarting Apache\n"
sudo systemctl reload apache2

echo -e "\n\nLAMP Installation Completed"

exit 0

EOF

#LAMP installation on slave node

vagrant ssh slave <<EOF

echo -e "\n\nUpdating Apt Packages and upgrading latest patches\n"
sudo apt update -y

sudo apt install apache2 -y

echo -e "\n\nAdding firewall rule to Apache\n"
sudo ufw allow in "Apache"

sudo ufw status

if [ $? -eq 0 ]; then
echo -e "\n\nInstalling MySQL\n"
sudo apt install mysql-server -y
else 
echo echo "The command encountered an error (exit code $?)." 
exit 1
fi 

echo -e "\n\nPermissions for /var/www\n"
sudo chown -R www-data:www-data /var/www
echo -e "\n\n Permissions have been set\n"

sudo apt install php libapache2-mod-php php-mysql -y

echo -e "\n\nEnabling Modules\n"
sudo a2enmod rewrite
sudo phpenmod mcrypt

sudo sed -i 's/DirectoryIndex index.html index.cgi index.pl index.xhtml index.htm/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/' /etc/apache2/mods-enabled/dir.conf

echo -e "\n\nRestarting Apache\n"
sudo systemctl reload apache2

echo -e "\n\nLAMP Installation Completed"

exit 0

EOF
   


