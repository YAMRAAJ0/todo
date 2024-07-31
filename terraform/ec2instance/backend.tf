terraform {
    backend "s3" {
    bucket = "<yourname>-tfstate-terraform-101"
    key    = "my_app"
    region = "us-east-1"
  }
}