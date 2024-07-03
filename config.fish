###### .dotfiles/fishrc ######

# vi:ft=fish
set DISABLE_FZF_AUTO_COMPLETION true
export TERM="xterm-256color"
export EDITOR="vi"

# PATH settings
# export LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/cuda-11.3/lib:$LD_LIBRARY_PATH
set PATH /opt/homebrew/bin $PATH
set PATH /opt/homebrew/opt/openssl@3/bin $PATH
set PKG_CONFIG_PATH /opt/homebrew/opt/openssl@3/lib/pkgconfig
set LD_LIBRARY_PATH /usr/lib/aarch64-linux-gnu /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib $LD_LIBRARY_PATH
set DYLD_FALLBACK_LIBRARY_PATH /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib $DYLD_FALLBACK_LIBRARY_PATH
set ALIYUNPAN_CONFIG_DIR /home/jhu/aliyunpan
set PATH /home/jhu/dev/bins $PATH

set CUDA_HOME /usr/local/cuda
set LD_LIBRARY_PATH $LD_LIBRARY_PATH /usr/local/cuda/lib64 /usr/local/cuda/extras/CUPTI/lib64
set PATH $PATH $CUDA_HOME/bin

set MPATH /home/jhu/dev/models
set HF_ENDPOINT https://hf-mirror.com

set https_proxy http://127.0.0.1:7890
set http_proxy http://127.0.0.1:7890

# Load HomeBrew
# export HOMEBREW_NO_AUTO_UPDATE=1
# export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles
# test -f /opt/homebrew/bin/brew && eval (/opt/homebrew/bin/brew shellenv)
# test -f /usr/local/bin/brew && eval (/usr/local/bin/brew shellenv)

# if uname | grep Linux
#   set PATH /home/linuxbrew/.linuxbrew/bin $PATH
# end

set HF_ENDPOINT https://hf-mirror.com
set NEBULA_USER root
set NEBULA_PASSWORD nebula
set NEBULA_ADDRESS 127.0.0.1:9669

# Aliases
if string match -q "*amd*" $PLAT
    alias jl="NEBULA_USER=root NEBULA_PASSWORD=nebula NEBULA_ADDRESS=127.0.0.1:9669 HF_ENDPOINT=https://hf-mirror.com RERANKER_DIR=/home/jhu/dev/models/bge-reranker-v2-m3 LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libGLdispatch.so.0 NLTK_DATA=/home/jhu/nltk_data jupyter lab"
else if string match -q "*arm*" $PLAT
    alias jl="NEBULA_USER=root NEBULA_PASSWORD=nebula NEBULA_ADDRESS=127.0.0.1:9669 HF_ENDPOINT=https://hf-mirror.com RERANKER_DIR=/home/jhu/dev/models/bge-reranker-v2-m3 LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libGLdispatch.so.0 NLTK_DATA=/home/jhu/nltk_data jupyter lab"
end
alias newenv="bash /home/jhu/dev/repos/container_runner/newenv.sh"
alias rmenv="bash /home/jhu/dev/repos/container_runner/rmenv.sh"
alias catcon="/home/jhu/dev/repos/container_runner/catcon.sh"
alias pve="ssh 192.168.1.220"
alias netop="sudo nethogs -d 2"
alias apt="sudo apt"
alias dc="docker compose"
alias dul="du -sh (ls -A)"
alias pc=podman-compose
alias gc0="git clone --depth=1 --branch=main"
alias gc1="git clone --depth=1 --branch=master"
alias t='tmux -2'
alias tmux='tmux -2'
alias ta="tmux a -t"
alias tl="tmux ls"
alias tk="tmux kill-session -t"
alias cd..='cd ..'
alias py=python
alias ipy='python -m IPython'
alias g='git'
alias ll='ls -alh'
alias :q='exit'
alias :wq='exit'
alias mkdirp='mkdir -p'
alias shn='sudo shutdown -h now'
alias mirror='wget -E -H -k -K -p'
alias sudo='sudo ' # magic trick to bring aliases to sudo
alias px="proxychains4"
alias lcurl='curl --noproxy localhost'
alias save-last-command='history | tail -n 2 | head -n 1 >> ~/.dotfiles/useful_commands'
alias topcpu='ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head'
alias topmem='ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head'
alias filenum="ls -l | grep "^-" | wc -l"
alias foldernum="ls -l | grep "^d" | wc -l"
alias sub="git submodule update --recursive --remote"
alias gpr="git pull --recurse-submodules"
alias nvtop="watch -n 0.5 nvidia-smi"
# alias pip='noglob pip'

