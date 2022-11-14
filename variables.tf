#Security Group Variables

variable "sgPorts" {
  type        = list(number)
  description = "List of Ingress Ports"
  default     = [443, 80, 22, 3389, 8080, 3000]
}

variable "isTest" {
  default = true
}
