#!/bin/bash

full_cmd=$(cat .last_failed_command)
cmd_word=$(echo "$full_cmd" | awk '{print $1}')
args=$(echo "$full_cmd" | cut -d' ' -f2-)

# Function to compute word-by-word character-wise match score
score_match() {
    input="$1"
    line="$2"

    input_words=($input)
    line_words=($line)

    total_score=0
    for i in "${!input_words[@]}"; do
        iw=${input_words[i]}
        lw=${line_words[i]:-""}

        len=${#iw}
        match=0
        for ((j=0; j<len; j++)); do
            [[ "${iw:$j:1}" == "${lw:$j:1}" ]] && ((match++))
        done
        total_score=$((total_score + match))
    done
    echo "$total_score|$line"
}

# If the command doesn't exist
if ! command -v "$cmd_word" &>/dev/null; then
    echo "$full_cmd" > .last_failed_command

    while IFS= read -r line; do
        score_match "$full_cmd" "$line"
    done < command_list.txt | sort -t'|' -k1,1nr | cut -d'|' -f2 | head -3 > .suggested_cmds

    echo -e "\n❌ Command '$cmd_word' not found."
    if [[ -s .suggested_cmds ]]; then
        echo "💡 Do you mean any of these commands:"
        nl .suggested_cmds
    else
        echo "⚠️ No known fix found. Please check manually."
    fi
else
    echo -e "\n✅ Command found: '$full_cmd'"
    echo "⚠️ But there may be an error in options or arguments."

    # Detect and suggest fix for special characters instead of '-'
    if echo "$args" | grep -qE '\<[[:alnum:]]+[[:space:]]*[^[:alnum:]-][[:alnum:]]+'; then
        fixed_args=$(echo "$args" | sed -E 's/\b([a-zA-Z0-9]+)[[:space:]]*[^a-zA-Z0-9-]+([a-zA-Z0-9]+)/\1 -\2/g')
        echo "💡 Tip: Detected invalid option formatting."
        echo "👉 Try: $cmd_word $fixed_args"
    fi

    # Optional: subcommand match for git
    if [[ "$cmd_word" == "git" ]]; then
        subcmd=$(echo "$full_cmd" | awk '{print $2}')
        if [[ -n "$subcmd" ]]; then
            echo "🔍 Checking common subcommands..."
            awk -v input="$subcmd" '
            function match_score(a, b) {
                n = length(a)
                m = length(b)
                max = (n < m) ? n : m
                score = 0
                for (i = 1; i <= max; i++) {
                    if (substr(a,i,1) == substr(b,i,1)) score++
                }
                return score
            }
            {
                score = match_score(input, $0)
                if (score > 0) print score "|" $0
            }' git_subcommands.txt | sort -t'|' -k1,1nr | cut -d'|' -f2 | head -3 | while read suggestion; do
                echo "🔧 Suggestion: git $suggestion"
            done
        fi
    fi
fi

