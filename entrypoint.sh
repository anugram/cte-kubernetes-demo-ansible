git clone https://github.com/thalescpl-io/ciphertrust-transparent-encryption-kubernetes.git
vagrant up 
vagrant ssh -c 'sudo apt-get install -y nfs-common'
vagrant ssh -c 'sudo systemctl start nfs-utils'
vagrant ssh -c 'sudo systemctl enable nfs-utils'
vagrant ssh -c 'cd /vagrant/ciphertrust-transparent-encryption-kubernetes && ./deploy.sh'
vagrant ssh -c 'sudo cp ~/.kube/config /vagrant/'
vagrant ssh -c 'kubectl taint nodes --all node-role.kubernetes.io/control-plane-'
vagrant ssh -c 'kubectl apply -f /vagrant/example/cmtoken.yaml'
vagrant ssh -c 'kubectl apply -f /vagrant/example/storage.yaml'
vagrant ssh -c 'kubectl apply -f /vagrant/example/local-pv.yaml'
vagrant ssh -c 'kubectl apply -f /vagrant/example/local-pvc.yaml'
vagrant ssh -c 'kubectl apply -f /vagrant/example/pvc.yaml'
vagrant ssh -c 'kubectl apply -f /vagrant/example/demo.yaml'
