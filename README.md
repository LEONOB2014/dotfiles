# dotfiles

Personal macOS dotfiles for Andrés Becerra, managed with [GNU Stow](https://www.gnu.org/software/stow/).
Each top-level directory is a **stow package**: its contents mirror the layout
of `$HOME`, and `stow <package>` symlinks everything into place. `./install.sh`
replicates the whole setup — packages, plugins, and everything they need —
on a fresh machine, VM, or remote server in one run; see
[Quick install](#quick-install-fresh-machine-vm-remote-server).

| Package    | Tool(s)                          | What it configures |
|------------|-----------------------------------|---------------------|
| `nvim`     | [Neovim](https://neovim.io)       | Lua config: lazy.nvim plugin manager, LSP/Mason, treesitter, telescope, catppuccin |
| `vim`      | Vim                                | Legacy Vimscript config, kept for reference/fallback |
| `tmux`     | tmux                               | Vim-style pane nav, Catppuccin Mocha status bar, TPM plugins |
| `zsh`      | zsh, [antidote](https://getantidote.github.io) | Shell config, aliases, antidote-managed plugin list |
| `ghostty`  | [Ghostty](https://ghostty.org)     | Terminal appearance, keybinds, Catppuccin Mocha theme |
| `starship` | [Starship](https://starship.rs)    | Prompt, Catppuccin Mocha theme |
| `atuin`    | [Atuin](https://atuin.sh)          | Shell history sync/search |
| `git`      | git, [delta](https://github.com/dandavison/delta) | Identity, global gitignore, delta as diff pager |

## Quick install (fresh machine / VM / remote server)

```sh
git clone <this-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` is idempotent (safe to re-run) and does everything end to end:
installs Homebrew if missing, runs `brew bundle` against the `Brewfile`
(all CLI tools + Ghostty + the Nerd Font), symlinks all 8 packages with
`stow`, installs TPM and syncs tmux plugins headlessly, installs vim-plug's
plugins and nvim's lazy.nvim plugins headlessly, and installs `uv`/`bun`
(the two tools `zsh/.zshrc` references directly). It prints a short list of
manual follow-ups at the end (setting zsh as your default shell, and a few
proprietary/personal tools — conda, Antigravity — that aren't automated
since they're not part of this repo). See `install.sh` for exact steps, and
`Brewfile` for the full package list.

On Linux, `install.sh` skips the cask entries (Ghostty, Nerd Font — macOS
only) and installs everything else; a couple of things assume macOS
regardless (tmux's copy-mode binds to `pbcopy`).

## Manual / partial install

Prefer to install package-by-package instead of running the full script:

```sh
brew install stow
brew bundle --file=Brewfile   # or hand-pick from it

# Dry-run first to check for conflicts with existing files
stow -nv nvim vim tmux zsh ghostty starship atuin git

# Then apply for real
stow nvim vim tmux zsh ghostty starship atuin git
```

Stow refuses to overwrite a real file that already exists at the target path
— if that happens, move the existing file aside (or `rm` it, once you've
confirmed it's not something worth keeping) and re-run `stow`. To remove a
package's symlinks, run `stow -D <package>`; to relink after editing a
package's structure, `stow -R <package>`.

Plugin managers (TPM for tmux, vim-plug for vim, lazy.nvim for nvim) still
need their install/sync step run once — see the corresponding numbered
section in `install.sh` if you're doing this by hand.

## Structure

```
dotfiles/
├── install.sh                   # bootstrap script — see "Quick install"
├── Brewfile                      # every formula/cask install.sh installs
├── nvim/.config/nvim/          # init.lua -> lua/andres/{core,plugins,lsp}
├── vim/.vimrc, .vim/            # legacy vim config + plugins
├── tmux/.tmux.conf
├── zsh/.zshrc, .zsh_plugins.txt
├── ghostty/.config/ghostty/
├── starship/.config/starship.toml
├── atuin/.config/atuin/config.toml
└── git/.config/git/{config,ignore}
```

Every package's real path under `$HOME` is one symlink hop into this repo —
e.g. `~/.config/nvim/init.lua -> ~/dotfiles/nvim/.config/nvim/init.lua`.

## Package notes

- **nvim** — Lua namespace is `lua/andres/`. Bootstraps
  [lazy.nvim](https://github.com/folke/lazy.nvim) on first run (clones it if
  missing), then loads `andres.core` (options/keymaps), `andres.lazy`
  (plugin manager + auto-imports everything under `andres/plugins/`), and
  `andres.lsp`. A few plugins (`ai.lua`, `flash.lua`, `which-key.lua`) are
  present but intentionally commented out — kept as ready-to-enable rather
  than deleted.
- **vim** — the pre-nvim Vimscript setup (`vim-plug`, coc.nvim, ALE). No
  longer the daily driver but left in place and stowed independently so it
  doesn't collide with the `nvim` package.
- **tmux** — Catppuccin Mocha status bar with live CPU/RAM segments,
  vim-style `hjkl` pane navigation, TPM-managed plugins (resurrect,
  continuum, tmux-cpu).
- **zsh** — plugins are declared in `.zsh_plugins.txt` and loaded by
  `antidote load` in `.zshrc`; antidote compiles that list into
  `~/.zsh_plugins.zsh` on every shell start. That generated file is **not**
  tracked here (see Notes below).
- **ghostty**, **starship**, **tmux** all share the same Catppuccin Mocha
  palette for visual consistency across the terminal.
- **git** — `user.name`/`user.email` set globally, `delta` wired in as the
  pager for `git diff`/`git show` (`core.pager`, `interactive.diffFilter`),
  and a global `ignore` file. `core.excludesfile` isn't set explicitly
  because git already reads `$XDG_CONFIG_HOME/git/ignore` (i.e.
  `~/.config/git/ignore`) as the global excludes file by default.
- **atuin** — config file present but currently all-default (every setting
  in it is commented-out upstream documentation); kept stowed so future
  overrides land in version control automatically.

## Notes

- `~/.zsh_plugins.zsh` is a build artifact generated by antidote from
  `.zsh_plugins.txt` — it is intentionally **not** part of this repo and
  regenerates itself automatically; don't hand-edit or try to stow it.
- `.DS_Store` files are excluded via `.gitignore`; if `stow` ever complains
  about one blocking a link, delete it rather than adopting it.
- Tools without an entry in this repo (zoxide, fzf, eza, bat, ripgrep, fd,
  tldr, jq, yq, gh, direnv, node, telescope) have no dedicated config file —
  they run on their built-in defaults, driven entirely by the aliases/
  `eval "$(... init zsh)"` lines in `zsh/.zshrc`. Telescope specifically is
  an nvim plugin, configured under
  `nvim/.config/nvim/lua/andres/plugins/telescope.lua`.
- `uv` and `bun` are installed by `install.sh` via their official installer
  scripts (not Homebrew) specifically because `.zshrc` sources
  `~/.local/bin/env` (created only by uv's installer) and
  `~/.bun/_bun` completions — installing via Homebrew instead would leave
  those lines pointing at files that don't exist.
- `node` is in the `Brewfile` solely so nvim's Mason (see nvim's
  `lsp/mason.lua`) has npm available to install the npm-based language
  servers it manages (`ts_ls`, `html`, `cssls`, `tailwindcss`, `svelte`,
  `graphql`, `emmet_ls`, `prismals`). Mason installs/updates those (plus
  `pyright`, `stylua`, `prettier`, `black`, `isort`, `pylint`, `eslint_d`)
  itself on nvim startup — nothing to do manually.

## Authors

Maintained by **Andrés Becerra**, configured together with **Claude**
(Anthropic). The `nvim` package's original layout and plugin selection were
adapted from [Josean Martinez](https://github.com/josean-dev)'s public
Neovim configuration/tutorial before being personalized (renamed Lua
namespace, pruned/adjusted plugin set) for this repo.
