# Willy's Mac Setup

This sets up a new Mac exactly the way I have mine — terminal, editor, shell, apps, everything.

**What gets installed:**
- **Homebrew** — Mac package manager
- **iTerm2** color theme (palenight)
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

**Terminal-only install:** add `--no-apps` to skip anything that installs a GUI
app or downloads files to your Downloads folder — the Homebrew casks (Amethyst)
and the iTerm2 color theme. Everything else (tmux, vim, zsh + oh-my-zsh, the
dotfile symlinks, plugins) is still set up. Useful on a work machine or over SSH
where you can't touch the Applications folder.

```
bash <(curl -sL https://raw.githubusercontent.com/wsbresee/dotfiles/main/setup.sh) --no-apps
```

`SKIP_APPS=1` as an environment variable does the same thing. With `--no-apps`
you can skip Step 3 below — there's nothing to configure by hand.

### Step 3 — A few things to do manually

These two steps have to be done by hand:

**Set up the color theme in iTerm2:**
1. Open **iTerm2** (it was just installed — press Command + Space, type iTerm, hit Enter)
2. Go to **iTerm2 → Preferences** (or press Command + comma)
3. Click **Profiles**, then **Colors**
4. Click **Color Presets...** in the bottom right → **Import...**
5. Select **palenight.itermcolors** from your Downloads folder
6. Click **Color Presets...** again and select **palenight**
7. Click **Background Color** and set it to black

**Allow Amethyst to manage windows:**
1. Open **Amethyst** (press Command + Space, type Amethyst, hit Enter)
2. Follow the prompt to grant Accessibility permissions in System Settings

---

That's it! Give me a call if anything goes wrong.
