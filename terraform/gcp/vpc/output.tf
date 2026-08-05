output "vpc_self_link" {
    description = "The VPC created"
    value       = google_compute_network.myvpc.self_link
}


output "subnet_self_link" {
    description = "The subnet created in VPC"
    value       = google_compute_subnetwork.mysubnet1.self_link
}