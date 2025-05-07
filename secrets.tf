locals {
  secrets_map = {
    DATABASE_URL    = "postgresql+asyncpg://savemomdev:savemomdev@34.93.88.162/starter"
    NO_AUTH_SECRET  = "s1a2v3e4m5o6m7"
    GEMINI_API_KEY  = "AIzaSyA_mLYAWyD35Gn2qAAgzvb25Cb0Qjlc95E"
  }
}

resource "google_secret_manager_secret" "secrets" {
  for_each = local.secrets_map

  secret_id = each.key
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "secrets_version" {
  for_each = local.secrets_map

  secret      = google_secret_manager_secret.secrets[each.key].id
  secret_data = each.value
}
