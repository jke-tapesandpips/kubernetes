variable "location-1" {
    description     = "Location Nuremberg"
    type            = string
    default         = "nbg"
}

variable "location-2" {
    description     = "Location Falkenstein"
    type            = string
    default         = "fsn"
}

variable "arm-small" {
    description     = "Smallest arm instance"
    type            = string
    default         = "cax11"
}

variable "arm-big" {
    description     = "Second largest arm instance"
    type            = string
    default         = "cax31"
}

variable "operating-system" {
  description = "Ubuntu, as OS for setting up the servers"
  type        = string
  default     = "ubuntu-24.04"
}