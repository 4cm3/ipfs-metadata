# ipfs-metadata

This is a simple approach to deploy the application to ECS. Foundations are written in terraform and some steps are manual. However it's a MVP that can be improved over time aiming to have a full automated CI/CD pipeline.

The application runs on a ECS cluster, inside a service created on public subnets. It connects to a postgresql RDS database that lives on a private subnet. Communication is controlled by a security group.

Users can access the application trough an ALB that uses the main endpoint as a healthcheck.

Due to time constraints the build and deploy needs to be done manually.

Another key points:

* Designed for multiple environments (dev, stage, prod)
* A new version of the app can be deployed without changing the terraform code
* Basic logging by default

## Build and run application

A Dockerfile is provided for you to build the application and test it locally. You need to setup the connection between the ipfs container and the postgres DB. Also in order to not have sensitive value inside the docker image, you can pass the parameters when running the container as env variables.

```
docker run -e POSTGRES_USER=youruser -e POSTGRES_PASSWORD=yourpassword -e POSTGRES_DB=yourdb -e POSTGRES_HOST=localhost -e POSTGRES_PORT=5432 ipfs-metadata:latest
```

## CI/CD pipeline

Everything will run from GHA, so you need to configure the repository first:

* Create following AWS variables as secrets in the github repository.

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION
```

After you push to main, run https://github.com/4cm3/ipfs-metadata/actions/workflows/build-and-push-container.yml to create a new image and put the URL to an SSM parameter.

## Deploy infrastructure with terraform

Detailed documentation can be found in [../infrastructure/README.md](../infrastructure/README.md)

## Deploy application

Right now, to deploy the application run `terraform apply` on `infrastructure/dev/ecs/` directory to update the task definition.

## Nice to have

A list of next steps to improve the app, no specific order:

* Build a new docker image after every push to `main`
* Implement stage and prod environments. Build and deploy a new docker image based on the branch: When a new commit is pushed to `dev` branch it CI/CD will deploy that image to the dev environment for testing. Better if we have those on different AWS accounts.
* Run terraform changes from CI/CD. Some tools that can be used are [octopus](https://octopus.com/docs/deployments/terraform), [hcp terraform](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-sign-up) or a custom set of actions.
* Create a proper healthcheck for the app and use it for deployments.
* Integrate ECS with cloudwatch alarms to ensure the application is healty. Also to detect errors after a deploy
* Send AWS messages (from deployments, cloudwatch and other changes) to slack or another tool with full visibility for the rest of the team.
* Implement circuit breaker for deployments (rollback when the new deployment fails)
* Review permissions of the account that interact with AWS from CI/CD.
* Add a third party tool like pindgom to check the status of the app.
* Start implementing [CIS Compliance](https://docs.gruntwork.io/guides/build-it-yourself/achieve-compliance/core-concepts/intro)