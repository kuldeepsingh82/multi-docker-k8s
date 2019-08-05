# multi-docker-k8s
​
Kubernetes deployment project for multi docker app. The application includes a react application, express back-end, a worker project, Postgres to persist the data and Redis in memory database.

## Local setup with minikube
	### Installation
	#### Install Kubectl

		Run following commands in your terminal

		1. Download the latest release with the command:

			curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

		2. Make the kubectl binary executable.

			chmod +x ./kubectl
		
		3. Move the binary in to your PATH.
		
			sudo mv ./kubectl /usr/local/bin/kubectl
			
		4. Test to ensure the version you installed is up-to-date:
			
			kubectl version
	
		Installtion steps can be found at https://kubernetes.io/docs/tasks/tools/install-kubectl/
		
		
	#### Install a VM driver virtualbox

		Run following commands in your terminal 

		sudo apt-get update
		sudo apt-get install apt-transport-https
		sudo apt-get upgrade
		
		sudo apt install virtualbox virtualbox-ext-pack


	#### Install Minikube

		1. Download the latest release with the command:

			wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

		2. Make the minikube binary executable.

			chmod +x minikube-linux-amd64

		3. Move the binary in to your PATH.

			sudo mv minikube-linux-amd64 /usr/local/bin/minikube

		4. Test to ensure the version you installed is up-to-date:

			minikube version

## Google cloud setup with Kubernetes Engine (GKE)

