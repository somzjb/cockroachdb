#!/bin/bash

#check if the cockroach version in provided
if [[ $# -eq 0 ]] ; then
    echo "Cockroach version is not provided... Please provide one"
    exit 1
fi

export ANSIBLE_HOST_KEY_CHECKING=False
#set current working directory as base path
BASE_PATH=$(pwd)
cockroach_version=$1

#----------create cockroach locally-------------------#
if [[ $(cockroach | grep "^cockroach: command not found$") ]] || [[ ! -f "/usr/local/bin/cockroach" ]]
then
      cd $BASE_PATH/ansible
      ansible-playbook -i localhost, install-cockroach-local.yaml --extra-vars="cockroach_version=$1" --connection=local --user=$USER
      if [[ $? != 0 ]]; then
	     echo "Cant install cockroach locally"
	     exit 1
      fi
else
echo "Cockcroach already present locally....."
fi

#---------------provision AWS resources----------------------#
cd $BASE_PATH/terraform
terraform apply -auto-approve -var-file="cockroach.tfvars"

if [[ $? == 0 ]] 
then
	ec2_instances=$(terraform output ec2_instances | paste -s | sed 's/^.//' | sed 's/.$//' | sed 's/[[:space:]]//g' | sed 's/\"//g')
	elb_dns_name=$(terraform output elb_dns_name)
	cd $BASE_PATH/ansible
	sudo mkdir my-safe-directory
	sudo mkdir certs
	sudo cockroach cert create-ca --certs-dir=certs --ca-key=my-safe-directory/ca.key
	IFS=',' read -ra ec2list <<< "$ec2_instances"
	for instance in "${ec2list[@]}"; do
		ansible-playbook -i "$instance", install-cockroach-nodes.yaml --extra-vars="elb_dns_name=$elb_dns_name ec2_ip=$instance ec2_instances=$ec2_instances cockroach_version=$1" --private-key ~/jbb.pem --user=ubuntu --become-method=sudo
	done

		if [[ $? == 0 ]]
		then
			echo "Creating client certifactes for root user locally..."
		        sudo cockroach cert create-client root --certs-dir=certs --ca-key=my-safe-directory/ca.key
		else
			echo "Cant install and configure nodes. Exiting...!"
			exit 1
		fi	
else
	echo "cant create EC2 instances"
	exit 1
fi
