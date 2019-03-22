sudo apt-get update 
sudo apt-get install -yq nginx 
sudo sh -c 'echo "Hi, this is VM with IP: $(curl ifconfig.io)" > /var/www/html/index.html'
