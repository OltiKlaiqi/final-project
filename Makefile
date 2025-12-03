.PHONY: init apply deploy test destroy docker-build docker-load

docker-build:
	docker build -t demo-api:latest app/api
	docker build -t demo-worker:latest app/worker
	docker images | grep demo

docker-load:
	kind load docker-image demo-api:latest
	kind load docker-image demo-worker:latest

init:
	terraform init -backend=false

apply:
	terraform apply -auto-approve

deploy:
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/api-deployment.yaml
	kubectl apply -f k8s/worker-deployment.yaml
	kubectl apply -f k8s/hpa.yaml
	kubectl apply -f k8s/demo-api-servicemonitor.yaml
	kubectl apply -f k8s/demo-worker-servicemonitor.yaml
	kubectl apply -f alerts/demo-alerts.yaml

test:
	curl http://localhost:8080/hello
	curl http://localhost:8080/metrics

destroy:
	kubectl delete -f alerts/demo-alerts.yaml
	kubectl delete -f k8s/demo-api-servicemonitor.yaml
	kubectl delete -f k8s/demo-worker-servicemonitor.yaml
	kubectl delete -f k8s/hpa.yaml
	kubectl delete -f k8s/api-deployment.yaml
	kubectl delete -f k8s/worker-deployment.yaml
	terraform destroy -auto-approve
