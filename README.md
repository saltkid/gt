# gt
Various scripts to find local git repositories, let user fuzzy select, and cd to the result. 

# Table of Contents
- [Supported Shells](#supported-shells)
- [Usage](#usage)
- [Requirements](#requirements)
- [How it works](#how-it-works)

# Supported Shells
- POSIX-compliant shells
- pwsh

# Usage
## POSIX-compliant shells
Invoke by sourcing the script. Needs source to be able to `cd` to the chosen directory
```bash
source /path/to/gt
```
Example alias and keybind in zsh:
```zsh
# alias
alias gt="source /path/to/gt"

# keybind
__gt_integ() {
  source /path/to/gt
  zle accept-line # to reset prompt.
                  # can also just use "zle reset-prompt" but that does fully
                  # reset multi level prompts (in p10k) in my experience
}
zle -N __gt_integ
bindkey '^F' __gt_integ
```
> [!Note]
> While the example alias does propagate `gt`'s exit code, the keybind does not

## pwsh
Make sure you set your execution policy accordingly.
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```
Then invoke the script as is.
```powershell
\path\to\gt
```
Example keybind setup:
```powershell
# keybind
function __gtInteg()
{
    \path\to\gt.ps1
}
Set-PSReadLineKeyHandler -Key "Ctrl+f" -ScriptBlock { __gtInteg }
```

# Requirements
## Requried for all
- [fzf](https://github.com/junegunn/fzf) to display found git repos and let user choose directory to `cd` to

## Requried for posix-compliant shells
- [sed](https://www.gnu.org/software/sed/) for trimming `.git/` or `.git` from all found git repos

## Optional for posix-compliant shells
- [fd](https://github.com/sharkdp/fd) as a faster alternative to
[find](https://www.gnu.org/software/findutils/)
    - has unbuffered output like [find](https://www.gnu.org/software/findutils/)
    that's used with `stdbuf -o0`, which means it can stream results directly to
    [sed](https://www.gnu.org/software/sed/) as they are found.

## Optional for pwsh
- [es (Everything CLI)](https://www.voidtools.com/downloads/#cli) is even
faster than [fd](https://github.com/sharkdp/fd).
    - well, that's because es uses a db so obviously it will be faster _once db
    is set up_

# How it works
1. Looks for a `GT_SEARCH_DIRS` env var and assigns defaults if not found
    - Default is `$HOME/projects/:$HOME/work/:$HOME/.config/`
        - `%USERPROFILE%\projects\;%USERPROFILE\work\;%USERPROFILE\.config\` for windows
    - dirs are colon separated (semi-colon on windows because of drives being included in paths)
2. Find all `.git/` dirs (`.git` files for gitmodules) under dirs in `GT_SEARCH_DIRS`
3. Use [sed](https://www.gnu.org/software/sed/) to trim `.git/` or `.git` from all found paths
    - powershell uses its own trimmer
4. Use [fzf](https://github.com/junegunn/fzf) to display results and let user fuzzy choose
5. `cd` to chosen directory
