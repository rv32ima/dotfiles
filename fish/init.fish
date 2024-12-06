# exports
if test -f "$HOME/.nix-profile/etc/profile.d/nix.fish"
  source "$HOME/.nix-profile/etc/profile.d/nix.fish"
end

if ! infocmp iTerm2.app &> /dev/null
  if [ "$TERM" = 'iTerm2.app' ]
    set -gx TERM 'xterm-256color'
  end
else
  if set -q LC_TERMINAL && [ "$LC_TERMINAL" = 'iTerm2' -a "$TERM" != 'iTerm2.app' -a "$TERM" != 'tmux-256color' -a "$TERM" != 'screen-256color' ]
    set -gx TERM 'iTerm2.app'
  end
end

# TokyoNight Night
# fish_config theme choose "TokyoNight Night" 

set -gx LANG 'en_US.UTF-8'
set -gx LC_ALL $LANG
set -gx LANGUAGE $LANG

set -gx EDITOR nvim
set -gx VISUAL $EDITOR
set -gx SUDO_EDITOR $EDITOR

set -gx PAGER "bat -p"

set -gx XDG_CONFIG_HOME ~/.config
set -gx XDG_DATA_HOME ~/.local/share

# disable that damn fish greeting 
set -U fish_greeting

# --- paths ---
# homebrew binaries
fish_add_path "/usr/sbin"
fish_add_path "/usr/local/sbin"
fish_add_path "$HOME/bin"
fish_add_path "$HOME/.cargo/bin"
fish_add_path "/usr/local/go/bin"
fish_add_path "$HOME/go/bin"

# --- aliases ---
alias ssh="TERM=xterm-256color command ssh"
alias xssh='TERM=xterm-256color ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking no"'
alias ls="eza"
alias cat="bat -p"
alias bazel="bazelisk"

# Git Branch Pull (create a new branch from what's on the main branch)
function gbp
  git symbolic-ref refs/remotes/origin/HEAD | read -d / -a PARTS
  set MAIN_BRANCH $PARTS[4]
  printf 'Detected main branch %s\n' "$MAIN_BRANCH"
  # Check out the main branch
  git checkout $MAIN_BRANCH
  # See if we have any changes in the main branch
  git diff-files --quiet
  if test $status -eq 1;
    git stash -m "Automatic stash at (date)"
  end
  git pull --rebase
  git branch -f $argv[1]
  git checkout $argv[1]
end

# Git Stash Pop
function gsp
  git stash pop
end

# Git Branch Main (stash whatever's on our current branch, switch to the main branch, pull)
function gbm
  git symbolic-ref refs/remotes/origin/HEAD | read -d / -a PARTS
  set MAIN_BRANCH $PARTS[4]
  printf 'Detected main branch %s\n' "$MAIN_BRANCH"
  # See if we have any changes in our current branch
  # that we haven't committed - automatically stash if
  # so.
  git diff-files --quiet
  if test $status -eq 1;
    git stash -m "Automatic stash at (date)"
  end
  # Check out the main branch
  git checkout $MAIN_BRANCH
  git pull --rebase
end

function vsc
  if [ -x "$(which code 2>/dev/null)" ]
    code $argv[1]
  else if [ -d "/Applications/Visual Studio Code.app" ]
    open -a "Visual Studio Code" $argv[1]
  else if [ -d "/Applications/Nix Apps/Visual Studio Code.app" ]
    open -a "Visual Studio Code" $argv[1]
  else if [ -d "$HOME/.vscode-server" ]
    set INSTALL (jq -r '.[0]' $HOME/.vscode-server/cli/servers/lru.json)
    "$HOME/.vscode-server/cli/servers/$INSTALL/server/bin/remote-cli/code" $argv[1]
  else
    echo "couldn't find any way of opening in visual studio code :-("
  end
end

function tailscale
  if [ -x "$(which tailscale 2>/dev/null)" ]
    tailscale $argv
  else if [ -x "/Applications/Tailscale.app/Contents/MacOS/Tailscale" ]
    /Applications/Tailscale.app/Contents/MacOS/Tailscale $argv
  else
    echo "couldn't find a way to execute tailscale CLI"
  end

end

function graph
  dot -Efontsize=24 \
      -Gdpi=300 \
      -Efontname="Berkeley Mono" \
      -Nfontname="Berkeley Mono" \
      -Tpng \
      -O $argv[1]
end

function graph_invert
  dot -Efontsize=24 \
      -Gdpi=300 \
      -Efontname="Berkeley Mono" \
      -Nfontname="Berkeley Mono" \
      -Tpng \
      -Gbgcolor=black \
      -Gcolor=white \
      -Ecolor=white \
      -Efontcolor=white \
      -Ncolor=white \
      -Nfontcolor=white \
      -O $argv[1]
end

function idot
  set -l graph_input
  while read line
    set graph_input $graph_input $line
  end

  set dir (mktemp -d)
  trap "rm -r $dir" EXIT
  set graph_file "$dir/graph.dot"
  set graph_out_file "$dir/graph.dot.png"
  echo $graph_input > $graph_file
  graph_invert $graph_file

  set graph_fixed_file "$dir/graph.dot-fixed.png"
  magick convert -trim \
          -bordercolor black \
          -border 20 \
          -transparent black \
          -resize '50%' \
          $graph_out_file \
          $graph_fixed_file 2>/dev/null

  kitty icat --transfer-mode memory --align left $graph_fixed_file 2>/dev/null
end

# If /opt/homebrew/bin/brew exists, then we're on a Mac-based machine
if test -f /opt/homebrew/bin/brew
  /opt/homebrew/bin/brew shellenv | source
  fish_add_path "/opt/homebrew/opt/llvm/bin"
end

# setup starship
if test -x "$(which starship 2>/dev/null)"
  starship init fish | source
end

# If we aren't already connected via SSH
# then we should launch the gpg-agent so we can get an SSH agent.
if test -x "$(which gpgconf 2>/dev/null)" -a -z "$SSH_CONNECTION"
  gpgconf --launch gpg-agent &>/dev/null
  if test $status -eq 0;
    set -gx GPG_TTY (tty)
    set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
  end
end

if test -e "${XDG_CONFIG_HOME}/fish/iterm2_shell_integration.fish"
  source "${XDG_CONFIG_HOME}/fish/iterm2_shell_integration.fish"
end

if test -x "$(which pyenv 2>/dev/null)"
  set -Ux PYENV_ROOT "$HOME/.pyenv"
  fish_add_path "$PYENV_ROOT/bin"
  pyenv init - | source
end

