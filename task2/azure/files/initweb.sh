sudo apt-get update 
sudo apt-get install -yq nginx 
sudo sh -c 'echo "Hi, this is VM <strong>$(hostname)</strong> with IP: <strong>$(curl ifconfig.io)</strong>" > /var/www/html/index.html'
