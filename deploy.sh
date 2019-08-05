# Tag the build as latest & the GIT_SHA (commit id)
docker build -t kuldeepaujla/multi-docker-worker-k8s:latest -t kuldeepaujla/multi-docker-worker-k8s:$GIT_SHA -f ./worker/Dockerfile ./worker
docker build -t kuldeepaujla/multi-docker-server-k8s:latest -t kuldeepaujla/multi-docker-server-k8s:$GIT_SHA -f ./server/Dockerfile ./server
docker build -t kuldeepaujla/multi-docker-client-k8s:latest -t kuldeepaujla/multi-docker-client-k8s:$GIT_SHA -f ./client/Dockerfile ./client

# Push latest tags
docker push kuldeepaujla/multi-docker-worker-k8s:latest
docker push kuldeepaujla/multi-docker-server-k8s:latest
docker push kuldeepaujla/multi-docker-client-k8s:latest

# Push GIT SHA Tags
docker push kuldeepaujla/multi-docker-worker-k8s:$GIT_SHA
docker push kuldeepaujla/multi-docker-server-k8s:$GIT_SHA
docker push kuldeepaujla/multi-docker-client-k8s:$GIT_SHA


# Deploy all deployment & services with kubectl
kubectl apply -f k8s

# Command to ensure kubernetes is using the latest image from docker hub. 
kubectl set image deployment/server-deployment server=kuldeepaujla/multi-docker-server-k8s:$GIT_SHA
kubectl set image deployment/client-deployment client=kuldeepaujla/multi-docker-client-k8s:$GIT_SHA
kubectl set image deployment/worker-deployment worker=kuldeepaujla/multi-docker-worker-k8s:$GIT_SHA
