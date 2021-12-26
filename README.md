## Automatic deployment of a scalable and resilient WordPress installation on AWS using Terraform.

### Architecture 
* Aurora Cluster:
  * scalable and resilient MySQL Database that spans over three Availability Zones (AZs).
* EFS (Elastic File system):
  * provides a network based resilient shared file system in three Availability Zones (AZs). 
* Launch Template: 
  * provides automatic provisioning of the EC2 instances running the wordpress app.
  * specifies instance configuration information: ID of the Amazon Machine Image (AMI),the instance type,a key pair,security groups and user data script.
* Auto Scaling Group:
  * allows instances to scale out or in based on scaling policies and health checks notifications that come from the Application Load Balancer.
  * scales out when CPU > 40%
  * scales in when CPU < 40%
* Application Load Balancer: 
  * automatically distributes incoming application traffic across multiple targets in three Availability Zones (AZs).
  * points at the Auto Scaling Group so the customer will connect via the Application Load Balancer instead of connecting to the instance directly.
  * it allows the system to be fully resilient, self-healing and fully elastically scalable.
  
![picture alt](https://github.com/George-T-Serban/aws-high-availability-wordpress/blob/main/aws-wordpress-smaller.png?raw=true)