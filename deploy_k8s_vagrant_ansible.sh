#!/bin/bash
vagrant up
vagrant ssh -c 'sudo apt-get install -y nfs-common'
vagrant ssh -c 'sudo systemctl start nfs-utils'
vagrant ssh -c 'sudo systemctl enable nfs-utils'
vagrant ssh -c 'mkdir -p /tmp/data'
vagrant ssh -c 'sudo chmod 777 /tmp/data'
vagrant ssh -c 'sudo systemctl enable nfs-utils'
vagrant ssh -c 'cd /vagrant/ciphertrust-transparent-encryption-kubernetes && ./deploy.sh'
vagrant ssh -c 'sudo cp ~/.kube/config /vagrant/'
