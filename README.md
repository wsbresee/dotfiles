# Willy's Mac Setup

This sets up a new Mac exactly the way I have mine — terminal, editor, shell, apps, everything.

**What gets installed:**
- **Homebrew** — Mac package manager
- **iTerm2** — full saved preferences (palenight colors, Monaco 12, keybindings)
- **tmux** — terminal multiplexer with custom keybindings
- **vim** — text editor with plugins and palenight colors
- **zsh + oh-my-zsh** — shell with the common theme and autosuggestions
- **Amethyst** (window manager)

---

## Instructions

### Step 1 — Open Terminal

Press **Command + Space**, type **Terminal**, and hit Enter.

### Step 2 — Run this command

Copy and paste the following into Terminal and hit Enter:

```
bash <(curl -sL https://raw.githubusercontent.com/wsbresee/dotfiles/main/setup.sh)
```

This will automatically install everything. It may take a few minutes. When it's done you'll see a "Done!" message.

Re-running the same command later will pull the latest dotfiles from this repo and re-apply them, so your config stays up to date.

**Terminal-only install:** add `--no-apps` to skip anything that touches a GUI
app — the Homebrew casks (Amethyst) and the iTerm2 preferences import.
Everything else (tmux, vim, zsh + oh-my-zsh, the dotfile symlinks, plugins) is
still set up. Useful on a work machine or over SSH where you can't touch the
Applications folder.

```
bash <(curl -sL https://raw.githubusercontent.com/wsbresee/dotfiles/main/setup.sh) --no-apps
```

`SKIP_APPS=1` as an environment variable does the same thing. With `--no-apps`
you can skip Step 3 below — there's nothing to configure by hand.

### Step 3 — A few things to do manually

**Allow Amethyst to manage windows:**
1. Open **Amethyst** (press Command + Space, type Amethyst, hit Enter)
2. Follow the prompt to grant Accessibility permissions in System Settings

That used to be a longer list. The iTerm2 colors, font and keybindings are now
applied automatically from the saved preferences file — see below.

---

## iTerm2 preferences

`iterm2/com.googlecode.iterm2.plist` is a full export of my iTerm2 settings.
The setup script imports it with `defaults import`, so a new Mac gets the
palenight colors, black background, Monaco 12 and all keybindings with no
clicking around in Preferences.

**Run it from Terminal.app, not iTerm2.** iTerm2 rewrites its preferences from
memory when it quits, which would wipe out the import. The script checks for
this: if iTerm2 is running it skips the import and tells you to quit and re-run.

Your previous settings are backed up once to
`~/Library/Preferences/com.googlecode.iterm2.plist.bak` before the first import.

**After changing settings in iTerm2**, save them back to this repo:

```
~/projects/dotfiles/iterm2/export.sh
```

then commit. It writes sorted XML so git diffs stay readable, and drops the
handful of keys that describe this particular Mac rather than the settings —
saved window positions, the install's UUID, crash-report state. Everything that
is actually a preference (profiles, colors, font, keybindings) is kept.

---

## Claude Code tabs in tmux

Every tmux window running Claude Code shows a short name for what that
session is about and an icon for whether Claude is busy or waiting on you:

```
0 ○ Tmux tab labels | 1 ● Fix login bug | 2 zsh
```

- **○ (palenight blue)** — Claude is working.
- **● (palenight green)** — Claude is finished and waiting for you: it ended
  its turn, wants a permission answer, or hit an error.

The name is Claude Code's own session title (the one it puts in the terminal
title bar, and that `/rename` overrides), kept to four words. Longer titles
are condensed once by a quick headless Haiku call in the background and
cached in `~/.cache/claude-tmux-tab`, so nothing ever blocks the session.
Before the first prompt the window is named after the directory.

Details worth knowing:

- `/rename Some name` in Claude pins the window name to whatever you typed.
- A window you renamed yourself before launching Claude keeps its name and
  only gains the icon.
- When Claude exits the window goes back to tmux's automatic naming.
- `CLAUDE_TMUX_TAB=0 claude` turns it all off for one session.

How it works: `claude/tmux-tab.sh` is a Claude Code hook that runs on
session start, prompt submit, tool completion, permission prompts, turn end
and exit. It stores the state in a `@claude_state` window option and
`.tmux.conf` renders that as the icon. `setup.sh` merges `claude/hooks.json`
into `~/.claude/settings.json` (that file is not symlinked, since it also
holds per-machine settings). After editing `hooks.json`, re-run `setup.sh`.

---

That's it! Give me a call if anything goes wrong.
