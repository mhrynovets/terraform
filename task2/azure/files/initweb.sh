sudo apt-get update 
sudo apt-get install -yq nginx 
sudo sh -c 'echo "Hi, this is VM <strong>$(hostname)</strong> with IP: $(curl ifconfig.io)" > /var/www/html/index.html'
