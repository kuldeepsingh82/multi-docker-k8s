# multi-docker-k8s

Kubernetes deployment project for multi docker app. The application includes a react application, express back-end, a worker project, Postgres to persist the data and Redis in memory database.

Overall architecture of the application looks like :
![enter image description here](https://github.com/kuldeepsingh82/multi-docker-k8s/blob/master/docs/images/k8s-arch.jpg)
# # Local setup with minikube

## a. Installation
### Install Kubectl

Run following commands in your terminal to install kubectl 

	# curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
	# chmod +x ./kubectl
	# sudo mv ./kubectl /usr/local/bin/kubectl
	
	Verify Installation by
	# kubectl version

Installtion steps can be found at https://kubernetes.io/docs/tasks/tools/install-kubectl/
		
### Install a VM driver virtualbox

Run following commands in your terminal 

	# sudo apt-get update
	# sudo apt-get install apt-transport-https
	# sudo apt-get upgrade
	
	# sudo apt install virtualbox virtualbox-ext-pack

### Install Minikube


	# wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
	# chmod +x minikube-linux-amd64
	# sudo mv minikube-linux-amd64 /usr/local/bin/minikube
	
	Verify Installation by
	# minikube version
	
	Start miniqube
	# minikube start	

Installation steps can be found here https://kubernetes.io/docs/tasks/tools/install-minikube/ 


## b. Verify minikube & kubectl cluster


	Verify minikube is running
	# minikube status
	
	Verify kubectl cluster
	# kubectl cluster-info
	
## d. Create Kubernetes configuration files

1. Deployment configuration files for server, client and worker
2. ClusterIP configuration files for server and client
3. Deployment configuration for Postgres and Redis 
4. ClusterIP configuration files for Postgres and Redis

## e. Create Persistent Volume Claim for Postgres

1. Create persistent volume claim 
2. Attach volumes from PVC in postgres deployment configuration file

## f. Define constant environment variables

1. Add constant environment variables in server for redis and postgres configuration
2. Add constant environment variables in worker for redis configuration

## g. Define Secret object and update environment variables

For Secret objects we have to use imperative commands instead of configuration files

1. Generate the Secret object
	kubectl create secret generic <secret_name> --from-literal key=value

	More details : https://kubernetes.io/docs/concepts/configuration/secret/
	
2. Get the password from secret object and update in server deployment configuration file.
3. Update postgres deployment configuration to update the default password  

## h. Configure Ingress service for minikube

#### Installation
We are going to use https://kubernetes.github.io/ingress-nginx/ 

Run mandatory command

	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml

Enable ingress addon in minikube

	minikube addons enable ingress

#### Define ingress service configuration 

Create ingress service configuration with the required paths/routes mapping


## i. Apply all configurations & Test

Apply all configurations with kubectl

	# kubectl apply -f k8s

Get the minikube ip

	# minikube ip

Open your browser and test the application with the minikube ip


## j. Continuous Development with Skaffold

This will work only if our apps have ability to refresh the changes automatically on any file change. Fortunately, react app refresh itself and nodemon for express also refresh the apps in case of any change. Lets install and configure Skaffold for our development environment

1. Install Skaffold on our local machine (https://skaffold.dev/docs/getting-started/)

	* curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64

	* chmod +x skaffold

	* sudo mv skaffold /usr/local/bin

2. Verify Skaffold by **skaffold version** command
3. Create skaffold.yaml configuration file in the project main directory for different projects.
4. Start skaffold by **skaffold dev**

## Commonly used minikube commands

	Start minikube
	# minikube start
	
	Stop minikube
	# minikube stop

	Delete minikube VM & kubernetes cluster
	# minikube delete

	minikube status
	# minikube status

	Get the IP of the minikube VM
	# minikube ip

	minikube dashboard
	# minikube dashboard
	
	Get minikube docker environment
	# minikube docker-env
	
	Connect to minikube docker environment (configure your shell)
	# eval $(minikube docker-env)
	

## Commonly used kubectl commands 


	Verify kubectl cluster
	# kubectl cluster-info
	
	Create/Update objects in kubectl
	# kubectl apply -f <object-config-file.yaml>
	OR for multiple files
	# kubectl apply -f <folder_name>
	
	Note : update the object name & kind of the object has to be same
	
	Get objects
	# kubectl get <object_type>
	Object type such as pods, deployments, services etc
	
	Describe object
	# kubectl describe <object_type> <object_name>
	
	Imperative Command to update a object image
	# kubectl set image <object_type>/<object_name> <container_name> = <new_image_to_use>
	
	Example : kubectl set image deployment/client-deployment client = kuldeepaujla/multi-docker-client-k8s:v1.3
	

# # Google cloud setup with Kubernetes Engine (GKE) with Travis CI

## a. Link your github repository with Travis CI

## b. Create google cloud project

1. Create a new google cloud project at https://console.cloud.google.com
2. Select this new project and enable billing account for the project
3. Create a Kubernetes Engine cluster on Google Cloud. Use zone close to you and select node pods and machine as per your project requirement.
4. Create a Service Account (IAM & Admin) and download the service account credentials json file (Should be encrypted before using it on Travis CLI CI)
5. Rename the file to service-account.json
6. Encrypt this service-account.json file with Travis CLI CI (Travis Client). Process given below


## c. Encrypt file with Travis CLI CI (With Temporary Ruby Container)

Go to the directory where you have your service-account.json file

Run following command to connect to rube docker container shell
	
	docker run -it -v "$(pwd):/app" ruby:2.3 sh

Install travis CLI in this container

	gem install travis

Login to travis CI on this container shell with your github username/password

	travis login
 
 Encrypt the service-account.json file with following command

	travis encrypt-file service-account.json -r kuldeepsingh82/multi-docker-k8s

Here kuldeepsingh82/multi-docker-k8s is the travis repository name (case sensitive)

The above command will encrypt the file and generate a command which we have to add in travis.yaml file in before_install stage. Add that command in the travis configuration file

The command will also generate a **service-account.json.enc** Add this file to root directory of your repository. Travis will read this and decrypt it before passing it to google cloud.
 
## d. Create travis configuration file

1. Setup Google Cloud Kubernetes Engine
2. Git SHA for Image tagging purpose
3. Docker Login command (**Remember to add the DOCKER_USER & DOCKER_PASSWORD on Travis for this repository again**)
4. Test command / script
5. Deploy script (deploy.sh)

## e. Configure Ingress service for Google Cloud

### Installation (Without Helm)
We are going to use https://kubernetes.github.io/ingress-nginx/ 

Run mandatory command & GCE - GKE command

	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml

### Installation (With Helm & Tiller) - Recommended

We are going to use https://github.com/helm/helm for Helm installation

**A.** Install Helm (https://helm.sh/docs/using_helm/#quickstart-guide)
 We need to run the following commands in our **google cloud shell**

	# curl -LO https://git.io/get_helm.sh
	# chmod 700 get_helm.sh
	# ./get_helm.sh

**B.** Do extra setup for GKE (Because RBAC is enabled by default). Create a service account and create a role binding & assign it to Tiller so that tiller have right permission to modify our cluster. Run the following commands in **google cloud shell**

	# kubectl create serviceaccount --namespace kube-system tiller
	# kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller


**C.** Initialize Helm in Google Cloud Shell

	# helm init --service-account tiller --upgrade

**D.** Install ingress-nginx using Helm
We are going to use https://kubernetes.github.io/ingress-nginx/ ingress nginx installation (using helm section)

	# helm install stable/nginx-ingress --name my-nginx --set rbac.create=true

* This command will create ingress and load balancer (with some IP) services
* This command will also create ingress controller and default backend workload

## f. Create Kubernetes configuration files (Same as with minikube)

1. Deployment configuration files for server, client and worker
2. ClusterIP configuration files for server and client
3. Deployment configuration for Postgres and Redis 
4. ClusterIP configuration files for Postgres and Redis

## g. Create Persistent Volume Claim for Postgres (Same as with minikube)

1. Create persistent volume claim 
2. Attach volumes from PVC in postgres deployment configuration file

## h. Define constant environment variables (Same as with minikube)

1. Add constant environment variables in server for redis and postgres configuration
2. Add constant environment variables in worker for redis configuration

## g. Define Secret object and update environment variables

For Secret objects we have to use imperative commands instead of configuration files

Generate the Secret object (**On Google Cloud Shell**)

	kubectl create secret generic <secret_name> --from-literal key=value

More details : https://kubernetes.io/docs/concepts/configuration/secret/
	
2. Get the password from secret object and update in server deployment configuration file.
3. Update postgres deployment configuration to update the default password

## h. Push your changes to github

It should start the test on Travis and then build should be deployed on Google Kubernetes Cluster

Open your browser and test the application with the Google Cloud Load Balance IP

## i. Enable SSH (Lets Encrypt)

1. Buy a domain name

2. Configure the domain (along with www), change the DNS configuration to point to google cloud cluster IP (load balancer IP)

3. We will use project named Cert Manager to install the certificates (https://github.com/jetstack/cert-manager)

4. Go to https://docs.cert-manager.io/en/latest/getting-started/install/kubernetes.html and follow the steps defined in section Installing with helm.

5. Create issuer.yaml configuration file, to tell who is the issuer of the certificate (letsencrypt in our case)

6. Create certificate.yaml configuration file (Details about the certificate and domains)

7. Deploy this, to get the certificates.

8. Reconfigure the ingress service configuration file for the https configuration

