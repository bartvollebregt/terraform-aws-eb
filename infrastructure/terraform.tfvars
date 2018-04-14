profile= "your-application-profile"
allowed_account_ids=["123456789012"]
application_name= "your-application-name"
application_description="Application based on Elastic Beanstalk & Docker"
application_environment="playground"
region="eu-west-1"
instance_type= "t2.micro"
min_instances_in_service=1
esb_solution_stack_name="64bit Amazon Linux 2017.09 v2.9.2 running Docker 17.12.0-ce"
public_key_path="~/.ssh/your_key.pub"
key_name="your-key-name"
batch_size=50

//Autoscaling
//autoscaling_measure_name="NetworkOut"
//autoscaling_statistic="Average"
//autoscaling_unit="Bytes"
//autoscaling_min_size=1
//autoscaling_max_size=2
//autoscaling_lower_breach_scale_increment=-1
//autoscaling_upper_breach_scale_increment=1
//autoscaling_upper_threshold=6000000
//autoscaling_LowerThreshold=2000000
//autoscaling_breach_duration=5
//autoscaling_evaluation_periods=1
//autoscaling_period=5