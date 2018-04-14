variable "allowed_account_ids" {
  type = "list"
  description = "Account ids of AWS that are allowed to apply"
}

variable "profile" {
  description = "Name of your profile inside ~/.aws/credentials"
}

variable "application_name" {
  description = "Name of your application"
}

variable "application_description" {
  description = "Sample application based on Elastic Beanstalk & Docker"
}

variable "application_environment" {
  description = "Deployment stage e.g. 'staging', 'production', 'test', 'integration'"
}

variable "region" {
  default     = "eu-west-1"
  description = "Defines where your app should be deployed"
}

variable "instance_type" {
  description = "The instance type where you wish to run the app on"
}

variable "esb_solution_stack_name" {
  description = "The solution stack name to use (e.g. esb_solution_stack_name)"
}

variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so ansible can
connect.
Example: ~/.ssh/your-application.pub
DESCRIPTION
}

variable "key_name" {
  description = "The name you want to use for the key in new instances"
}

variable "healthcheck_url" {
  default     = "/health"
}

variable "deployment_policy" {
  description = "The default deployment policy you would like to use"
  default     = "RollingWithAdditionalBatch"
}

variable "batch_size_type" {
  description = "The batch size type you would like to use"
  default     = "Percentage"
}

variable "batch_size" {
  description = "Percent to deploy when rolling with additional batch"
}

variable "rolling_update_enabled" {
  default     = "true"
}

variable "min_instances_in_service" {
  description = "Minimum number of instances that should be online (deployments)"
}

variable "rolling_update_type" {
  default     = "Health"
}

//Autoscaling
variable "autoscaling_max_size" {
  description = "Maximum number of intances to scale to"
  default = 2
}

variable "autoscaling_min_size" {
  description = "Minimum number of intances to downscale to"
  default = 1
}

variable "autoscaling_lower_breach_scale_increment" {
  description = "To number of instances to take down when the lower breach is reached (downscaling)"
  default = -1
}

variable "autoscaling_upper_breach_scale_increment" {
  description = "To number of instances to add when the upper breach is reached (upscaling)"
  default = 1
}

variable "autoscaling_upper_threshold" {
  description = "Value on which to perform upscaling"
  default = 6000000
}

variable "autoscaling_LowerThreshold" {
  description = "Value on which to perform downscaling"
  default = 2000000
}

variable "autoscaling_breach_duration" {
  description = "The amount of time a metric can exceed a threshold before triggering a scaling operation. (minutes)"
  default = 5
}

variable "autoscaling_measure_name" {
  description = "The metric that is monitored to determine if the environment’s capacity is too low or too high."
  default = "NetworkOut"
}

variable "autoscaling_evaluation_periods" {
  description = "The amount of periods to evaluate metrics before up- or downscaling."
  default = 1
}

variable "autoscaling_period" {
  description = "The period between metric evaluations."
  default = 5
}

variable "autoscaling_statistic" {
  description = "How the metric is interpreted."
  default = "Average"
}

variable "autoscaling_unit" {
  description = "The unit used to interpret metric."
  default = "Bytes"
}


//Custom environment variables that will be provisioned inside your container
variable "env_custom_variable" {
  description = "My custom environment variable"
}
