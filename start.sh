#!/bin/sh
bw config server $BW_SERVER &> /dev/null
export BW_SESSION=$(bw login $BW_USERNAME --raw)


exec "$@"
