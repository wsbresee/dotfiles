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

That's it! Give me a call if anything goes wrong.
