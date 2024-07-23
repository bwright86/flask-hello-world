variable "resources" {
  type = map(string)
  description = "A map of string values to use for resources."
}

variable "tags" {
    type = map(string)
    description = "Tags to be applied to resources."
}