#!/bin/sh

echo "generating env-config file"
workingDir="$nginx_dir"/html

echo "window._env_ = {" > "${workingDir}"/env.config.js
awk -F '=' '
  /^\s*#/ { next }           # skip comments
  /^\s*$/ { next }           # skip empty lines
  {
    key = $1
    value = substr($0, index($0, "=") + 1)
    # prefer environment override if set
    if (ENVIRON[key] != "") {
      value = ENVIRON[key]
    }
    # escape backslashes and double quotes
    gsub(/\\/, "\\\\", value)
    gsub(/\"/, "\\\"", value)
    # remove trailing carriage return if any
    sub(/\r$/, "", value)
    print key ": \"" value "\"," 
  }
' "${workingDir}"/.env >> "${workingDir}"/env.config.js
echo "}" >> "${workingDir}"/env.config.js

echo "generation of env-config file completed!"

exec "$@"
