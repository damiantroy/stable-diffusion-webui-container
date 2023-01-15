# Host and container GID and UID
export PUID=1002
export PGID=1002

# Host user and group names
export SD_USER=stabdiff
export SD_GROUP=stabdiff

# Persistant storage
export SD_BASE_DIR=/mnt/media/stable-diffusion

# SD container image location
# Locally built: localhost/stable-diffusion-webui
# Pre-built: docker.io/damiantroy/stable-diffusion-webui
export SD_IMAGE=localhost/stable-diffusion-webui

