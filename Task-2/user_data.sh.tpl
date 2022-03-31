#!/bin/bash
yum -y update
yum -y install nginx


myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

cat <<EOF > /var/www/html/index.html
<html>
<h2>Build by Power of Terraform <font color="red"> v0.12</font></h2><br>
</html>
EOF

sudo service nginx start
chkconfig nginx on
