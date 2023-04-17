terraform {
  backend "gcs" {
    bucket = "dev-tfstate-bf"
    prefix = ""
  }
}
