terraform {
  required_version = ">= 0.12"
}
provider "google" {
  project     = "my-gcp-project"
  credentials = file("GCP_Keys.json")
  region      = "europe-west1"
  zone        = "europe-west1-b"
}
