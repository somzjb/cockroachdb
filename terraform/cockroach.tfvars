instance_size = "m5.large"
region = "us-east-1"
db_server_count = "3"
target_vpc = "default"
keypair = "<key_pair>"       ##replace the placeholder with the ec2 keypair
security_group = "<security_group>"  #replace the placeholder with security group
app_access_rule = ["0.0.0.0/0"]
