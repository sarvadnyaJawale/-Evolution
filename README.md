 AWS Auto Scaling with Load Average Monitoring

1. Introduction:
    The project aims to implement an Auto Scaling solution on AWS, allowing dynamic adjustment of the number of instances in response to changes in system load.

2. Architecture Components:

   a. Virtual Private Cloud (VPC):
       A VPC is created to isolate the network resources in the AWS cloud. It provides a logically isolated section of the AWS Cloud where you can launch AWS resources.

   b. Subnets:
       Public and private subnets are defined within the VPC. Public subnets typically house resources that need to be directly accessible from the internet, while private subnets are for resources that should not be directly exposed.

   c. Launch Template:
       A launch template is specified to define the configuration of instances launched within the Auto Scaling Group. It includes details such as the Amazon Machine Image (AMI), instance type, key pair, user data script, etc.

   d. Auto Scaling Group:
       An Auto Scaling Group is created to manage the scaling of EC2 instances based on defined policies. It ensures that the desired number of instances is maintained even during fluctuations in load.

   e. Scaling Policies:
       Scaling policies are defined to instruct the Auto Scaling Group on when to add or remove instances based on load conditions. In this project, scaling policies are tied to the 5-minute load average metric.

   f. Scheduled Action for Daily Refresh:
       A scheduled action is implemented to refresh all instances in the Auto Scaling Group daily at UTC 12am. This action replaces the existing instances with new ones.

   g. CloudWatch Alarm:
       A CloudWatch alarm is configured to monitor the load average metric. It triggers actions when the load average exceeds or falls below certain thresholds. In this case, it's set to trigger when the load average is above 75%.

   h. Simple Notification Service (SNS) Topic:
       An SNS topic is created, which can be used for sending email notifications. It's associated with the CloudWatch alarm to notify stakeholders when scaling events occur.

3. Flow of the Program:

   a. Initialization:
       Run `terraform init` to initialize the Terraform working directory.

   b. Configuration:
       Replace placeholder values in the Terraform script (e.g., AWS region, AMI ID, key pair, etc.) with your actual AWS configuration details.

   c. Execution:
       Run `terraform apply` to execute the Terraform script and create the specified AWS resources.

   d. Monitoring:
       AWS Auto Scaling continuously monitors the specified metric (5-minute load average) through CloudWatch.

   e. Scaling Events:
       When the load average crosses the defined thresholds, Auto Scaling triggers scaling policies to add or remove instances.

   f. Daily Refresh:
       The scheduled action triggers daily at UTC 12am, refreshing all instances in the Auto Scaling Group.

   g. Notification:
       If the CloudWatch alarm is triggered, notifications are sent to the specified SNS topic, notifying stakeholders of the scaling events.

4. Customization:
    Users can customize the project by adjusting parameters in the Terraform script, such as instance type, AMI, scaling thresholds, etc., to match their specific requirements.

5. Future Improvements:
    Additional features or improvements can be implemented based on project requirements, such as integrating with a load balancer, incorporating custom metrics, or enhancing notification mechanisms.
