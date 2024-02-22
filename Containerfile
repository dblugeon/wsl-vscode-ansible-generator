FROM rockylinux/rockylinux:8

# https://code.visualstudio.com/docs/remote/linux
# requiretement for wsl remote on rhel
# glibc libgcc libstdc++ python ca-certificates tar openssh curl wget libstdc++
# I add subversion and git for my usage
# socat iproute is for launch_wsl2_ssh_bridge.sh

RUN dnf update -y && \
    dnf install -y sudo curl wget ca-certificates podman python38-pip git subversion openssh \
    glibc-langpack-fr glibc-langpack-en man socat iproute && \
    dnf clean all && rm -rvf /var/cache/* /var/log/*

ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG VSCODE_VERSION=

# TODO recheck motd
RUN echo -e "Welcome on rockylinux 8 wsl version\n \
with vscode server for $VSCODE_VERSION.\n \
Podman is configured to use a remote serveur via podman desktop,\n \
the podman machine must be started." > /etc/motd

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USERNAME -G wheel -m -s /bin/bash $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME && \    
    echo -e "[user]\ndefault=$USERNAME\n" >> /etc/wsl.conf && \
    chown -R "$USERNAME:$USERNAME" /home/$USERNAME/

USER $USERNAME
COPY --chown=$USERNAME dist/vscode-server/ /home/${USERNAME}/.vscode-server/

# podman preconfigured to use podman socket
COPY --chown=${USERNAME} containers.conf /home/${USERNAME}/.config/containers/containers.conf

# add launch_wsl2_ssh_bridge.sh in bashrc.
COPY --chown=${USERNAME} --chmod=700 launch_wsl2_ssh_bridge.sh /home${USERNAME}/.launch_wsl2_ssh_bridge.sh
RUN echo ". /home${USERNAME}/.launch_wsl2_ssh_bridge.sh" >> /home/${USERNAME}/.bashrc && \
    mkdir /home/${USERNAME}/.ssh && chmod 700 -Rv /home/${USERNAME}/.ssh

ADD requirements.txt /home/$USERNAME/requirements.txt 
RUN pip3.8 install --user -r /home/$USERNAME/requirements.txt && \
    rm -rf /home/$USERNAME/requirements.txt /home/$USERNAME/.cache