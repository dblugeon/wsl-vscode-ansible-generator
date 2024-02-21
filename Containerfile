FROM rockylinux/rockylinux:8

# https://code.visualstudio.com/docs/remote/linux
# requiretement for wsl remote on rhel
# glibc libgcc libstdc++ python ca-certificates tar openssh curl wget libstdc++
# I add subversion and git for my usage

RUN dnf update -y && \
    dnf install -y sudo curl wget ca-certificates podman python38-pip git subversion openssh \
    glibc-langpack-fr glibc-langpack-en man && \
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
COPY --chown=${USERNAME} containers.conf /home/${USERNAME}/.config/containers/containers.conf

ADD requirements.txt /home/$USERNAME/requirements.txt 
RUN pip3.8 install --user -r /home/$USERNAME/requirements.txt && \
    rm -rf /home/$USERNAME/requirements.txt /home/$USERNAME/.cache