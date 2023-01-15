# Stable Diffusion WebUI Container

Welcome to the Stable Diffusion WebUI Container installation guide. This guide will walk you through the steps necessary to prepare your system and install the [Stable Diffusion AUTOMATIC1111 WebUI Container](https://github.com/AUTOMATIC1111/stable-diffusion-webui). 

This guide is specially tailored for Podman on Rocky Linux 9, but it can also be applied to other EL9 distributions and potentially even EL8 distributions. It may even work on Docker. Additionally, it's important to note that this guide assumes an SELinux-enabled system.

**The container will only work on systems with an Nvidia GPU installed.**

## Preparation

Before beginning, you will need to customise the installation to your system by selecting a free UID and GID for your new user and group, and choosing the location where persistent files will be stored, then create the resources.

```shell script
cp --no-clobber scripts/_example_env.sh scripts/env.sh
# Edit scripts/env.sh to change your settings.
source scripts/env.sh

sudo groupadd -g "$PGID" "$SD_GROUP"
sudo useradd -u "$PUID" -g "$SD_GROUP" "$SD_USER"
eval SD_USER_HOME=\~$SD_USER

sudo mkdir -p "$SD_BASE_DIR"/models/{deepbooru,Stable-diffusion,VAE,VAE-approx}
sudo chown -R "$SD_USER:$SD_GROUP" "$SD_BASE_DIR"
```

Install Podman:

```shell script
sudo dnf install podman
```

Allow containers to be managed by systemd in SELinux:

```shell script
sudo setsebool -P container_manage_cgroup on
```

[Download a model](https://rentry.org/sdmodels) and move it to `$SD_BASE_DIR/models/Stable-diffusion/model.ckpt`. In order for Stable Diffusion to start, you need one model file to be named `model.ckpt`, as it will load this first.

## Podman/Nvidia Preparation

Before doing the following steps, **make sure your Nvidia drivers are installed and working**. These steps will allow the GPU to be shared with containers.

```shell script
wget https://raw.githubusercontent.com/NVIDIA/dgx-selinux/master/bin/RHEL7/nvidia-container.pp
sudo semodule -i nvidia-container.pp
curl -s -L https://nvidia.github.io/nvidia-docker/rhel9.0/nvidia-docker.repo | sudo tee /etc/yum.repos.d/nvidia-docker.repo
sudo dnf -y install nvidia-container-runtime nvidia-container-toolkit
sudo nvidia-container-cli -k list | restorecon -v -f -
sudo restorecon -Rv /dev
```

## Build

Depending on your system, the build step will take around 15 minutes. Optionally, you can also run `make build-nc` to build with no cache.

```shell script
make build
```

## Run

It's good to run the container from the command line first to make sure everything is working. This command will run it in the foreground and you can press Control-C to stop it.

```shell script
make run
```

## Firewalld

This will permanently open Stable Diffusion's default port in the firewall.

```shell script
sudo firewall-cmd --new-service-from-file firewalld/stable-diffusion-webui.xml --permanent
sudo firewall-cmd --add-service stable-diffusion-webui --permanent
sudo firewall-cmd --reload
```

## Systemd

This will you to use the `systemctl` command to start and stop the container, as well as auto-starting the container when your machine starts.

```shell script
source scripts/env.sh
envsubst < systemd/container-stable-diffusion-webui.service-template | sudo tee /etc/systemd/system/container-stable-diffusion-webui.service
sudo systemctl daemon-reload
sudo systemctl enable --now container-stable-diffusion-webui.service
```

If you prefer to not run the container via systemd, you can run it in the background using the command:

```shell script
make run-bg
```

## Use

You can now point your web browser at: http://your-host-ip:7860/

