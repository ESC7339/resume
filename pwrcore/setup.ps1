
$dockerComposeFile = "docker-compose.yml"
$ansibleDirectory = "ansible"
$inventoryFile = "$ansibleDirectory/inventory"
$playbookFile = "$ansibleDirectory/playbook.yml"
$configFile = "$ansibleDirectory/ansible.cfg"

if (-Not (Test-Path $ansibleDirectory)) {
    New-Item -ItemType Directory -Path $ansibleDirectory
}


@"
[cisco_devices]
192.168.1.1
192.168.1.2

[cisco_devices:vars]
ansible_connection=network_cli
ansible_network_os=ios
ansible_user=your_username
ansible_password=your_password
"@ | Out-File -FilePath $inventoryFile -Encoding UTF8


@"
- name: Test connection to Cisco devices
  hosts: cisco_devices
  gather_facts: no
  tasks:
    - name: Ping Cisco device
      ios_ping:
        dest: 8.8.8.8
        count: 5
"@ | Out-File -FilePath $playbookFile -Encoding UTF8


@"
[defaults]
inventory = /etc/ansible/inventory
"@ | Out-File -FilePath $configFile -Encoding UTF8


docker-compose -f $dockerComposeFile up -d


docker exec -it ansible ansible-playbook /etc/ansible/playbook.yml
