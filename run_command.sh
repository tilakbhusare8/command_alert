#!/bin/bash
read -p "🔹 Enter your command: " user_cmd
eval "$user_cmd"
status=$?

if [ $status -ne 0 ]; then
    echo "[ERROR] $user_cmd" >> logs/command_log.txt
    echo "$user_cmd" > .last_failed_command
    bash error_handler.sh
else
    echo "✅ Command executed successfully!"
fi

