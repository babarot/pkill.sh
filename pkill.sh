#!/bin/bash

get_filter() {
    local x candidates
    if [[ -z $1 ]]; then
        return 1
    fi
    candidates="$1:"
    while [[ -n $candidates ]]
    do
        x=${candidates%%:*}
        candidates=${candidates#*:}
        if type "${x%% *}" &>/dev/null; then
            echo "$x"
            return 0
        else
            continue
        fi
    done
    return 1
}

pdir="$(builtin cd "$(dirname "$0")" && pwd)"

filter="$(get_filter "${F:-fzf-tmux --header-lines=1:fzy:peco:fzf}")"
if [[ -z $filter ]]; then
    echo "\$F: no available filters" >&2
    exit 1
fi

pid="$(
{
    if [[ $filter =~ ^fzf ]]; then
        printf "PID\tTIME\t\tCOMMAND\n"
    fi
    ps aux \
        | awk -v user=$USER -f "$pdir/lib/process.awk"
} \
    | $filter \
    | awk '{print $1}'
)"

if [[ -z $pid ]]; then
    exit 0
fi

if ! kill -0 $pid &>/dev/null; then
    echo "pid $pid: not found" >&2
    exit 1
fi

kill -9 $pid
if [[ $? -eq 0 ]]; then
    echo "pid $pid was killed"
else
    echo "pid $pid: failed to kill"
fi
