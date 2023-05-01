#!/bin/sh
echo "Initializing container"

if [ x"${SSH_KEY_PASSPHASE}" != "x" ] && [ x"${SSH_KEY_PATH}" != "x" ]; then
  eval `ssh-agent` &> /dev/null
  DISPLAY=":0.0" SSH_ASKPASS="/ssh-key-passphase-from-env.sh" setsid ssh-add "$SSH_KEY_PATH" </dev/null &> /dev/null
fi

if [ x"${GIT_CONFIG_SAFE_DIR}" != "x" ]; then
  git config --global --add safe.directory $GIT_CONFIG_SAFE_DIR
fi

bw config server $BW_SERVER &> /dev/null
export BW_SESSION=$(bw login $BW_USERNAME $BW_PASSWORD --raw)

exec "$@"
