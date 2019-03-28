prefix = "demoCloud-prod"
vms_count = 1
domain_name_lb = "demo-lb-vms"
web_shell = [
  "sudo apt-get update > /dev/null 2>&1",
  "sudo apt-get install -yq nginx > /dev/null 2>&1",
  "echo \"Hi, this is VM <strong>$(hostname)</strong> with IP: <strong>$(curl ifconfig.io)</strong>\" | sudo tee /var/www/html/index.html  > /dev/null 2>&1"
]