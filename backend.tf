terraform {
  backend "s3" {
    endpoint                    = "https://s3.zech.co"
    bucket                      = "terraform-state"
    region                      = "eu-central-1"
    use_path_style              = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
}
