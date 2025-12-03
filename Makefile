.PHONY: init apply deploy test destroy

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
