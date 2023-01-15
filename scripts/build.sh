#!/usr/bin/env bash
# This script is used to build the stable-diffusion-webui container image.
set -e

SD_IMAGE_DEFAULT="localhost/stable-diffusion-webui"

usage() {
    echo "Usage: $(basename $0) [-i IMAGE] [-n] [-h]"
    echo "  -i IMAGE  Image name to build. Default is '$SD_IMAGE_DEFAULT'"
    echo "  -n        Do not use cache when building the image"
	echo "  -h        Display this help"
    exit 1
}

CONTAINER_RUNTIME=$(command -v podman 2> /dev/null || echo docker)
SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"

if [[ -f "$SCRIPTS_DIR/env.sh" ]]; then
    source "$SCRIPTS_DIR/env.sh"
fi

NO_CACHE_OPT=""
while getopts "i:nh" OPT; do
    case "$OPT" in
        i) SD_IMAGE="$OPTARG" ;;
        n) NO_CACHE_OPT="--no-cache" ;;
		*) usage ;;
    esac
done
shift $((OPTIND-1))
SD_IMAGE=${SD_IMAGE:-$SD_IMAGE_DEFAULT}
eval SD_USER_HOME=\~$SD_USER

echo "Building image $SD_IMAGE..."
sudo $CONTAINER_RUNTIME build $NO_CACHE_OPT \
    --security-opt label=type:nvidia_container_t \
    --hooks-dir="/usr/share/containers/oci/hooks.d" \
    -t "$SD_IMAGE" .

exit 0

