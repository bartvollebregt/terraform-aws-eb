# terraform-aws-eb (Single Docker container)
This repository contains an infrastructure set-up with Terraform and AWS EB to setup CI/CD
It contains:
- A Terraform setup for an AWS Elastic Beanstalk single docker container application.
- A deploy.sh bash script to deploy new versions to your AWS EB application
- An example Jenkinsfile
- A clean.sh script to clean generated stuff

## Prerequisites
- Terraform ([here](https://www.terraform.io/downloads.html))

## Getting started
### Terraform
- `cd` to the infrastructure directory
- Run `terraform init`
- If you haven't already, run `aws configure --profile your-profile-name` to configure your AWS profile
- Replace the variables in terraform.tfvars with your own
- Set your custom ENV variables like `export TF_VAR_env_custom_variable=test` or fill them in manually in the next step.
- Run `terraform apply`
- That's it! Elastic beanstalk is now live

### Deployments
- `cd` to the root of your project
- Make sure you have Dockerized your application (there must be a Dockerfile in the root)
- Set AWS credentials as environment variables:
    ```bash
    export AWS_ACCOUNT_ID=yourvalue
    export AWS_ACCESS_KEY_ID=yourvalue
    export AWS_SECRET_ACCESS_KEY=yourvalue
    ```
- Run `bash infrastructure/deploy.sh your-application-name playground eu-west-1 $(git rev-parse HEAD)`
- Checkout how your app is running in the AWS Console :D

### Jenkins
- In Jenkins, create a [pipelines Job] (https://jenkins.io/doc/book/pipeline/)
- Make sure it triggers on the branch you are pushing to 
- Add the Jenkinsfile from the example and fill in the variables with yours.
- Push to the branch :D

## License

terraform-aws-eb is released under the [MIT License](LICENSE).