# Venv auto actiavation
function __auto_source_venv --on-variable PWD --description "Activate/Deactivate virtualenv on directory change"
  status --is-command-substitution; and return

  # Check if we are inside a git directory
  if git rev-parse --show-toplevel &>/dev/null
    set gitdir (realpath (git rev-parse --show-toplevel))
  else
    set gitdir ""
  end

  # If venv is not activated or a different venv is activated and venv exist.
  if test "$VIRTUAL_ENV" != "$gitdir/.venv" -a -e "$gitdir/.venv/bin/activate.fish"
    source $gitdir/.venv/bin/activate.fish
  # If venv activated but the current (git) dir has no venv.
  else if not test -z "$VIRTUAL_ENV" -o -e "$gitdir/.venv"
    deactivate
  end
end

# Proxy switcher
function proxy
  if test "$argv[1]" = "on"
    if test "$argv[2]" = ""
      echo "No port provided"
      return 2
    end
    # proxy offered by local shadowsocks
    export http_proxy="http://127.0.0.1:$argv[2]"
    export https_proxy="http://127.0.0.1:$argv[2]"
  else if test "$argv[1]" = "off"
    set -e http_proxy
    set -e https_proxy
  else if test "$argv[1]" != ""
    echo "Usage:
        proxy          - view current proxy
        proxy on PORT  - turn on proxy at localhost:PORT
        proxy off      - turn off proxy"
    return 1
  end
  echo "Current: http_proxy=$http_proxy https_proxy=$https_proxy"
end

# Load fzf config
test -f ~/.dotfiles/fzf.fish && source ~/.dotfiles/fzf.fish

###### .config/fish/config.fish ######
if status is-interactive
    # Commands to run in interactive sessions can go here
end

test -f ~/.dotfiles/fishrc && source ~/.dotfiles/fishrc

###### .dotfiles/fzf.fish ######
# vi:syntax=sh

export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND='fd --type f'
export FZF_ALT_C_COMMAND='fd --type d'
export FZF_COMPLETION_TRIGGER=''
export FZF_DEFAULT_OPTS="--height 40% --reverse --border --prompt '>>> ' \
    --bind 'alt-j:preview-down,alt-k:preview-up,alt-v:execute(vi {})+abort,ctrl-y:execute-silent(cat {} | pbcopy)+abort,?:toggle-preview' \
    --header 'A-j/k: preview down/up, A-v: open in vim, C-y: copy, ?: toggle preview, C-x: split, C-v: vsplit, C-t: tabopen' \
    --preview 'test (du -k {} | cut -f1) -gt 1024 && echo too big || highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {} 2> /dev/null'"
export FZF_CTRL_T_OPTS=$FZF_DEFAULT_OPTS
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window hidden:wrap --bind '?:toggle-preview'"
export FZF_ALT_C_OPTS="--height 40% --reverse --border --prompt '>>> ' \
    --bind 'alt-j:preview-down,alt-k:preview-up,?:toggle-preview' \
    --header 'A-j/k: preview down/up, ?: toggle preview' \
    --preview 'tree -C {}'"
bind \cr 'commandline --replace -- (history | fzf) || commandline --function repaint'

fish_vi_key_bindings




set NLTK_DATA /home/jhu/nltk_data

set -x LC_ALL en_US.UTF-8
set -x LC_CTYPE en_US.UTF-8


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /home/jhu/dev/envs/conda/bin/conda
    eval /home/jhu/dev/envs/conda/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/home/jhu/dev/envs/conda/etc/fish/conf.d/conda.fish"
        . "/home/jhu/dev/envs/conda/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/home/jhu/dev/envs/conda/bin" $PATH
    end
end

if test -f "/home/jhu/dev/envs/conda/etc/fish/conf.d/mamba.fish"
    source "/home/jhu/dev/envs/conda/etc/fish/conf.d/mamba.fish"
end
# <<< conda initialize <<<

set NGC_API_KEY azlkaDFqbnN1MTM3cjlrbzhzZDg4bjV0MDQ6NWYwODU2ZTUtYzQ5My00YzAzLWE2NDgtOTY4YzUwN2U1MGQ1
set CONTAINER_NAME llama3-8b-instruct
set PATH $PATH /home/jhu/dev/repos/ngc-cli

# Choose a LLM NIM Image from NGC
