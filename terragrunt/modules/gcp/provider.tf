provider "google" {
    project = var.project_id
    region = var.region
    zone = var.zone 
    alias = "us-central1"   
}