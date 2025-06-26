#!/bin/bash

echo "📥 Cloning command_alert..."
git clone https://github.com/tilakbhusare8/command_alert.git

cd command_alert || { echo "❌ Directory not found."; exit 1; }

chmod +x *.sh

echo "✅ Installed. Run it with: ./command_alert.sh"

