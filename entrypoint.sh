#!/bin/bash
echo "✅ Container built successfully and is running!"

# If no command is passed, default to running the Python script
if [ "$#" -eq 0 ]; then
    exec aws configure list
else
    exec "$@"
fi
