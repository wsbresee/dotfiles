#!/usr/bin/env bash
#
# Claude Code hook → tmux window name + activity icon.
#
# claude/hooks.json (merged into ~/.claude/settings.json by setup.sh) runs this
# for every Claude Code hook event, with the event name as $1 and the hook's
# JSON payload on stdin. It keeps two things on the tmux window Claude runs in:
#
#   window name     1-4 words for what the session is about
#   @claude_state   "working" or "waiting" — .tmux.conf renders it as the
#                   ○ / ● icon in front of the name
#
# Naming: Claude Code generates a title for every session (it is what the
# terminal tab shows as "✳ Fix login bug"), and /rename overrides it. That
# title is used as-is when it is already MAX_WORDS words or fewer. Longer
# titles are condensed once by a headless `claude -p --model haiku` call that
# runs in the background and is cached under ~/.cache/claude-tmux-tab, so no
# hook ever waits on the network.
#
# A window you renamed yourself before starting Claude keeps its name; only
# the icon is added. CLAUDE_TMUX_TAB=0 turns the whole thing off.

set -u

[[ "${CLAUDE_TMUX_TAB:-1}" != 0 ]] || exit 0
[[ -n "${TMUX_PANE:-}" ]] || exit 0
command -v tmux >/dev/null 2>&1 || exit 0

MAX_WORDS=4
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-tmux-tab"

event=${1:-}
pane=$TMUX_PANE
input=$(cat)   # always drain stdin so Claude never sees a broken pipe

tm()        { tmux "$@" 2>/dev/null; }
field()     { jq -r "$1 // empty" <<<"$input" 2>/dev/null; }
win_opt()   { tm show-options -wqv -t "$pane" "$1"; }
set_state() { tm set-option -w -t "$pane" @claude_state "$1"; }

first_words() {   # first MAX_WORDS words of stdin, one line
  awk -v n="$MAX_WORDS" '{ s = ""; for (i = 1; i <= NF && i <= n; i++) s = s (i > 1 ? " " : "") $i; print s; exit }'
}

# The title Claude Code gave this session: a /rename custom title wins, else
# the AI-generated one. Newer payloads carry it directly; otherwise both kinds
# are appended to the transcript as one-line JSON records.
session_title() {
  local t rec path
  t=$(field .session_title)
  if [[ -z $t ]]; then
    path=$(field .transcript_path)
    [[ -r $path ]] || return 0
    rec=$(/usr/bin/grep -oE '"type":"custom-title","customTitle":"([^"\\]|\\.)*"' "$path" | tail -n 1)
    [[ -n $rec ]] || rec=$(/usr/bin/grep -oE '"type":"ai-title","aiTitle":"([^"\\]|\\.)*"' "$path" | tail -n 1)
    [[ -n $rec ]] || return 0
    t=$(jq -r '.customTitle // .aiTitle // empty' <<<"{$rec}" 2>/dev/null)
  fi
  printf '%s' "$t"
}

rename() {
  [[ -n $1 ]] || return 0
  [[ $(win_opt @claude_keep) == 1 ]] && return 0
  [[ $(tm display -p -t "$pane" '#W') == "$1" ]] && return 0
  tm rename-window -t "$pane" "$1"
  tm set-option -w -t "$pane" @claude_named 1
}

# Runs in the background: condense a long title with haiku, cache it, and
# apply it if the window still belongs to the session that asked.
generate_name() {
  local title=$1 out=$2 lock=$3 sid=$4 transcript=$5 name context opening
  context="Session title: $title"
  if [[ -r $transcript ]]; then
    # The user's first real message (not a slash-command expansion) gives
    # haiku the specifics the title may have smoothed over.
    opening=$(jq -r 'select(.type == "user" and (.message.content | type) == "string"
                            and (.message.content | startswith("<") | not))
                     | .message.content' "$transcript" 2>/dev/null | head -c 400 | tr '\n' ' ')
    [[ -n $opening ]] && context+=$'\n'"Opening request: $opening"
  fi
  name=$(CLAUDE_TMUX_TAB=0 "${CLAUDE_CODE_EXECPATH:-claude}" -p --model haiku --tools "" \
      --no-session-persistence --strict-mcp-config --mcp-config '{"mcpServers":{}}' \
      --disable-slash-commands --exclude-dynamic-system-prompt-sections \
      --system-prompt "You name terminal tabs. Given a coding session's title and opening request, reply with a title of 1 to $MAX_WORDS words that says what the session is for. Be specific. Sentence case, no punctuation, no quotes, nothing else." \
      "$context" 2>/dev/null | head -n 1 | tr -d '"'"'"'.,:;!' | first_words)
  [[ -n $name ]] || name=$(first_words <<<"$title")
  printf '%s\n' "$name" > "$out.tmp" && mv -f "$out.tmp" "$out"
  rmdir "$lock" 2>/dev/null
  [[ $(win_opt @claude_session) == "$sid" ]] && rename "$name"
}

# Print a name of at most MAX_WORDS words for title $1, or nothing while one
# is still being generated.
short_name() {
  local title=$1 key cached lock
  [[ -n $title ]] || return 0
  if (( $(wc -w <<<"$title") <= MAX_WORDS )); then printf '%s' "$title"; return 0; fi
  key=$(printf '%s' "$title" | shasum | cut -c1-16)
  cached="$CACHE_DIR/$key"
  if [[ -s $cached ]]; then head -n 1 "$cached"; return 0; fi
  mkdir -p "$CACHE_DIR"
  lock="$cached.lock"
  if ! mkdir "$lock" 2>/dev/null; then
    # Another hook is already generating this one. Only take over if its
    # lock is stale (it crashed).
    [[ -n $(find "$lock" -maxdepth 0 -mmin +2 2>/dev/null) ]] || return 0
    touch "$lock"
  fi
  generate_name "$title" "$cached" "$lock" "$(field .session_id)" "$(field .transcript_path)" </dev/null >/dev/null 2>&1 &
  disown 2>/dev/null || true
}

apply_name() {
  rename "$(short_name "$(session_title)")"
}

case $event in
  SessionStart)
    set_state waiting
    tm set-option -w -t "$pane" @claude_session "$(field .session_id)"
    if [[ $(field .source) != compact ]]; then
      if [[ $(win_opt automatic-rename) == off && $(win_opt @claude_named) != 1 ]]; then
        tm set-option -w -t "$pane" @claude_keep 1   # user named this window; leave the name alone
      fi
      name=$(short_name "$(session_title)")
      [[ -n $name ]] || name=$(basename "$(field .cwd)")
      rename "$name"
    fi
    ;;
  UserPromptSubmit)
    set_state working
    apply_name
    ;;
  PostToolUse|PostToolUseFailure|PermissionDenied|ElicitationResult)
    set_state working
    ;;
  PermissionRequest|Elicitation|StopFailure)
    set_state waiting
    ;;
  Notification)
    case $(field .notification_type) in
      permission_prompt|idle_prompt|elicitation*) set_state waiting ;;
    esac
    ;;
  Stop)
    set_state waiting
    apply_name
    ;;
  SessionEnd)
    tm set-option -w -t "$pane" -u @claude_state
    tm set-option -w -t "$pane" -u @claude_session
    [[ $(win_opt @claude_keep) == 1 ]] || tm set-option -w -t "$pane" -u automatic-rename
    tm set-option -w -t "$pane" -u @claude_named
    tm set-option -w -t "$pane" -u @claude_keep
    ;;
esac

exit 0
