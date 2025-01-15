param (
    [switch]$fast,
    [switch]$f,
    [switch]$help,
    [switch]$h,
    [switch]$version,
    [switch]$v
)

$env:gt_VERSION="0.0.1-dev"

if (-not $env:gt_SEARCH_DIRS)
{
    $env:gt_SEARCH_DIRS = "$env:USERPROFILE\projects\;$env:USERPROFILE\work\;$env:USERPROFILE\.config\"
}

function __gtMain
{
    $exitcode = 0
    if (-not (Get-Command "fzf" -ErrorAction SilentlyContinue))
    {
        Write-Host "ERROR: 'fzf' is not installed"
        $exitcode = 1
    } elseif ($help -or $h)
    {
        __gthelp
    } elseif ($version -or $v)
    {
        Write-Host $env:gt_VERSION
    } elseif ($fast -or $f)
    {
        __gtfast
    } elseif (-not ($help -or $h -or $version -or $v -or $fast -or $f)) 
    {
        __gtnormal
    } else
    {
        Write-Host "ERROR: Unknown option"
        __gthelp
    }
    return $exitcode
}

function __gtHelp
{
    Write-Host '
gt finds local git repos and cd to whichever one is fuzzy selected.
Uses the semi-colon separated $env:GT_SEARCH_DIRS to search for git repos

Usage: gt [option]
Options:
                 leave empty to use "Get-ChildItem"
-f | --fast      uses "es" instead
-h | --help      prints this help message
-v | --version   prints the version
'
}

function __gtNormal
{
    $selected = $( `
            $env:gt_SEARCH_DIRS -split ';' `
        | ForEach-Object `
        { `
                Get-ChildItem -Path $_ -Recurse -Directory -Filter ".git" -Depth 3 -Hidden `
            | ForEach-Object { Split-Path $_.FullName -Parent } `
        } | fzf `
    )
    if ($selected)
    {
        Set-Location $selected
    }
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.SendKeys]::SendWait("{Enter}")
}

function __gtFast
{
    # es is the fastest (once set up) so we're not using fd on windows
    $selected = $(es -w .git /a[DH] | ForEach-Object { $_ -replace '\\.git', '' } | fzf)
    if ($selected)
    {
        Set-Location $selected
    }
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.SendKeys]::SendWait("{Enter}")
}

exit __gtMain
_gtMain
