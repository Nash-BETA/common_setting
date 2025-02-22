# Zsh 補完の初期化
autoload -Uz compinit
compinit

# k8 コマンド
k8() {
  if [ $# -eq 0 ]; then
    kubectl get namespaces
  elif [ $# -eq 1 ]; then
    kubectl get pods -n "$1"
  elif [ $# -eq 2 ]; then
    kubectl exec -it -n "$1" "$2" -- sh
  else
    echo "使用法:"
    echo "1. 名前空間一覧: k8"
    echo "2. 名前空間のポッド一覧: k8 <namespace>"
    echo "3. ポッド内でシェル実行: k8 <namespace> <pod>"
  fi
}

# k8 の補完スクリプト
function _k8_completions {
  local curcontext="$curcontext" state line
  typeset -A opt_args
  _arguments -C \
    '1:namespace:->namespace' \
    '2:pod:->pod' \
    '*::arg:->default'

  case $state in
    namespace)
      local namespaces
      namespaces=($(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}'))
      _describe 'namespace' namespaces
      ;;
    pod)
      local pods
      if [[ -n "$words[2]" ]]; then
        pods=($(kubectl get pods -n "$words[2]" -o jsonpath='{.items[*].metadata.name}'))
        _describe 'pod' pods
      fi
      ;;
  esac
}

compdef _k8_completions k8

# kubectl の補完設定
source <(kubectl completion zsh)

# エイリアスの設定
alias gti='git'
alias python="python3"
# 簡略
alias ra='git diff --diff-filter=ACMR --name-only HEAD | xargs bundle exec rubocop -a'
alias rs='git diff --diff-filter=ACMR --name-only HEAD | grep "^spec/" | grep -v "^spec/factories/" | xargs -r bundle exec rspec'

# git-promptの読み込み
source ~/.zsh/git-prompt.sh
# git-completionの読み込み
fpath=(~/.zsh $fpath)
zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash

# プロンプトのオプション表示設定
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUPSTREAM=auto

# プロンプトの表示設定(好きなようにカスタマイズ可)
setopt PROMPT_SUBST
PS1='%F{green}%n@%m%f: %F{cyan}%~%f %F{red}$(__git_ps1 "(%s)")%f
\$ '

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"

export PATH=$PATH:`npm prefix --location=global`/bin


# aws関連
alias aws_login='unset AWS_PROFILE; aws-azure-login; export AWS_PROFILE=production; unset AWS_PROFILE;'
alias aws_unset='unset AWS_PROFILE'
alias k8s_gname='kubectl get namespaces'
alias k8s_g_p_n='kubectl get pod -n'
alias k8s_ex='(){kubectl exec -it -n $1 $2 -- sh}'
alias k8s_u_s='kubectl config use-context arn:aws:eks:ap-northeast-1:759549166074:cluster/Staging'
alias k8s_u_p='kubectl config use-context arn:aws:eks:ap-northeast-1:759549166074:cluster/Production'



export NODE_OPTIONS='--openssl-legacy-provider'
