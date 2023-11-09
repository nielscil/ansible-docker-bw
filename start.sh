#!/bin/bash
echo "Initializing container"

if [ x"${SSH_KEY_PASSPHASES}" != "x" ] && [ x"${SSH_KEY_PATHS}" != "x" ]; then
  eval `ssh-agent` &> /dev/null
  
  read -ra splittedKeys <<< "$SSH_KEY_PATHS"
  read -ra splittedPass <<< "$SSH_KEY_PASSPHASES"
  
  for ((i = 0; i < ${#splittedKeys[@]}; ++i)); do
    sshKey=${splittedKeys[i]}
	sshPass=${splittedPass[i]}
    echo "Adding $sshKey"
    printf "#!/bin/sh\necho \"%s\"" $sshPass > /ssh-key-passphase-from-env.sh
	chmod u+x /ssh-key-passphase-from-env.sh
    DISPLAY=":0.0" SSH_ASKPASS="/ssh-key-passphase-from-env.sh" setsid ssh-add "$sshKey" </dev/null &> /dev/null
	rm /ssh-key-passphase-from-env.sh 
  done  
fi

if [ x"${GIT_CONFIG_SAFE_DIR}" != "x" ]; then
  git config --global --add safe.directory $GIT_CONFIG_SAFE_DIR
fi

bws config server-base $BW_SERVER &> /dev/null
exec "$@"
