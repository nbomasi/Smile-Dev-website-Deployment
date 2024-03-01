# DEPLOYING SCALABLE AND SECURED WEBSITE FOR SMILE LIMITED

**Task:** You will build a secure infrastructure inside AWS VPC (Virtual Private Cloud) network for Smile Limited company  that uses WordPress CMS for its main business website, and a Tooling Website (Source code: https://github.com/nbomasi/tooling-1) for the DevOps team. As part of the company's desire for improved security and performance, a decision has been made to use a reverse proxy technology from NGINX to achieve this.

Cost, Security, and Scalability are the major requirements for this project. Hence, implementing the architecture designed below, ensure that infrastructure for both websites, WordPress and Tooling, is resilient to Web Server's failures, can accommodate to increased traffic and, at the same time, has reasonable cost.

## Project Design Architecture Diagram

![Design architecture](<Images/architecture diagram.PNG>)

## Task Breakdown:

1. **Wordpress CMS:** For it's main business website, that means wordpress will be installed.
2. **Tooling website:** This site will be use to access applications that DevOps team will need to carry out their daily activites 
3. **To secure websites:** NGINX proxy server, Security Group, Two Application load balancers (External and internal ALB), SSL/TLS cert for DNS, DB EFS and Web apps will be in private subnet. We will create our own VPC.
4. **Cost saving and scalability:** Auto scaling group with with target group mixed with sport instance and on-demand instances, EFS, ACM will be.used.

**STEPS TO BE TAKEN:**
1. Login into AWS
2. Create VPC and all associated resources
3. Security group
4. PaaS needed: Internal and external LB, RDS, EFS, SSL/TLS certificate for DNS from Namecheap
5. Compute Resources (IaaS): Bastion host, Nginx server, web severs

## Building the Network

Set Up a Virtual Private Network (VPC)
Always make reference to the architectural diagram and ensure that your configuration is aligned with it.

1. Create a VPC

2. Create subnets as shown in the architecture

3. Create a route table and associate it with public subnets

4. Create a route table and associate it with private subnets

5. Create an Internet Gateway

6. Edit a route in public route table, and associate it with the Internet Gateway. (This is what allows a public subnet to be accisble from the Internet)

7. Create 2 Elastic IPs for NAT gateway one per zone

VPC Range 10.0.0.0/16; remember to enable domain name resolution after creating th VPC
6 Subnets: 2 pub sub, 3 priv sub
2 Zones: eu-north-1a, eu-north-1b
10.0.1.0/24 => pub-sub1 [eu-north-1a]
10.0.1.0/24 => pub-sub2 [eu-north-1b]
10.0.1.0/24 => priv-sub1 [eu-north-1a]
10.0.1.0/24 => priv-sub2 [eu-north-1b]
10.0.1.0/24 => priv-sub3 [eu-north-1a]
10.0.1.0/24 => priv-sub4 [eu-north-1b]
Remember to allow auto assigning of public IP from the public sunet settings
1 Internet Gateway => To enable VPC access to the internet
2 NAT Gatway => For routing traffic to the internet from private subnet
2 Elastic IP => Static IP for NAT Gateway
2 Route Tables => 1 pub-Sub RT, 1 priv-sub RT: RT determines where traffic is directed to

## Security Group

Create a Security Group for:

**Nginx Servers:** Access to Nginx should only be allowed from a Application Load balancer (ALB). At this point, we have not created a load balancer, therefore we will update the rules later. For now, just create it and put some dummy records as a place holder.
**Bastion Servers:** Access to the Bastion servers should be allowed only from workstations that need to SSH into the bastion servers. Hence, you can use your workstation public IP address. To get this information, simply go to your terminal and type curl www.canhazip.com
**Application Load Balancer:** ALB will be available from the Internet
**Webservers:** Access to Webservers should only be allowed from the Nginx servers. Since we do not have the servers created yet, just put some dummy records as a place holder, we will update it later.
**Data Layer:** Access to the Data layer, which is comprised of Amazon Relational Database Service (RDS) and Amazon Elastic File System (EFS) must be carefully desinged - only webservers should be able to connect to RDS, while Nginx and Webservers will have access to EFS Mountpoint.

The security group should start from the outside: external LB, Bastion, NGINX, Internal LB, Webservers and datalayer SG


## Steps to be taken to achieve project AIM

1. Create a VPC
2. Create the subnets
3. Create the Internet Gateway
4. Create route table for the public subnet to use (Public Route Table)
5. Create a route in the public route table and point to the Internet gateway
6. Associate the public subnets to the created route table
7. Create a NAT Gateway so that servers in the private subnet can reach the internet to for example download stuff (Outbound)
8. Create route table for the private subnet to use (Private Route Table)
9. Create a route in the created route table and point to the NAT Gateway
9. Associate the private subnets (for compute only) to the private route table
10. Create Bastion security group. Allow all DevOps engineers to connect over SSH to the Bastion server
11. Create Public ALB security group and allow the entire world to talk to the ALB (HTTP/HTTS)
12. Create Nginx Proxy security group and allow the ALB to talk to the Nginx proxy server. (Nginx). Also allow Bastion to talk to nginx
13. Create internal ALB security group. (Alow traffic from Nginx proxy)
14. Create Wordpress site Security group (Allow traffic from internal ALB)
15. Create Security group for Tooling site (Allow traffic from internal ALB)
16. Create SG for data layer (RDS and EFS)

**Compute resources section**
17. Create an External facing Application Load Balancer (ALB)
18. Create a Listener (port 80) and target group
19. Update VPC settings to enable DNS Hostnames
20. Update public subnet settings to auto assign public IP address
21. Create Key Pair for SSH
22. Create a Launch Template for Bastion (Use a redhat based AMI) (include subnet settings for auto scaling in templates) Instamce type - Micro
24. Create ASG for Bastion
25. Connect to Bastion server launched in the Public Subnet over SSH
26. Create a Launch Template for nginx (Use a Ubuntu based AMI) (Private network)
27. Create ASG for nginx
28. Connect to the nginx server launched in the Private Subnet (Use SSH Agent to forward the public IP)


## Starting Off AWS Project

1. Properly configure your AWS account and Organization Unit [Watch How To Do This Here](https://youtu.be/9PQYCc_20-Q)
   
- Create an AWS Master account. (Also known as Root Account)
- Within the Root account, create a sub-account and name it DevOps. (You will need another email address to complete this)
- Within the Root account, create an AWS Organization Unit (OU). Name it Dev. (We will launch Dev resources in there)
Move the DevOps account into the Dev OU.
- Login to the newly created AWS account using the new email address.
- Create a free domain name for your fictitious company at Freenom domain registrar here.

- Create a hosted zone in AWS, and map it to your free domain from Freenom. [Watch how to do that here](https://youtu.be/IjcHp94Hq8A)


**NOTE** : As you proceed with configuration, ensure that all resources are appropriately tagged, for example:

- Project: Smile_Dev-Site
- Environment: dev
- Automated: Partial automation with bash script.
#

## Setting Up Infrastucture

1. Create a VPC

![VPC](<Images/create a new VPC.PNG>)

2. Create subnets as shown in the architecture

![Private_subnet](<Images/private subnet created.PNG>)

3. Create a route table and associate it with public subnets



4. Create a route table and associate it with private subnets
   

5. Create an Internet Gateway

![Internet_gateway](<Images/create TCS-igw.PNG>)

1. Edit a route in public route table, and associate it with the Internet Gateway. (This is what allows a public subnet to be accisble from the Internet)

7. Create an Elastic IP

8. Create a Nat Gateway and assign one of the Elastic IPs (*The other 2 will be used by Bastion hosts)
   
![NAT-gateway](<Images/create NAT gateway.PNG>)

9. Create a Security Group for:

**- Nginx Servers:** Access to Nginx should only be allowed from a Application Load balancer (ALB). At this point, we have not created a load balancer, therefore we will update the rules later. For now, just create it and put some dummy records as a place holder.
  
**- Bastion Servers:** Access to the Bastion servers should be allowed only from workstations that need to SSH into the bastion servers. Hence, you can use your workstation public IP address. To get this information, simply go to your terminal and type curl www.canhazip.com
  
**- Application Load Balancer:** ALB will be available from the Internet
Webservers: Access to Webservers should only be allowed from the Nginx servers. Since we do not have the servers created yet, just put some dummy records as a place holder, we will update it later.

**- Data Layer:** Access to the Data layer, which is comprised of Amazon Relational Database Service (RDS) and Amazon Elastic File System (EFS) must be carefully desinged – only webservers should be able to connect to RDS, while Nginx and Webservers will have access to EFS Mountpoint.

## Compute Resources

You will need to set up and configure compute resources inside your VPC. The recources related to compute are:

- EC2 Instances
- Launch Templates
- Target Groups
- Autoscaling Groups
- TLS Certificates
- Application Load Balancers (ALB)
  
### TLS Certificates From Amazon Certificate Manager (ACM)


You will need TLS certificates to handle secured connectivity to your Application Load Balancers (ALB).

- Navigate to AWS ACM
- Request a public wildcard certificate for the domain name you registered in Freenom
- Use DNS to validate the domain name
- Tag the resource
- Bind the ACM to the route53 hosted zone created earlier


### Setup EFS

Amazon Elastic File System (Amazon EFS) provides a simple, scalable, fully managed elastic Network File System (NFS) for use with AWS Cloud services and on-premises resources. In this project, we will utulize EFS service and mount filesystems on both Nginx and Webservers to store data.

- Create an EFS filesystem
- Create an EFS mount target per AZ in the VPC, associate it with both subnets dedicated for data layer
- Associate the Security groups created earlier for data layer.
Create an EFS access point. (Give it a name and leave all other settings as default)

![EFS](<Images/creating EFS.PNG>)

- On the EFS setup, create two access points for both `tooling` and `wordpress` applications
  
![Access-point](<Images/access points for tooling and wordpress.PNG>)
#

## Setup RDS
#

**Pre-requisite:** Create a KMS key from Key Management Service (KMS) to be used to encrypt the database instance.

`Amazon Relational Database Service (Amazon RDS) is a managed distributed relational database service by Amazon Web Services. This web service running in the cloud designed to simplify setup, operations, maintenans & scaling of relational databases. Without RDS, Database Administrators (DBA) have more work to do, due to RDS, some DBAs have become jobless`

To ensure that your databases are highly available and also have failover support in case one availability zone fails, we will configure a multi-AZ set up of RDS MySQL database instance. In our case, since we are only using 2 AZs, we can only failover to one, but the same concept applies to 3 Availability Zones. We will not consider possible failure of the whole Region, but for this AWS also has a solution – this is a more advanced concept that will be discussed in following projects.

To configure RDS, follow steps below:

- Create a subnet group and add 2 private subnets (data Layer)
- Create an RDS Instance for mysql 8.*.*

![Database](<Images/creating database.PNG>)

- To satisfy our architectural diagram, you will need to select either Dev/Test or Production Sample Template. But to minimize AWS cost, you can select the Do not create a standby instance option under Availability & durability sample template (The production template will enable Multi-AZ deployment)

- Configure other settings accordingly (For test purposes, most of the default settings are good to go). In the real world, you will need to size the database appropriately. You will need to get some information about the usage. If it is a highly transactional database that grows at 10GB weekly, you must bear that in mind while configuring the initial storage allocation, storage autoscaling, and maximum storage threshold.

- Configure VPC and security (ensure the database is not available from the Internet)
- Configure backups and retention
- Encrypt the database using the KMS key created earlier

![KMS](<Images/KMS created.PNG>)

- Enable CloudWatch monitoring and export Error and Slow Query logs (for production, also include Audit)

Database Script is [here](rds.sh)
  #
## Creating AMIs for Launch Templates

* [Script](tooling.sh) for tooling website that was use to build tooling image, hence tooling template
* [Script](wordpress.sh) for wordpress website that was use to build wordpress image, hencewordpress template
* [Script](nginx.sh) for tooling website that was use to build nginx image, hence nginx template


- To create Launch templates and target groups later on, we will need to setup AMI containing configurations to be done on this respective servers.
#

- Prepare Launch Template For Nginx,tooling, WebServers and Bastion (One Per Subnet)
  
- Make use of the AMI to set up a launch template

- Ensure the Instances are launched into their respective subnet; The bastion and Nginx template should be in the public subnets and then tooling and webservers be on the private subnet
  
- Assign appropriate security group

- Configure Userdata to update yum package repository and install nginx

- Configure Target Groups

- Select Instances as the target type
  
- Ensure the protocol HTTPS on secure TLS port 443

- Ensure that the health check path is /healthstatus

- Register Nginx Instances as targets

- Ensure that health check passes for the target group

- Configure Autoscaling For Nginx

- Select the right launch template

- Select the VPC

- Select both public subnets

- Enable Application Load Balancer for the AutoScalingGroup (ASG)

- Select the target group you created before

- Ensure that you have health checks for both EC2 and ALB

The desired capacity is 2

Minimum capacity is 2

Maximum capacity is 4

Set scale out if CPU utilization reaches 90%
Ensure there is an SNS topic to send scaling notifications
#


## CONFIGURE APPLICATION LOAD BALANCER (ALB)
#

Application Load Balancer To Route Traffic To NGINX
Nginx EC2 Instances will have configurations that accepts incoming traffic only from Load Balancers. No request should go directly to Nginx servers. With this kind of setup, we will benefit from intelligent routing of requests from the ALB to Nginx servers across the 2 Availability Zones. We will also be able to offload SSL/TLS certificates on the ALB instead of Nginx. Therefore, Nginx will be able to perform faster since it will not require extra compute resources to valifate certificates for every request.

### Create an Internet facing ALB

- Ensure that it listens on HTTPS protocol (TCP port 443)

- Ensure the ALB is created within the appropriate VPC | AZ | Subnets

- Choose the Certificate from ACM

- Select Security Group

- Select Nginx Instances as the target group

- Application Load Balancer To Route Traffic To Web Servers

- Since the webservers are configured for auto-scaling, there is going to be a problem if servers get dynamically scalled out or in. Nginx will not know about the new IP addresses, or the ones that get removed. Hence, Nginx will not know where to direct the traffic.

- To solve this problem, we must use a load balancer. But this time, it will be an internal load balancer. Not Internet facing since the webservers are within a private subnet, and we do not want direct access to them.

### Create an Internal ALB

- Ensure that it listens on HTTPS protocol (TCP port 443)

- Ensure the ALB is created within the appropriate VPC | AZ | Subnets
- Choose the Certificate from ACM

- Select Security Group

- Select webserver Instances as the target group

- Ensure that health check passes for the target group

![loadbalancer](Images/loadbalancers.PNG)

**NOTE:** This process must be repeated for both WordPress and Tooling websites.

- Route traffic coming from the nginx server into the internal loadbalancer by sending traffic to the respective target group based on the url being requested by the user.
  
![Adding-rule](<Images/adding rules.PNG>)


## Creating Databases for Wordpress and Tooling Sites on MySQL rds

- Login into the MySQL RDS from the bastion server

- Create databases 

 ![database](<Images/creating database tooling and wordpress.PNG>)


## Adding URL EndPoints to Route53 for Wordpress and Tooling Access

tooling-webpage
![tooling](Images/tooling-site.png)

Wordpress-page
![wordpress](Images/wordpress-page.png)

### End of Project 15