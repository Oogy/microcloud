provider "github" {
}

resource "github_repository" "microcloud" {
  name        = "microcloud"
  description = "A self-hosted mini Cloud Provider."

  visibility = "public"

  auto_init  = true

  pages {
    source {
      branch = "main"
      path   = "/docs"
    }
  }
}
