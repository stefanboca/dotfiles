local return_code="%(?..%{$fg_bold[red]%}%? ↵%{$reset_color%})"

PROMPT='%{$fg[green]%}%n%{$fg[magenta]%}@%{$fg[cyan]%}%m %{$fg[blue]%}%1~$ %{$reset_color%}'
RPS1="${return_code}"

