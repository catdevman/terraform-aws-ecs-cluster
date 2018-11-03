output "alb_arn" {
 value = "${module.alb.alb_arn}"
}

output "alb_security_group_id" {
  value = "${module.alb.alb_security_group_id}"
}
