FROM rockylinux/rockylinux:8

RUN dnf update -y && \
    dnf install -y bash-completion findutils sudo procps curl wget ca-certificates podman python38-pip git subversion openssh \
    bind-utils glibc-langpack-fr glibc-langpack-en man && \    
    dnf remove -y shadow-utils && dnf install -y shadow-utils && \
    dnf clean all && rm -rvf /var/cache/* /var/log/*

ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG VSCODE_COMMIT_ID=
ARG VSCODE_VERSION=

RUN echo -e "Welcome on rockylinux 8 wsl version\n \
           with vscode server for $VSCODE_VERSION($VSCODE_COMMIT_ID).\n \
           Podman is configured to use a remote serveur via podman desktop." > /etc/motd

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