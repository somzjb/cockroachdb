###Overview:
This script is used to provision cockroach db on AWS. The DB is distributed on set of AWS nodes. The traffic is served by a Network load balancer sitting in front of the EC2 instances.

##Provision:
The script takes care of automating in provisioning of resources that are required in local as well on the AWS using terraform and ansible. The AWS infra are provisioned using terraform. while its configuration are handled by ansible code. A shell script is created to run bot the terraform modules and ansible playbooks required.
   #Usage: 
	./create_cockroach <cockroach_version>
	example: ./create_cockroach 21.1.2

##Prerequisities:
1. This automation provisions resources in public network(public subnet)
2. variables for terraform EC2 provisioning needs to be provided in the terraform variables file residing under "terraform" directory
3. The main.tf (terraform main module) consists of placeholders that should be replaced with appropriate value before executing. 
4. This script should be run on linux environment with user have sudo permission both locally and remotely. P.S: The normal user should not required a password to assume sudo (both local and remote)
5. Ubuntu AMI is used for hosting the db nodes and hence ubuntu user is hardcorded as remote user for now.
