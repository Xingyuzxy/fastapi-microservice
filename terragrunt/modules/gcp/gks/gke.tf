resource "google_service_account" "gke_sa" {
    account_id   = "gke-sa"
    project = var.project_id
    display_name = "GKE Service Account"
}

resource "google_container_cluster" "gke_cluster" {
    name     = "gke-cluster"
    location = var.region
    project = var.project_id

    # We can't create a cluster with no node pool defined, but we want to only use
    # separately managed node pools. So we create the smallest possible default
    # node pool and immediately delete it.
    remove_default_node_pool = true
    initial_node_count       = 1
    # Network
    network = var.vpc_self_link
    subnetwork = var.subnet_self_link
    # In production, change it to true (Enable  to avoid accidental deletion)
    deletion_protection = false
}

# Resource: GKE Node Pool 1
resource "google_container_node_pool" "nodepool_1" {
    name       = "node-pool-1"
    location   = var.region
    cluster    = google_container_cluster.gke_cluster.name
    node_count = 1
    project = var.project_id

    node_config {
        preemptible  = true
        machine_type = var.machine_type

        # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
        service_account = google_service_account.gke_sa.email
        oauth_scopes    = [
        "https://www.googleapis.com/auth/cloud-platform"
        ]
    }
}