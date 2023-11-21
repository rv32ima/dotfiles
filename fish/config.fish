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

set -gx LANG 'en_US.UTF-8'
set -gx LC_ALL $LANG
set -gx LANGUAGE $LANG

set -gx EDITOR nvim
set -gx VISUAL $EDITOR
set -gx SUDO_EDITOR $EDITOR

set -gx PAGER bat
# set -gx MANPAGER sh -c 'col -bx | bat -l man -p'

set -gx XDG_CONFIG_HOME ~/.config
set -gx XDG_DATA_HOME ~/.local/share

set -gx GPG_TTY "$(tty)"
set -gx SSH_AUTH_SOCK $(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

set -gx BUN_INSTALL "$HOME/.bun"

# disable that damn fish greeting 
set -U fish_greeting

# --- paths ---
# homebrew binaries
fish_add_path "$HOME/bin"
fish_add_path "$HOME/.cargo/bin"
fish_add_path "$BUN_INSTALL/bin"
fish_add_path "$HOME/.aftman/bin"
fish_add_path "/opt/homebrew/opt/llvm/bin"

# --- aliases ---
alias ssh="TERM=xterm-256color command ssh"
alias xssh='ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking no"'
alias ls="eza"
alias cat="bat"

function idot
  set -l graph_input
  while read line
    set graph_input $graph_input $line
  end
  set rendered_graph $(echo $graph_input | dot -Efontsize=24 \
                                               -Efontname="Berkeley Mono" \
                                               -Nfontname="Berkeley Mono" \
                                               -Tpng \
                                               -Gbgcolor=black \
                                               -Gcolor=white \
                                               -Ecolor=white \
                                               -Efontcolor=white \
                                               -Ncolor=white \
                                               -Nfontcolor=white | base64)
  string length -q $rendered_graph;
  if test $status -ne 0
    return
  end
  
  echo $rendered_graph |\
    base64 --decode |\
    convert -trim \
            -bordercolor black \
            -border 20 \
            -transparent black \
            -resize '100%' - - |\
    imgcat
end

# setup homebrew
/opt/homebrew/bin/brew shellenv | source
# setup starship
starship init fish | source
