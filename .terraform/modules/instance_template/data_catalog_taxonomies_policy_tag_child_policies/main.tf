resource "google_data_catalog_policy_tag" "parent_policy" {
  provider = google-beta
  taxonomy = google_data_catalog_taxonomy.my_taxonomy.id
  display_name = "High"
  description = "A policy tag category used for high security access"
}

resource "google_data_catalog_policy_tag" "child_policy" {
  provider = google-beta
  taxonomy = google_data_catalog_taxonomy.my_taxonomy.id
  display_name = "ssn"
  description = "A hash of the users ssn"
  parent_policy_tag = google_data_catalog_policy_tag.parent_policy.id
}

resource "google_data_catalog_policy_tag" "child_policy2" {
  provider = google-beta
  taxonomy = google_data_catalog_taxonomy.my_taxonomy.id
  display_name = "dob"
  description = "The users date of birth"
  parent_policy_tag = google_data_catalog_policy_tag.parent_policy.id
  // depends_on to avoid concurrent delete issues
  depends_on = [google_data_catalog_policy_tag.child_policy]
}

resource "google_data_catalog_taxonomy" "my_taxonomy" {
  provider = google-beta
  region = "us"
  display_name =  "taxonomy_display_name-${local.name_suffix}"
  description = "A collection of policy tags"
  activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]
}
