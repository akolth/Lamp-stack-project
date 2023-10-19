#**Deployment of Vagrant Ubuntu Cluster with LAMP stack**
The objective of this project is to develop a bash script to orchestarate the automated deployment of two vagrant-based ubuntu systems wtih designations of "Master" and "Slave", with an integrated LAMP stack deployed on both systems.

**THIS PROJECT HAS THE FOLLOWING REQUIREMENTS**
- Virtual machine running ubuntu servers
- Apache2 
- Php
- MySQL Database 

**SETUP**
LAMP stack comprises of the following applications

Linux - The operating system hosting the applications
Apache - The free and open-source cross-platform web server software to be installed on the servers.
MySQL/MariaDB – open source relational database management system.
PHP – The programming/scripting language used for the development of  web applications.


**PREREQUISITES**
- VAGRANT
- VIRTUAL BOX

**DEEP DIVE**
My vagrant.sh script was configured to create two servers namely the "Master" and "Slave". This will contain a deep dive into the setup of each of the servers.
Memory assigned to each of the machines was 1024mb and 2 CPUS were assigned each.

**SLAVE MACHINE OVERVIEW**
Created a Slave Machine designated as "slave" using the "ubuntu/focal64" image , the machine is being hosted on a private network and being assigned with a public static IP address of "192.168.1.100"

**SLAVE MACHINE CONFIGURATION**
- Firstly an apt-update was run to update packages 

```bash
sudo apt-get update && sudo apt-get upgrade -y
```

- Then sshpass was installed to provide a password for the ssh command when trying to log in  via ssh
```bash
sudo apt install sshpass -y
```
- Then changes were made to the SSH server's configuration from disallowing password authentication (PasswordAuthentication no) to allowing password authentication (PasswordAuthentication yes)
```bash
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
```
-Then the SSH server service was stopped and then immediately restarted effect configuration changes 
```bash
sudo systemctl restart sshd
```

- Avahi-daemon was installed via 
```bash
sudo apt-get install -y avahi-daemon libnss-mdns
```

**MASTER MACHINE OVERVIEW**
Created a Master Machine designated as "Master" using the "ubuntu/focal64" image , the machine is being hosted on a private network and being assigned with a public static IP address of "192.168.1.100"

**MASTER MACHINE CONFIGURATION**
- We also run an apt-update and apt-upgrade to update packages on the master machine

```bash
sudo apt-get update && sudo apt-get upgrade -y
```

- Then sshpass was installed to provide a password for the ssh command when trying to log in  via ssh
```bash
sudo apt install sshpass -y
```

- Avahi-daemon was installed via 
```bash
sudo apt-get install -y avahi-daemon libnss-mdns
```

- Then changes were made to the SSH server's configuration from disallowing password authentication (PasswordAuthentication no) to allowing password authentication (PasswordAuthentication yes)
```bash
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
```
-Then the SSH server service was stopped and then immediately restarted effect configuration changes 
```bash
sudo systemctl restart sshd
```

- On the master node a user name "Altschool" was created 
```bash
sudo useradd -m -G sudo altschool
```

- An SSH key was generated for the user, and also bearing in mind the requirement for the user to be able to ssh into the slave node without requiring a password 

```bash
sudo -u altschool ssh-keygen -t rsa -b 4096 -f /home/altschool/.ssh/id_rsa -N "" -y
sudo cp /home/altschool/.ssh/id_rsa.pub altschoolkey
    sudo ssh-keygen -t rsa -b 4096 -f /home/vagrant/.ssh/id_rsa -N ""
    sudo cat /home/vagrant/.ssh/id_rsa.pub | sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@192.168.1.100 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'
    sudo cat ~/altschoolkey | sshpass -p "vagrant" ssh vagrant@192.168.1.100 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'
```

**MASTER & SLAVE**
- *LAMP STACK*
- Firstly i ran an update with the apt-update command then install apache2 and set up
```bash
sudo apt install apache2 -y
echo -e "\n\nAdding firewall rule to Apache\n"
sudo ufw allow in "Apache"
```
- Then i install MYSQL running this
```bash
echo -e "\n\nInstalling MySQL\n"
sudo apt install mysql-server -y
``` 

- I set the ownership of the /var/www directory and its contents to the www-data user and group
```bash
echo -e "\n\nPermissions for /var/www\n"
sudo chown -R www-data:www-data /var/www
echo -e "\n\n Permissions have been set\n"
```

- Then php is installed alongside it's dependencies 
```bash
sudo apt install php libapache2-mod-php php-mysql -y
```

- Next thing is enabling modules 
```bash
echo -e "\n\nEnabling Modules\n"
sudo a2enmod rewrite
sudo phpenmod mcrypt
```

- We now restart apache 
```bash
echo -e "\n\nRestarting Apache\n"
sudo systemctl reload apache2
```

- A LAMP stack will be installed on both master and slave once the script is run, then apache will be restarted.

-Also MYSQL server and client will be installed on both "SLAVE" and "MASTER" 

Finally the apache page can be accessed with my IP "192.168.1.100" and below is a display 

![A webpage displaying APACHE webpage](apachedisplay.jpg)