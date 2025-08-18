code ~/.bashrc
# no ~/.bash_profile
[ -f ~/.bashrc ] && . ~/.bashrc


# --- Git completion ---
if [ -f /usr/share/git/completion/git-completion.bash ]; then
  . /usr/share/git/completion/git-completion.bash
elif [ -f /mingw64/share/git/completion/git-completion.bash ]; then
  . /mingw64/share/git/completion/git-completion.bash
fi

# (Opcional) prompt do Git com o nome do branch
if [ -f /usr/share/git/completion/git-prompt.sh ]; then
  . /usr/share/git/completion/git-prompt.sh
elif [ -f /mingw64/share/git/completion/git-prompt.sh ]; then
  . /mingw64/share/git/completion/git-prompt.sh
fi
# Exemplo simples de prompt mostrando o branch:
# PS1='[\u@\h \W$(__git_ps1 " (%s)")]$ '


source ~/.bashrc

[ -f ~/.git-completion.bash ] && . ~/.git-completion.bash
