dockerTag = chadd944/liatrio:latest

build:
	docker build -t ${dockerTag} .
push:
	docker image push ${dockerTag}


infra-deploy: 
	aws cloudformation deploy --template-file amazon-eks-entrypoint-new-vpc.template.yaml --stack-name eks --parameter-overrides file://cfparams.json

deploy-api:
	kubectl apply -f automate.yml
