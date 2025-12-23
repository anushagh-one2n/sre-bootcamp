path "secret/data/student-api/db" {
  capabilities = ["read"]
}

path "secret/data/dockerhub" {
  capabilities = ["read"]
}

path "secret/metadata/*" {
  capabilities = ["read", "list"]
}