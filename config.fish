if status is-interactive
    # Commands to run in interactive sessions can go here
end

# ===== base env =====
set -gx DISABLE_FZF_AUTO_COMPLETION true
set -gx TERM xterm-256color
set -gx EDITOR vi

# ===== path / library settings =====
# Paths can safely exist or not; nonexistent entries do not crash fish.
set -gx PATH /opt/homebrew/bin $PATH
set -gx PATH /opt/homebrew/opt/openssl@3/bin $PATH
set -gx PKG_CONFIG_PATH /opt/homebrew/opt/openssl@3/lib/pkgconfig
set -gx LD_LIBRARY_PATH /usr/lib/aarch64-linux-gnu /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib $LD_LIBRARY_PATH
set -gx DYLD_FALLBACK_LIBRARY_PATH /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib $DYLD_FALLBACK_LIBRARY_PATH

set -gx ALIYUNPAN_CONFIG_DIR /home/jhu/aliyunpan
set -gx PATH /home/jhu/dev/bins $PATH
set -gx PATH /home/jhu/dev/bins/ffmpeg/bin $PATH

set -gx CUDA_HOME /usr/local/cuda
set -gx LD_LIBRARY_PATH $LD_LIBRARY_PATH /usr/local/cuda/lib64 /usr/local/cuda/extras/CUPTI/lib64 /usr/lib/x86_64-linux-gnu
set -gx PATH $PATH $CUDA_HOME/bin

set -gx MPATH /home/jhu/dev/models
set -gx HF_ENDPOINT https://hf-mirror.com

set -gx NEBULA_USER root
set -gx NEBULA_PASSWORD nebula
set -gx NEBULA_ADDRESS 127.0.0.1:9669

# ===== aliases =====
# Avoid hard failure on systems without dpkg.
set -l __plat unknown
if command -sq dpkg
    set __plat (dpkg --print-architecture)
else if test (uname -m) = x86_64
    set __plat amd64
else if test (uname -m) = aarch64 -o (uname -m) = arm64
    set __plat arm64
end

if string match -q "*amd*" $__plat
    alias jl="PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True NEBULA_USER=root NEBULA_PASSWORD=nebula NEBULA_ADDRESS=127.0.0.1:9669 HF_ENDPOINT=https://hf-mirror.com RERANKER_DIR=/home/jhu/dev/models/bge-reranker-v2-m3 LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libGLdispatch.so.0 NLTK_DATA=/home/jhu/nltk_data jupyter lab"
else if string match -q "*arm*" $__plat
    alias jl="NEBULA_USER=root NEBULA_PASSWORD=nebula NEBULA_ADDRESS=127.0.0.1:9669 HF_ENDPOINT=https://hf-mirror.com RERANKER_DIR=/home/jhu/dev/models/bge-reranker-v2-m3 LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libGLdispatch.so.0 NLTK_DATA=/home/jhu/nltk_data jupyter lab"
end

alias newenv="bash /home/jhu/dev/repos/container_runner/newenv.sh"
alias rmenv="bash /home/jhu/dev/repos/container_runner/rmenv.sh"
alias pixict="bash /home/jhu/dev/repos/container_runner/pixictl.sh"
alias catcon="/home/jhu/dev/repos/container_runner/catcon.sh"
alias pve="ssh 192.168.1.220"
alias netop="sudo nethogs -d 2"
alias apt="sudo apt"
alias dc="docker compose"
alias dul="sudo du -sh (ls -A)"
alias pc=podman-compose
alias jt="sudo jtop"
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
alias sudo='sudo '
alias px="proxychains4"
alias lcurl='curl --noproxy localhost'
alias save-last-command='history | tail -n 2 | head -n 1 >> ~/.dotfiles/useful_commands'
alias topcpu='ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head'
alias topmem='ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head'
alias filenum="ls -l | grep '^- ' | wc -l"
alias foldernum="ls -l | grep '^d' | wc -l"
alias sub="git submodule update --recursive --remote"
alias gpr="git pull --recurse-submodules"
alias gcr="git clone --recursive"
alias nvtop="watch -n 0.5 nvidia-smi"
alias pi="pip install --proxy=http://192.168.1.222:7897"
alias ma="mamba activate"
alias md="mamba deactivate"
alias cl="sudo socat TCP-LISTEN:7892,fork,reuseaddr,bind=0.0.0.0 TCP:127.0.0.1:7890"

