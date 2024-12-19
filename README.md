# gt
Various scripts to find local git repositories, let user fuzzy select, and cd to the result. 

# How it works
1. Looks for a `GT_SEARCH_DIRS` env var and assigns defaults if not found
    - Default is `$HOME/projects/:$HOME/work/:$HOME/.config/`
        - `%USERPROFILE%\projects\;%USERPROFILE\work\;%USERPROFILE\.config\` for windows
    - dirs are colon separated (semi-colon on windows because of drives being included in paths)
2. Find all `.git/` under dirs in `GT_SEARCH_DIRS`
3. Use [sed](https://www.gnu.org/software/sed/) to trim `.git/` from all found paths
    - powershell uses its own trimmer
4. Use [fzf](https://github.com/junegunn/fzf) to display results and let user fuzzy choose
5. `cd` to chosen directory

# Usage
```bash
source path/to/gt
```
Needs source to be able to `cd` to the chosen directory. In zsh for example, you can just make an
alias or a keybind.
```zsh
# alias
alias gt="source /path/to/gt"

# keybind
__gt_integ() {
  source /path/to/gt
  zle accept-line
}
zle -N __gt_integ
bindkey '^F' __gt_integ
```

# Supported Shells
- Any shell that can execute a `#!/bin/sh` script
- pwsh


# Requirements
## Requried for all
- [fzf](https://github.com/junegunn/fzf)
    - used to display found git repos and let user choose directory to `cd` to

## Optional for Linux and Mac
- [fd](https://github.com/sharkdp/fd)
    - faster alternative to [find](https://www.gnu.org/software/findutils/)
    - has unbuffered output like [find](https://www.gnu.org/software/findutils/) with `stdbuf -o0`,
    which means it can stream results directly to [sed](https://www.gnu.org/software/sed/) as they
    are found.
        - [sd](https://github.com/chmln/sd) currently does not support unbuffered output so sadly,
        it cannot be used as a faster alternative here. A [pr](https://github.com/chmln/sd/pull/287)
        is up though

## Optional for Windows
- [es (Everything CLI)](https://www.voidtools.com/downloads/#cli)
    - faster than [fd](https://github.com/sharkdp/fd). well, that's because es uses a db so
    obviously it will be faster _once db is set up_
