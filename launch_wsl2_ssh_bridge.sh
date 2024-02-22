#!/bin/bash
# inspired from https://github.com/KerickHowlett/wsl2-ssh-bridge?tab=readme-ov-file#bashzsh
export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
if ! ss -a | grep -q "$SSH_AUTH_SOCK"; then
  rm -f "$SSH_AUTH_SOCK"
  wsl2_ssh_bridge_bin="$HOME/.ssh/wsl2-ssh-bridge.exe"
  if test -x "$wsl2_ssh_bridge_bin"; then
    (setsid nohup socat UNIX-LISTEN:"$SSH_AUTH_SOCK,fork" EXEC:"$wsl2_ssh_bridge_bin -verbose" >/dev/null 2>&1 &)
  else
    echo >&2 "WARNING: $wsl2_ssh_bridge_bin is not executable."
    echo >&2 "HINT: check existence and permission of $wsl2_ssh_bridge_bin"
    echo >&2 "HINT: the path $wsl2_ssh_bridge_bin must be a symbolic link to windows partition"
    echo >&2 "return of ls :$(ls -alh $wsl2_ssh_bridge_bin)"
  fi
  unset wsl2_ssh_bridge_bin
fi