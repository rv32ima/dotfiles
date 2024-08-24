# exports
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
fish_config theme choose "TokyoNight Night"

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
fish_add_path "$HOME/bin"
fish_add_path "$HOME/.cargo/bin"
fish_add_path "/usr/local/go/bin"
fish_add_path "$HOME/go/bin"

# --- aliases ---
alias ssh="TERM=xterm-256color command ssh"
alias xssh='TERM=xterm-256color ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking no"'
alias ls="eza"
alias cat="bat -p"

function vsc
  if [ -x "$(which code)" ]
    code $argv[1]
  else if [ -d "/Applications/Visual Studio Code.app" ]
    open -a "Visual Studio Code" $argv[1]
  else
    echo "couldn't find any way of opening in visual studio code :-("
    exit 1
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
  convert -trim \
          -bordercolor black \
          -border 20 \
          -transparent black \
          -resize '50%' \
          $graph_out_file \
          $graph_fixed_file

  imgcat $graph_fixed_file
end

# If /opt/homebrew/bin/brew exists, then we're on a Mac-based machine
if test -f /opt/homebrew/bin/brew
  /opt/homebrew/bin/brew shellenv | source
  fish_add_path "/opt/homebrew/opt/llvm/bin"
end

# setup starship
if test -x (which starship)
  starship init fish | source
end

# If we don't already have an SSH_AUTH_SOCK,
# then we should launch the gpg-agent so we can get one.
if test -x (which gpgconf) -a -n $SSH_AUTH_SOCK
  gpgconf --launch gpg-agent &>/dev/null
  if test $status -eq 0;
    set -gx GPG_TTY (tty)
    set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
  end
end
