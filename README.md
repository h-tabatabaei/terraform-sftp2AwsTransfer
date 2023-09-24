# terraform-sftp2AwsTransfer
Terraform Infrastructure code to deploy awsTransferFamiliy with S3 Backend.

## Usage

### Define AWS Infrastructure

`````sh
terraform init
terraform fmt
terraform plan
terraform apply
`````

the code will make and specific private s3 bucket.
then create related IAM role and policy to make allow access form transfer service to put objects within s3 bucket.
then will create a transfer server and ssh key pair. in addition will create MyAWSKey.pem file as private key in root directory of the code.
finally will create a username called "msdtbt" with associate public key from key pair.

make use of the outputs to create connection via filezilla or any other sftp clients.
the outputs are:
	Transfer_srv_endpoint = "endpoint address which will be used as a hostname in sftp connection via ftp client app."
	Transfer_srv_username = "msdtbt"
	s3_bucket_id = "arn of defined s3 bucket as a backend storage for aws transfer family service."

### configure the filezilla as ftp client
create a new connection in filezilla:

	Protocol: SFTP File Transfer Protocol
	HOST: "Transfer_srv_endpoint"

	Login Type: Key File
	User: "Transfer_srv_username"
	Key File: "path to MyAWSKey.pem"

