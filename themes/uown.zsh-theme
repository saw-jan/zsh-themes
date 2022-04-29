# icons
USER_ICO='\uf31b'
FOLDER_ICO='\uf115'
NODE_ICO='\uf7d7'
PACKAGE_ICO='\uf487'
GIT_BRANCH_ICO='\uf418'

prompt_segment() {
    local bg fg
    [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
    [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
    echo -n "%{$bg%}%{$fg%} "
    [[ -n $3 ]] && echo -n $3
}

prompt_me() {
    prompt_segment white black "%(!.%{%F{yellow}%}.)$USER_ICO "
}

prompt_git() {
    (( $+commands[git] )) || return
    if [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
        return
    fi
    local PL_BRANCH_CHAR
    () {
        local LC_ALL="" LC_CTYPE="en_US.UTF-8"
        PL_BRANCH_CHAR=$GIT_BRANCH_ICO
    }
    local ref dirty mode repo_path

    if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]]; then
        repo_path=$(git rev-parse --git-dir 2>/dev/null)
        dirty=$(parse_git_dirty)
        ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"
        if [[ -n $dirty ]]; then
            prompt_segment default yellow
        else
            prompt_segment default green
        fi

        if [[ -e "${repo_path}/BISECT_LOG" ]]; then
            mode=" <B>"
        elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
            mode=" >M<"
        elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
            mode=" >R>"
        fi

        setopt promptsubst
        autoload -Uz vcs_info

        zstyle ':vcs_info:*' enable git
        zstyle ':vcs_info:*' get-revision true
        zstyle ':vcs_info:*' check-for-changes true
        zstyle ':vcs_info:*' stagedstr '✚'
        zstyle ':vcs_info:*' unstagedstr '±'
        zstyle ':vcs_info:*' formats ' %u%c'
        zstyle ':vcs_info:*' actionformats ' %u%c'
        vcs_info
        echo -n "${ref/refs\/heads\//$PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${mode}"
    fi
}

prompt_dir() {
    # storage size
    # dir_size=$(pwd | du -hs | tr -d '[:space:]' | sed -e 's/[.]*$//')
    DIR=$(pwd)
    HOME=$(echo ~)
    if [ $DIR = $HOME ] || [ $DIR = '/' ]; then
        prompt_segment default default "$FOLDER_ICO  %~"
    else
        prompt_segment default default "$FOLDER_ICO  %1~"
    fi
}

prompt_pwd() {
    DIR=$(pwd)
    PARENT="$(dirname "$DIR")"
    if [ $PARENT != '/' ]; then
        echo "\n\e[90m\e[3m\u250c $PARENT"
    fi
}

prompt_status() {
    local -a symbols

    [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"
    [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
    [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

    [[ -n "$symbols" ]] && prompt_segment white black "$symbols"
}

prompt_nodejs() {
    is_nodeapp=$(find . -maxdepth 1 -name package.json)
    if [ $is_nodeapp ]; then
        node_ver=$(node -v |cut -c 1-3)
        package_ver=$(grep '"version"' package.json | cut -d ':' -f 2 | tr -d '",')
        if [ $node_ver ]; then
            prompt_segment default green $NODE_ICO" "$node_ver
            prompt_segment default cyan $PACKAGE_ICO""$package_ver
        fi
    fi
}

prompt_indicator() {
    prompt_segment default default "\e[90m\n\u2514%F{default} "
}

## Main prompt
build_prompt() {
    RETVAL=$?
    prompt_me
    prompt_dir
    prompt_nodejs
    prompt_git
    prompt_indicator
}

PROMPT='$(prompt_pwd)'$'\n''%{%f%b%k%}$(build_prompt)'
RPROMPT='$(prompt_status)'
