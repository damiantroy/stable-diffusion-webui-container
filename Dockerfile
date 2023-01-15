# Base
FROM docker.io/rockylinux/rockylinux:9-minimal
RUN microdnf -y update && \
    microdnf -y install git libglvnd-glx python3-pip && \
    microdnf clean all && rm -rf /var/cache/yum

# Prereq
ENV PUID 1002
ENV PGID 1002
RUN groupadd -g "$PGID" stabdiff && \
    useradd -u "$PUID" -g stabdiff stabdiff && \
    chown -R stabdiff:stabdiff /home/stabdiff

# Nvidia
ENV NV_CUDA_CUDART_VERSION 11.7.99-1
COPY cuda.repo /etc/yum.repos.d/cuda.repo
RUN export NVIDIA_GPGKEY_SUM=d0664fbbdb8c32356d45de36c5984617217b2d0bef41b93ccecd326ba3b80c87 && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/rhel9/x86_64/D42D0685.pub | sed '/^Version/d' > /etc/pki/rpm-gpg/RPM-GPG-KEY-NVIDIA && \
    echo "$NVIDIA_GPGKEY_SUM  /etc/pki/rpm-gpg/RPM-GPG-KEY-NVIDIA" | sha256sum -c --strict -
RUN microdnf -y install cuda-cudart-11-7-${NV_CUDA_CUDART_VERSION} cuda-compat-11-8 && \
    microdnf clean all && rm -rf /var/cache/yum
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf
ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

# Install
USER stabdiff
WORKDIR /home/stabdiff
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
WORKDIR /home/stabdiff/stable-diffusion-webui
ENV PIP_NO_CACHE_DIR=1
RUN python3 -u launch.py --reinstall-xformers --exit

# Runtime
VOLUME /home/stabdiff/stable-diffusion-webui/models
VOLUME /home/stabdiff/stable-diffusion-webui/outputs
EXPOSE 7860
USER stabdiff
WORKDIR /home/stabdiff/stable-diffusion-webui
CMD ["python3","-u","webui.py","--listen","--disable-safe-unpickle","--port","7860"]

