# The Stack — Field Guide

A practitioner's guide to the terminal, editor, and shell stack configured in
this repo — written for the way it's actually used: Python for ML/DL, agent
development with Claude Code and Gemini CLI, and multi-cloud infrastructure.
Every command below is real, pulled from the config files in this repo, not
generic advice.

A styled version of this guide (same content, Catppuccin-themed) also exists
as a published Artifact; this file is the version that lives in git.

## Contents

- [00 — Stack map](#00--stack-map)
- [01 — Shell & prompt](#01--shell--prompt)
- [02 — Navigation & files](#02--navigation--files)
- [03 — tmux sessions](#03--tmux--sessions-that-outlive-your-terminal)
- [04 — Git, reviewed properly](#04--git-reviewed-properly)
- [05 — Neovim as a Python/ML IDE](#05--neovim-as-a-pythonml-ide)
- [06 — Python & ML environments](#06--python--ml-environments)
- [07 — Agents & AI CLIs](#07--agents--ai-clis)
- [08 — Cloud provider workflows](#08--cloud-provider-workflows)
- [09 — Legacy → modern cheat sheet](#09--legacy--modern-cheat-sheet)
- [10 — A day in the life](#10--a-day-in-the-life)
- [11 — Full keybind reference](#11--full-keybind-reference)
- [12 — Tips & gotchas](#12--tips--gotchas)

---

## 00 — Stack map

| Layer | Tool | Role | Supersedes |
|---|---|---|---|
| Terminal | `ghostty` | GPU-accelerated terminal emulator | Terminal.app / iTerm2 |
| Multiplexer | `tmux` | Persistent sessions, panes, detach/reattach | — |
| Shell | `zsh` + `antidote` | Interactive shell, plugin management | oh-my-zsh |
| Prompt | `starship` | Fast, minimal cross-shell prompt | oh-my-zsh themes / powerlevel10k |
| History | `atuin` | Searchable, contextual shell history | zsh's built-in `Ctrl+R` |
| Editor | `neovim` + lazy.nvim | Primary IDE — LSP, treesitter, telescope | `vim` (kept, not used daily) |
| Navigation | `zoxide` | Frecency-based directory jumping | `cd` |
| Listing | `eza` | Icons, git status, tree view | `ls` |
| Viewing | `bat` | Syntax-highlighted paging | `cat` |
| Searching | `ripgrep` | Fast recursive content search | `grep` |
| Finding | `fd` | Fast, friendly file finder | `find` |
| Fuzzy select | `fzf` | Interactive filtering — history, files, anything piped in | manual `grep` pipelines |
| Data wrangling | `jq` / `yq` | JSON / YAML query & transform | Python one-liners for quick inspection |
| Diffing | `delta` | Syntax-highlighted, side-by-side git diffs | plain `git diff` |
| Git TUI | `lazygit` | Stage, commit, branch, rebase visually | memorized `git` incantations |
| GitHub | `gh` | PRs, issues, runs, releases from the CLI | the GitHub web UI, for most flows |
| Env vars | `direnv` | Per-directory env vars, auto-loaded/unloaded | manually sourcing `.env` files |
| Python tooling | `uv` | Package/venv manager, Rust-fast | `pip` + `venv`, mostly `conda` too |
| JS runtime | `bun`, `node` | JS/TS runtime; `node` also backs nvim's Mason LSPs | — |
| Docs | `tldr` | Example-first man pages | reading full `man` pages first |
| Agents | Claude Code CLI, Gemini CLI | Terminal-native coding agents | copy-pasting into a chat window |

**How this doc is organized**: sections 01–04 are the daily driving layer
(shell → files → sessions → git). Section 05 is the editor. 06–08 are where
this stack earns its keep for actual ML/agent/cloud work. 09–12 are
reference material to keep open in a split while working.

## 01 — Shell & prompt

`zsh/.zshrc` · `starship/.config/starship.toml` · `atuin/.config/atuin/config.toml`

### Plugins via antidote, not oh-my-zsh

Plugins are declared in `zsh/.zsh_plugins.txt` and compiled by `antidote
load` in `.zshrc` into a single generated bundle, `~/.zsh_plugins.zsh`. That
bundle is **not** tracked in the repo — it's a build artifact, regenerated
on every shell start. To add a plugin, edit `.zsh_plugins.txt`, not the
generated file.

```
# Essential
zsh-users/zsh-autosuggestions
zsh-users/zsh-syntax-highlighting
zsh-users/zsh-history-substring-search
zsh-users/zsh-completions

# Optional quality-of-life
Aloxaf/fzf-tab                    # better tab completion with fzf
```

### Reading the prompt

Starship is set to a flat, single-accent style — no powerline blocks. Left
side is identity + location + git state; right side is timing, right-aligned:

```
andresbecerra ~/dotfiles main !2 ❯                    1.2s 21:42
└user        └dir  └branch └dirty          └cmd_duration └time (right_format)
```

The prompt character itself is signal, not decoration: green `❯` means the
last command succeeded, red means it didn't.

### History that understands context — atuin

`Ctrl+R` opens atuin's full-screen searchable history instead of zsh's
line-by-line one. It's contextual (filter by directory/session) and
syncable across machines if you turn that on later — it works fully
offline by default.

- `↑` / `↓` — substring search (`history-substring-search-up/down`): arrow
  keys filter history by what you've already typed, not just walk it
  linearly.
- `Ctrl+←` / `Ctrl+→` — word-wise cursor movement, bound explicitly.

## 02 — Navigation & files

### Jump, don't `cd`

`cd` is aliased straight to `z` (zoxide). It ranks directories by frecency
(frequency × recency), so after visiting a project a few times, a fragment
of its name is enough:

```sh
cd ml-pipeline        # first visit — needs the real path
cd pipeline            # any later visit — fuzzy match on history
cdi                    # zi — interactive picker when multiple match
```

### List, view, search, find

| Alias | Runs | Why over the default |
|---|---|---|
| `ls` | `eza --icons --group-directories-first` | Icons, dirs first, git-aware colors |
| `ll` | `eza -l --icons --group-directories-first --git` | Long form + per-file git status column |
| `la` | `eza -la ...` | + dotfiles |
| `tree` | `eza --tree --icons` | No separate tool needed |
| `cat` | `bat --paging=never` | Syntax highlighting, still prints to stdout so it composes in pipes |
| `grep` | `rg` | Respects `.gitignore`, far faster on large repos/dataset dirs |

> **For ML repos specifically**: `rg` and `fd` both skip `.gitignore`'d
> paths by default — checkpoint dirs, `__pycache__`, and `.venv` stay out
> of search results automatically, as long as they're gitignored. No
> `--exclude-dir` flags to remember.

### `fzf` as connective tissue

`fzf` is initialized with `eval "$(fzf --zsh)"`, wiring up `Ctrl+T`
(fuzzy-insert a file path), `Ctrl+R` (history — superseded by atuin), and
`Alt+C` (fuzzy-`cd`). Its real value for ML/cloud work is piping into it:

```sh
git branch --all | fzf | xargs git checkout
ls checkpoints/ | fzf                       # pick a checkpoint to inspect
kubectl get pods | fzf | awk '{print $1}'   # pick a pod to tail
```

### `jq` / `yq` for config and API output

Training configs, HF/W&B API responses, and cloud CLI output are almost
always JSON or YAML. Query it instead of eyeballing it:

```sh
cat run_config.json | jq '.hyperparameters.learning_rate'
yq '.spec.template.spec.containers[0].resources' training-job.yaml
aws s3api list-objects --bucket my-checkpoints | jq -r '.Contents[].Key'
curl -s https://api.wandb.ai/... | jq '.runs[] | {name, state}'
```

## 03 — tmux — sessions that outlive your terminal

`tmux/.tmux.conf`

This is the single most load-bearing habit for ML work: **training runs,
long `kubectl logs -f` streams, and agent sessions all belong inside tmux**,
not a bare terminal tab. Close the laptop, lose the SSH connection, switch
networks — the session and everything running in it survives, and you
reattach exactly where you left off.

```sh
tmux new -s train-resnet     # start a named session
# ... kick off training, detach with prefix+d, close laptop, go home ...
tmux attach -t train-resnet  # pick up exactly where you left off
tmux ls                      # see every session still running
```

> **Even survives a reboot**: `tmux-resurrect` + `tmux-continuum` are
> enabled with `@resurrect-strategy-nvim 'session'` (nvim sessions restore
> too) and autosave every 15 minutes. `@continuum-restore` is intentionally
> `'off'` — restore is a conscious action (`prefix` + `Ctrl+r`), not
> silent, so it never surprises you by respawning stale panes on a machine
> you didn't expect it on.

### Panes, the vim way

| Keys | Action |
|---|---|
| `prefix` `\|` | Split vertically, keeping the current working directory |
| `prefix` `-` | Split horizontally, keeping cwd |
| `prefix` `c` | New window, keeping cwd |
| `prefix` `h/j/k/l` | Move between panes, vim-style |
| `prefix` `H/J/K/L` | Resize the current pane (repeatable) |
| `prefix` `r` | Reload `~/.tmux.conf` in place |
| `prefix` `v` (copy-mode) | Begin visual selection (vi-style copy mode) |
| `prefix` `y` (copy-mode) | Copy selection straight to the macOS clipboard (`pbcopy`) |

Pane navigation is also nvim-aware: `vim-tmux-navigator` (an nvim plugin)
means `Ctrl+h/j/k/l` moves between tmux panes *and* nvim splits
interchangeably.

### Reading the status bar

Flat and minimal by design: session name in one accent color, plain window
list (current window bold), live CPU/RAM as plain text, clock on the
right — no icons competing for attention while watching a loss curve
scroll by.

## 04 — Git, reviewed properly

`git/.config/git/{config,ignore}`

### Every diff goes through delta

`core.pager = delta` and `interactive.diffFilter = delta --color-only` are
set globally — `git diff`, `git show`, and `git log -p` are side-by-side,
syntax-highlighted, and line-numbered without asking for it. `navigate =
true` means `n`/`N` jump between file sections inside a diff.

### When to reach for `lazygit` vs. raw `git`

- **Raw `git` / `g` alias** — scripted or one-shot: `git commit -m "..."`,
  `git rebase -i`, anything going in a shell script or CI. Precise,
  composable, reproducible.
- **`lg` → `lazygit`** — anything visual: staging *some* hunks from a messy
  notebook-plus-code change, reviewing a branch's full history, interactive
  rebasing without memorizing the todo-list syntax. Open with `lg` from the
  shell, or `<leader>lg` from inside nvim (floats over the buffer).

### `gh` for the GitHub-shaped parts

```sh
gh pr create --fill                 # open a PR from the current branch
gh pr checks                        # CI status, without leaving the terminal
gh pr view --web                    # drop into the browser only when needed
gh run watch                        # tail a GitHub Actions run live
```

This matters more than it looks for agent-assisted work: an agent that
shells out to `gh` can open and update PRs itself — see [§07](#07--agents--ai-clis).

> **Global ignore, no explicit config needed**: `~/.config/git/ignore` is
> read automatically as the global excludes file — git checks
> `$XDG_CONFIG_HOME/git/ignore` by default, so `core.excludesfile` was
> deliberately left unset rather than hardcoded.

## 05 — Neovim as a Python/ML IDE

`nvim/.config/nvim/` → `init.lua` → `lua/andres/{core,plugins,lsp}`

lazy.nvim auto-loads every file under `lua/andres/plugins/` — each file is
one plugin's spec. Leader is `Space`.

### Finding things — Telescope

| Keys | Action |
|---|---|
| `<leader>ff` | Fuzzy find files in the project |
| `<leader>fs` | Live grep — search file *contents* across the whole repo |
| `<leader>fc` | Search for the word under the cursor |
| `<leader>fr` | Recently opened files |
| `<leader>ft` | Jump to a TODO/FIXME comment |
| `<leader>fk` | Search your own keymaps |

`<leader>fs` is the one you'll use constantly on a large ML codebase —
finding every call site of a training loop function, every place a config
key is read — faster than opening a file tree and guessing.

### Reading & navigating code — LSP

`pyright` is installed automatically by Mason on first launch (see
[§12](#12--tips--gotchas)) and gives full Python type-checking and
completion.

| Keys | Action |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gR` | Find references (in Telescope) |
| `gi` | Find implementations |
| `gt` | Go to type definition |
| `K` | Hover docs |
| `<leader>ca` | Code actions (works on a visual selection too) |
| `<leader>rn` | Rename symbol, project-wide |
| `<leader>d` / `<leader>D` | Line diagnostics / all buffer diagnostics |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>rs` | Restart the LSP (e.g. after switching Python interpreters) |

### Format & lint on save

`conform.nvim` formats Python with **isort → black** on every save
(`format_on_save`, 3s timeout, synchronous). `nvim-lint` runs **pylint** on
`BufWritePost`/`InsertLeave`. Manual trigger: `<leader>mp` to format,
`<leader>l` to lint on demand.

### Everything else, at a glance

- **File tree**: `<leader>ee` toggle · `<leader>ef` reveal current file
- **Git hunks (gitsigns)**: `]h`/`[h` navigate · `<leader>hs` stage ·
  `<leader>hp` preview · `<leader>hb` blame line
- **Diagnostics list (Trouble)**: `<leader>xw` workspace ·
  `<leader>xd` current file only
- **lazygit, floating**: `<leader>lg`
- **Maximize a split**: `<leader>sm`
- **Sessions per project**: `<leader>ws` save · `<leader>wr` restore
  (auto-restore is off by default)
- **Substitute — replace, not just delete**: `<leader>r<motion>` (e.g.
  `<leader>riw` replaces a word)
- **Rusty on motions?**: `:VimBeGood` — a practice game, installed and ready

> **Two plugins present but off**: `which-key.lua` and `flash.lua` exist in
> `lua/andres/plugins/` but are commented out — enable either by
> uncommenting for an on-screen keymap hint popup, or jump-to-anywhere
> motions.

## 06 — Python & ML environments

### `uv` as the default, project by project

For anything that isn't GPU-driver-sensitive — data pipelines, agent
tooling, experiment-tracking scripts, most training code pulling prebuilt
CUDA wheels — `uv` is the faster, simpler default over `pip` + `venv` or
conda:

```sh
uv init my-experiment && cd my-experiment
uv add torch transformers datasets accelerate
uv run train.py                     # runs inside the project's venv, no activation step
uv lock && uv sync                    # reproducible installs, like a lockfile-based pip-tools
```

### When conda still wins

`.zshrc` keeps a guarded conda-init block specifically for this: some
scientific/CUDA packages (certain RAPIDS versions, some compiled
geospatial/chemistry libraries) are still meaningfully easier to get right
through conda's binary package management than through wheels. The guard
means it's a silent no-op if conda isn't installed — reach for it
deliberately per-project, don't default to it.

### `direnv` — stop exporting secrets in `.zshrc`

`eval "$(direnv hook zsh)"` is unconditional in `.zshrc`. The payoff:
per-project API keys, model paths, and cloud profiles that load/unload
automatically as you `cd` in and out — instead of one giant, leaky global
export block.

```sh
# project-a/.envrc
export ANTHROPIC_API_KEY=$(op read op://Personal/anthropic/credential)
export WANDB_PROJECT=resnet-ablation
export AWS_PROFILE=ml-training
layout uv     # direnv's built-in uv/venv integration
```

```sh
cd project-a
direnv: loading project-a/.envrc
direnv: export +ANTHROPIC_API_KEY +AWS_PROFILE +WANDB_PROJECT ~PATH
cd ..
direnv: unloading
```

> **First time in a directory**: direnv refuses to auto-load an `.envrc`
> it hasn't seen before — run `direnv allow` once per file. That's a
> safety feature: it's what stops a cloned repo from silently executing
> shell code the moment you `cd` into it.

## 07 — Agents & AI CLIs

Claude Code and Gemini CLI, composed with the rest of the stack — not
bolted on.

### Run agents inside a named tmux session

`.zshrc` already has this pattern ready, commented out:

```sh
# Uncomment to auto-attach Claude Code inside a dedicated tmux session
alias claude='tmux new-session -A -s claude "claude"'
```

`-A` means "attach if it exists, create if it doesn't" — one alias either
drops you back into a running agent session or starts a fresh one. Same
pattern works for Gemini CLI:

```sh
tmux new-session -A -s gemini "gemini"
```

The payoff is the same as [§03](#03--tmux--sessions-that-outlive-your-terminal):
a long agent run survives you closing the laptop.

### Scope credentials with direnv, not global exports

Different agent projects often need different API keys or model tiers. Put
them in each project's `.envrc` (see [§06](#06--python--ml-environments))
instead of a single global `ANTHROPIC_API_KEY` in `.zshrc`.

### Review agent output the same way you'd review a human's

| Step | Command |
|---|---|
| See what an agent actually changed | `git diff` (through delta) or `lg` for hunk-by-hunk review |
| Recall the exact prompt/command you ran | `Ctrl+R` — atuin's history search works on agent CLI invocations too |
| Let the agent open the PR itself | `gh pr create --fill` |
| Watch CI on an agent-opened PR | `gh pr checks` / `gh run watch` |

### jq as the glue between agent output and everything else

```sh
claude -p "list every TODO in src/" --output-format json | jq -r '.result'
```

> **Multi-agent tmux layout**: `prefix` `|` to put Claude Code in one pane
> and Gemini CLI in another, side by side, in the same tmux window as a
> normal shell pane below. Compare approaches, or run one as a second
> opinion on the other's diff.

## 08 — Cloud provider workflows

This stack doesn't install `aws`/`gcloud`/`az` — it's the glue layer around
whichever ones are in use.

### Parse, don't eyeball

```sh
aws ec2 describe-instances --output json \
    | jq -r '.Reservations[].Instances[] | "\(.InstanceId)\t\(.State.Name)"'

gcloud compute instances list --format=json | jq -r '.[].name' | fzf

kubectl get pods -o json | jq -r '.items[] | select(.status.phase=="Running") | .metadata.name'
```

### Long-lived streams live in tmux

`kubectl logs -f`, `gcloud ... tail`, an SSH tunnel into a training VM —
same rule as [§03](#03--tmux--sessions-that-outlive-your-terminal). A
dropped SSH connection stops being an incident.

### Per-project cloud context via direnv

```sh
# infra-project/.envrc
export AWS_PROFILE=ml-training
export AWS_REGION=us-west-2
export KUBECONFIG=$PWD/.kube/config
export GOOGLE_APPLICATION_CREDENTIALS=$PWD/.gcp/sa.json
```

Walking into a different infra project directory switches account, region,
and cluster context automatically.

### `zoxide` across multi-cloud project trees

If projects are organized like `~/work/{aws,gcp,azure}/<project>`,
zoxide's frecency ranking means `z training-cluster` gets you there
regardless of which provider subtree it's under.

## 09 — Legacy → modern cheat sheet

| Instead of | Use | The actual reason |
|---|---|---|
| `ls` | `eza` (aliased already) | Git status per file, icons, sane defaults |
| `cat` | `bat` (aliased already) | Syntax highlighting when reading |
| `grep -r` | `rg` (aliased already) | Gitignore-aware, multithreaded |
| `find` | `fd <pattern>` | Sane defaults, no flag archaeology |
| `cd` | `z` (aliased already) | Frecency jumping instead of full paths |
| `history \| grep` | atuin (`Ctrl+R`) | Full-screen, contextual, filterable |
| `git diff` | delta (automatic) | Side-by-side + syntax highlighting, no flag |
| `git add -p` / `git log --graph` | `lg` (lazygit) | Visual hunk staging and history |
| `pip` + `venv` | `uv add` / `uv run` | Rust-fast resolver, lockfile-based, no manual activate |
| conda (by default) | `uv` (by default) | conda still available, deliberate per-project choice now |
| `export SECRET=... in .zshrc` | direnv `.envrc` | Scoped, auto-unloaded, never leaks |
| oh-my-zsh | antidote | Lighter, faster shell startup |
| `vim` | `nvim` | LSP, treesitter, async plugins |

## 10 — A day in the life

**09:05 — Jump into the project, environment loads itself**
`z resnet-ablation` → direnv auto-loads `AWS_PROFILE`, `WANDB_PROJECT`, and
activates the project's `uv` venv. No manual `source venv/bin/activate`.

**09:10 — Start (or reattach to) a training session**
`tmux new -s train-resnet` (or `attach` if already running). Split with
`prefix |`: training log left, `watch nvidia-smi` or the tmux CPU/RAM
indicator on the right.

**09:20 — Iterate on the training code**
New tmux window, open `nvim`. `<leader>fs` to find every call site of the
function being changed. Edit; black + isort format on save; pylint flags
an unused import before you even save.

**10:00 — Review and commit**
`<leader>lg` from inside nvim — stage the hunks that matter, leave the
debug `print` unstaged, commit. Delta renders the diff either way.

**10:15 — Hand a refactor to an agent**
Third tmux window: `claude` (auto-attaches its own persistent session).
Point it at the flaky data-loading module. Walk away.

**11:30 — Review the agent's diff like anyone else's**
`git diff` through delta, or `Ctrl+R` in atuin to recall the exact prompt.
Looks right → `gh pr create --fill`, agent-authored PR, human-reviewed.

**17:45 — Close the laptop**
Training's still running in `train-resnet`. The agent session is still
live. tmux-continuum already checkpointed the session layout.

## 11 — Full keybind reference

### nvim — window & tab management

| Keys | Action |
|---|---|
| `jk` (insert) | Exit insert mode |
| `<leader>nh` | Clear search highlight |
| `<leader>+` / `<leader>-` | Increment / decrement number under cursor |
| `<leader>sv` / `<leader>sh` | Split vertically / horizontally |
| `<leader>se` | Equalize split sizes |
| `<leader>sx` | Close current split |
| `<leader>to` / `<leader>tx` | New tab / close tab |
| `<leader>tn` / `<leader>tp` | Next / previous tab |
| `<leader>tf` | Move current buffer into a new tab |

### nvim — text objects & editing

| Keys | Action |
|---|---|
| `<leader>r`{motion} | Substitute text at motion with last yank |
| `<leader>rr` | Substitute the whole line |
| `<leader>R` | Substitute to end of line |
| surround (`ys`/`cs`/`ds`) | nvim-surround's standard mappings |
| `]t` / `[t` | Next / previous TODO comment |
| `ih` / `ah` (textobj) | Inner/around git hunk, as a text object |

### Ghostty

| Keys | Action |
|---|---|
| `⌘D` | Split right |
| `⌘⇧D` | Split down |
| `⌘⌥` + arrows | Move between splits |
| `⌘T` | New tab |
| `⌘W` | Close split |
| `⌘⇧[` / `⌘⇧]` | Previous / next tab |

### zsh aliases, complete list

| Alias | Expands to |
|---|---|
| `ll` / `la` | `eza -l` / `eza -la`, icons + git status |
| `tree` | `eza --tree --icons` |
| `cdi` | `zi` — interactive zoxide picker |
| `lg` | `lazygit` |
| `g` | `git` |
| `..` / `...` | `cd ..` / `cd ../..` |

## 12 — Tips & gotchas

> **First nvim launch after a fresh install needs internet**: Mason
> installs `pyright`, `ts_ls`, `html`, `cssls`, `tailwindcss`, `svelte`,
> `graphql`, `emmet_ls`, `prismals`, plus `prettier`/`stylua`/`isort`/
> `black`/`pylint`/`eslint_d` automatically the first time — that requires
> network access and a working `node`/`npm` (that's why `node` is in the
> Brewfile). `./install.sh` triggers this headlessly via `Lazy! sync`.

> **Never hand-edit `~/.zsh_plugins.zsh`**: it's regenerated by `antidote
> load` on every shell start from `.zsh_plugins.txt`. Edit
> `.zsh_plugins.txt` instead.

> **vim-plug's fzf install won't touch your zshrc**: the legacy `vim`
> package's `Plug 'junegunn/fzf', {'do': './install --all --no-update-rc'}`
> is deliberately pinned with `--no-update-rc` — fzf's own installer
> otherwise appends duplicate shell-integration lines into any rc file it
> finds, colliding with the `eval "$(fzf --zsh)"` already in `.zshrc`.

> **`vim/.vim/plugged/` is gitignored on purpose**: `vim/.vim` is stowed to
> `~/.vim`, so vim-plug's plugin checkouts land physically inside the
> dotfiles repo. They're excluded from git — re-running `vim +PlugInstall
> +qall` (or `./install.sh`) repopulates them on any machine.

> **Replicating this whole setup elsewhere**: `./install.sh` from the repo
> root does the entire thing end to end — Homebrew, `brew bundle`, `stow`
> for all 8 packages, TPM, vim-plug, lazy.nvim, `uv`, `bun`. It's
> idempotent, safe to re-run on a machine that already has some of this
> installed.

> **Two things intentionally not automated**: setting zsh as the default
> shell (`chsh` touches system state, left manual) and Anaconda/Antigravity
> (proprietary installers, outside this repo's scope — the `.zshrc` lines
> that reference them are silently harmless if those aren't installed).

---

~/dotfiles · Andrés Becerra + Claude · Catppuccin Mocha / Latte throughout
