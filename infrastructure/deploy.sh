#!/bin/bash
# Script used to deploy applications to AWS Elastic Beanstalk
# Should be hooked to CircleCI post.test or deploy step
#
# Does three things:
# 1. Builds Docker image & pushes it to container registry
# 2. Generates new `infrastructure/Dockerrun.aws.json` file which is Beanstalk task definition
# 3. Creates new Beanstalk Application version using created task definition
#
# REQUIREMENTS!
# - AWS_ACCOUNT_ID env variable
# - AWS_ACCESS_KEY_ID env variable
# - AWS_SECRET_ACCESS_KEY env variable
#
# usage: ./deploy.sh name-of-application staging us-east-1 f0478bd7c2f584b41a49405c91a439ce9d944657

set -e
start=`date +%s`

# Name of your application, should be the same as in setup
NAME=$1

# Stage/environment e.g. `staging`, `test`, `production``
STAGE=$2

# AWS Region where app should be deployed e.g. `us-east-1`, `eu-central-1`
REGION=$3

# Hash of commit for better identification
SHA1=$4

if [ -z "$NAME" ]; then
  echo "Application NAME was not provided, aborting deploy!"
  exit 1
fi

if [ -z "$STAGE" ]; then
  echo "Application STAGE was not provided, aborting deploy!"
  exit 1
fi

if [ -z "$REGION" ]; then
  echo "Application REGION was not provided, aborting deploy!"
  exit 1
fi

if [ -z "$SHA1" ]; then
  echo "Application SHA1 was not provided, aborting deploy!"
  exit 1
fi

if [ -z "$AWS_ACCOUNT_ID" ]; then
  echo "AWS_ACCOUNT_ID was not provided, aborting deploy!"
  exit 1
fi

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "AWS_ACCESS_KEY_ID was not provided, aborting deploy!"
  exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "AWS_SECRET_ACCESS_KEY was not provided, aborting deploy!"
  exit 1
fi

EB_BUCKET=${NAME}-deployments
ENV=${NAME}-${STAGE}
VERSION=${STAGE}-${SHA1}-$(date +%s)
ZIP=${VERSION}.zip

echo Deploying ${NAME} to environment ${STAGE}, region: ${REGION}, version: ${VERSION}, bucket: ${EB_BUCKET}, account_id ${AWS_ACCOUNT_ID}

aws configure set default.region ${REGION}
aws configure set default.output json

# Login to AWS Elastic Container Registry
eval $(aws ecr get-login --no-include-email --region ${REGION})

# Build the image
docker build -t ${NAME}:${VERSION} .
# Tag it
docker tag ${NAME}:${VERSION} ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${NAME}:${VERSION}
# Push to AWS Elastic Container Registry
echo "docker push $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$NAME:$VERSION"
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${NAME}:${VERSION}

# Copy over to real file since we're going to do some sed's in it.
cp -f infrastructure/Dockerrun.aws.template.json infrastructure/Dockerrun.aws.json

# Replace the <AWS_ACCOUNT_ID> with your ID
sed -i='' "s/<ACCOUNT_ID>/$AWS_ACCOUNT_ID/" infrastructure/Dockerrun.aws.json
# Replace the <NAME> with the your name
sed -i='' "s/<NAME>/$NAME/" infrastructure/Dockerrun.aws.json
# Replace the <REGION> with the selected region
sed -i='' "s/<REGION>/$REGION/" infrastructure/Dockerrun.aws.json
# Replace the <TAG> with the your version number
sed -i='' "s/<VERSION>/$VERSION/" infrastructure/Dockerrun.aws.json

# Zip up the Dockerrun file
zip -j -r ${ZIP} infrastructure/Dockerrun.aws.json

# Send zip to S3 Bucket
aws s3 cp ${ZIP} s3://${EB_BUCKET}/${ZIP}


# Create a new application version with the zipped up Dockerrun file
aws elasticbeanstalk create-application-version --application-name ${NAME} --version-label ${VERSION} --source-bundle S3Bucket=${EB_BUCKET},S3Key=${ZIP}

# Update the environment to use the new application version
aws elasticbeanstalk update-environment --environment-name ${ENV} --version-label ${VERSION}

end=`date +%s`

rm ${ZIP}

echo Deploy ended with success! Time elapsed: $((end-start)) seconds


