#
#### I wanted to setup Ansible lab on AWS, I was planning to do it with cloudformation first but then decided to go with Terraform
##### Lab Details

##### once "terraform apply" succeed, we should have 1- ansible control node (with ansible 2.7 installed) and 3 - ansible managed nodes (all amzn linux --- modified to centos7 in version 06 and 07)

###### 05-infra will create VPC with 2 subnets, a security group with ssh open to world.


## changed AMI
=======
## using ansible control node:
#### connect to control node using 

```
ssh -i kp.pem centos@IP
```
#### set ansible venv after logging in to control node

```
source myansible/bin/active
```

##### all ansible related command can be run now, but we still need to configure passwordless ssh between control node and managend nodes

##### use ssh-agent to get passwordless ssh (using kp we already have)

```
ssh-agent bash
ssh-add kp.pem
```
##### now passwordless ssh can be used. ansible ping shall work now.

```
ansible all -m ping


```



ansible lab practice document:
https://github.com/ArunNadda/ansible-exam-prep
