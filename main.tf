provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_cloud_run_service" "default" {
  name     = var.service_name
  location = var.region

  template {
    spec {

      containers {
        image = var.image

        env {
          name  = "APP_MODE"
          value = "dev"
        }

        env {
          name = "DATABASE_URL"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.secrets["DATABASE_URL"].secret_id
              key  = "latest"
            }
          }
        }

        env {
          name = "NO_AUTH_SECRET"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.secrets["NO_AUTH_SECRET"].secret_id
              key  = "latest"
            }
          }
        }

        env {
          name = "GEMINI_API_KEY"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.secrets["GEMINI_API_KEY"].secret_id
              key  = "latest"
            }
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "public_invoker" {
  location = google_cloud_run_service.default.location
  project  = var.project_id
  service  = google_cloud_run_service.default.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "cloud_run_url" {
  value = google_cloud_run_service.default.status[0].url
}
