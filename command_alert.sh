#!/bin/bash

while true; do
    clear
    echo "🔧 Command Alert System"
    echo "=========================="
    echo "1. Run a command"
    echo "2. View command log"
    echo "3. Exit"
    echo -n "Enter your choice [1-3]: "
    read choice

    case $choice in
        1)
            bash run_command.sh
            read -p "Press Enter to return to menu..."
            ;;
        2)
            echo "📄 Command Error Logs:"
            cat logs/command_log.txt
            echo ""
            read -p "Press Enter to return to menu..."
            ;;
        3)
            echo "👋 Exiting... Goodbye!"
            break
            ;;
        *)
            echo "❗ Invalid choice!"
            read -p "Press Enter to return to menu..."
            ;;
    esac
done

