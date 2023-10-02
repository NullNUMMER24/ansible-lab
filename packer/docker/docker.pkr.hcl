source "docker" "example" {
    image = "ubuntu"
    commit = false
    changes = [
      "ENTRYPOINT [\"/bin/sh\",
      "ENV HOSTNAME vmLS1",
      "MAINTAINER NullNUMMER24",
      "USER vagrant",
    ]
}


build {
  sources = ["source.docker.example"]
}