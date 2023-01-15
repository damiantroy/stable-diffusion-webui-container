#!/usr/bin/env bash
# This script is used create a shell on the stable-diffusion-webui image.
set -e

SD_IMAGE_DEFAULT="localhost/stable-diffusion-webui"

usage() {
    echo "Usage: $(basename $0) [-i IMAGE] [-h]"
    echo "  -i IMAGE  Image name to run. Default is '$SD_IMAGE_DEFAULT'"
	echo "  -h        Display this help"
    exit 1
}

CONTAINER_RUNTIME=$(command -v podman 2> /dev/null || echo docker)
SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"

if [[ -f "$SCRIPTS_DIR/env.sh" ]]; then
    source "$SCRIPTS_DIR/env.sh"
fi

while getopts "i:h" OPT; do
    case "$OPT" in
        i) SD_IMAGE="$OPTARG" ;;
		*) usage ;;
    esac
done
shift $((OPTIND-1))
SD_IMAGE=${SD_IMAGE:-$SD_IMAGE_DEFAULT}

echo "Running image $SD_IMAGE..."
sudo $CONTAINER_RUNTIME run -it \
    --security-opt label=type:nvidia_container_t \
    --hooks-dir="/usr/share/containers/oci/hooks.d" \
    -v "$SD_BASE_DIR/models:/home/stabdiff/stable-diffusion-webui/models:z" \
    -v "$SD_BASE_DIR/outputs:/home/stabdiff/stable-diffusion-webui/outputs:z" \
    --network=host \
    --rm \
    "${SD_IMAGE}" bash

exit 0