# ===== venv auto activation =====
function __auto_source_venv --on-variable PWD --description "Activate/Deactivate virtualenv on directory change"
    status --is-command-substitution; and return

    set -l gitdir ""
    if command -sq git
        if git rev-parse --show-toplevel >/dev/null 2>/dev/null
            set gitdir (realpath (git rev-parse --show-toplevel))
        end
    end

    if test -n "$gitdir"
        if test "$VIRTUAL_ENV" != "$gitdir/.venv" -a -e "$gitdir/.venv/bin/activate.fish"
            source "$gitdir/.venv/bin/activate.fish"
        else if test -n "$VIRTUAL_ENV"
            if not test -e "$gitdir/.venv"
                if functions -q deactivate
                    deactivate
                end
            end
        end
    else
        if test -n "$VIRTUAL_ENV"
            if functions -q deactivate
                deactivate
            end
        end
    end
end

function gc1
    if test (count $argv) -ne 1
        echo "Usage: gc <repository_url>"
        return 1
    end

    git clone --depth=1 --no-checkout $argv[1]
    if test $status -ne 0
        return $status
    end

    set repo_dir (basename $argv[1] .git)
    cd $repo_dir

    set default_branch (git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
    git checkout $default_branch
end

# ===== proxy switcher =====
function proxy
    if test "$argv[1]" = "on"
        if test "$argv[2]" = ""
            echo "No port provided"
            return 2
        end
        set -gx http_proxy "http://127.0.0.1:$argv[2]"
        set -gx https_proxy "http://127.0.0.1:$argv[2]"
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

function rmsub
    set -l submodule_path $argv[1]

    if test -z "$submodule_path"
        echo "Usage: remove_git_submodule <submodule-path>"
        return 1
    end

    echo "Removing submodule at path: $submodule_path"

    git submodule deinit -f $submodule_path
    if test $status -ne 0
        echo "Failed to deinit submodule"
        return 1
    end

    set -l submodule_name (string replace -r '.*\/' '' $submodule_path)
    rm -rf .git/modules/$submodule_name
    if test $status -ne 0
        echo "Failed to remove submodule directory from .git/modules"
        return 1
    end

    git config -f .gitmodules --remove-section submodule.$submodule_path
    if test $status -ne 0
        echo "Failed to remove submodule entry from .gitmodules"
        return 1
    end

    git config -f .git/config --remove-section submodule.$submodule_path
    if test $status -ne 0
        echo "Failed to remove submodule entry from .git/config"
        return 1
    end

    git rm -f $submodule_path
    if test $status -ne 0
        echo "Failed to remove submodule directory from working tree"
        return 1
    end

    echo "Submodule removed successfully!"
end

# ===== optional fzf config =====
if test -f ~/.dotfiles/fzf.fish
    source ~/.dotfiles/fzf.fish
end

# ===== local config =====
set -gx NLTK_DATA /home/jhu/nltk_data

set -gx LC_ALL en_US.UTF-8
set -gx LC_CTYPE en_US.UTF-8

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# if test -f /home/jhu/dev/envs/conda/bin/conda
#     eval /home/jhu/dev/envs/conda/bin/conda "shell.fish" "hook" $argv | source
# else
#    if test -f "/home/jhu/dev/envs/conda/etc/fish/conf.d/conda.fish"
#        source "/home/jhu/dev/envs/conda/etc/fish/conf.d/conda.fish"
#    else
#        set -gx PATH "/home/jhu/dev/envs/conda/bin" $PATH
#    end
# end

# if test -f "/home/jhu/dev/envs/conda/etc/fish/conf.d/mamba.fish"
#     source "/home/jhu/dev/envs/conda/etc/fish/conf.d/mamba.fish"
# end
# <<< conda initialize <<<

set -gx NGC_API_KEY azlkaDFqbnN1MTM3cjlrbzhzZDg4bjV0MDQ6NWYwODU2ZTUtYzQ5My00YzAzLWE2NDgtOTY4YzUwN2U1MGQ1
set -gx CONTAINER_NAME llama3-8b-instruct
set -gx PATH $PATH /home/jhu/dev/repos/ngc-cli
set -gx PATH $PATH $HOME/.bun/bin
set -gx PATH $HOME/.local/bin $PATH

umask 002

# bun
set -gx BUN_INSTALL "$HOME/.bun"
set -gx PATH $BUN_INSTALL/bin $PATH

if functions -q fish_add_path
    fish_add_path /home/jhu/.pixi/bin
else
    set -gx PATH /home/jhu/.pixi/bin $PATH
end

# optional local integrations
if test -f /home/jhu/clashctl/scripts/cmd/clashctl.fish
    source /home/jhu/clashctl/scripts/cmd/clashctl.fish
end
