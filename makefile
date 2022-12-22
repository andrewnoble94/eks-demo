docker_tag = chadd944/liatrio:latest
eks_name = $(shell aws cloudformation --profile personal describe-stacks --stack-name eks | jq .Stacks[0].Outputs[1].OutputValue)
aws_profile = personal
elb = $(shell kubectl get svc -o json liatrio-demo-api | jq .status.loadBalancer.ingress[0].hostname)

build:
	@echo docker build...
	docker build -t ${docker_tag} .
push:
	@echo push to docker hub..
	docker image push ${docker_tag}

infra-deploy: 
	@echo deploy EKS cfn stack...
	aws cloudformation deploy --profile $(aws_profile) --template-file amazon-eks-entrypoint-new-vpc.template.yaml --stack-name eks --parameter-overrides file://cfparams.json --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND

deploy-api:
	@echo deploy flask app to EKS..
	kubectl apply -f automate.yml

test-env:
	@echo check status of cfn stack...
	aws cloudformation --profile $(aws_profile) describe-stacks --stack-name eks | jq .Stacks[0].StackStatus

	@echo check $(eks_name) cluster status...
	aws eks describe-cluster --profile $(aws_profile) --name ${eks_name} | jq .cluster.status

test-deploy:
	@echo ELB is $(elb)
	curl $(elb)/automate

destroy:
	aws cloudformation delete-stack --profile $(aws_profile) --stack-name eks