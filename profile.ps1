﻿# ------ Chocolatey Profile ------

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

# ------ Shortcuts ------

function d ($path)
{
    pushd $path
}

function d-
{
    popd
}

function Find-File($pattern)
{
    if (!$pattern)
    {
        Write-Error "Please type the pattern you wish to search for"
        return
    }

    & rg --files --iglob "*$pattern*"
}
Set-Alias ff Find-File

function Find-String($pattern)
{
    if (!$pattern)
    {
        Write-Error "Please type the pattern you wish to search for"
        return
    }

    & rg -i $pattern
}
Set-Alias f Find-String

function sublime ($file)
{
    & 'c:\program files\sublime text 3\subl.exe' $file
}

# ------ Date ------

function get-today
{
    return Get-Date -UFormat "%Y-%m-%d"
}

# ------ Notes ------

$notesPath = "~\notes"

function notes
{
    cd $notesPath
}

function notes-todo
{
    $prevDir = pwd
    cd $notesPath

    rg -i "\- \[ \]"

    cd $prevDir
}

function notes-sync
{
    $prevDir = pwd
    cd $notesPath

    git pull
    git add .
    git commit -m "[Notes] Auto Sync Commit"
    git push

    cd $prevDir
}

function notes-new ($directory)
{
    $today = get-today

    if (!$directory)
    {
        & e "$today.md"
    }
    else
    {
        & e "$directory\$today.md"
    }
}

function notes-search ($pattern)
{
    if (!$pattern)
    {
        echo "Please enter a pattern to search for"
        return
    }

    pushd
    notes

    rg -i $pattern

    popd
}

# ------ Git ------

function git-sync
{
    git pull
    git add .
    git commit -m "Auto Sync Commit"
    git push
}

function git-sync-all
{
    echo "------ Syncing PSConfig ------"
    pushd ~\psconfig
    git-sync

    echo "------ Syncing VimConfig ------"
    cd ~\.vim
    git-sync

    echo "------ Syncing Notes ------"
    notes
    git-sync

    popd
}

function git-checkout ($pattern)
{
    $b = ""
    if ($pattern)
    {
        $b = git branch -a
        $b = $b | sls $pattern
    }
    else
    {
        $b = git branch
    }

    if (!$b)
    {
        return
    }

    $b = $b | sort | fzf
    if (!$b)
    {
        return
    }

    $b = $b.Replace("*", "").Trim()
    $b = $b.Replace("remotes/origin/", "")

    echo "Checking out branch: $b"

    git checkout $b
}

function git-diff
{
    git diff
}

function git-status
{
    git status
}

function git-pull
{
    git pull
}

function git-push
{
    git push
}

function git-get-current-branch
{
    $branch = git branch | sls "\* (.*)" -AllMatches | %{$_.Matches.Groups[1].Value}
    return $branch
}

function git-push-setupstream
{
    $branch = git-get-current-branch
    & git push origin --set-upstream $branch
}

function git-clone ($repo)
{
    if (!$repo)
    {
        Write-Output "Please enter a repository path"
    }
    else
    {
        git clone git@github.com:$repo
    }
}

function git-commit-and-push ($message)
{
    if (!$message)
    {
        Write-Output "Please enter a commit message"
    }
    else
    {
        git commit -am $message; git push
    }
}

# ------ Visual Studio Code ------

# ------ Fast Edits ------

function evim
{
    e ~\.vim\.vimrc
}

function epp
{
    e ~\psconfig\profile.ps1
}

function e ($file)
{
    if (!$file)
    {
        $file = fzf
        e $file
    }
    else
    {
        gvim --remote-silent $file
    }
}

# ------ Utilities ------

function copy-file($source, $destination)
{
    run-in-another-window
}

function run-in-another-window($command)
{
    & cmd /c start powershell -Command { iex $command; pause }
}

# ------ Directory Commands ------

function ws
{
    cd c:\Workspace
}

function repos
{
    cd c:\Workspace\Repositories
}

function temp
{
    cd c:\temp
}

function home
{
    cd ~
}

# ------ Initialization ------

function Install-Personal-Dependencies
{
    Install-Module PSReadLine
    Install-Module PSFzf
    Install-Module PowerShellGet -Force -AllowClobber

    PowerShellGet\Install-Module posh-git -AllowPrerelease -Force
}

function Initialize-Personal-Powershell
{
    $powershellShortcutPath = "$Home\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Windows PowerShell"
    $shortcutPath = "$PSScriptRoot\Windows PowerShell.lnk"
    & cp $shortcutPath $powershellShortcutPath

    Import-Module Posh-Git
    $GitPromptSettings.BeforeStatus.Text = "`n["
    $GitPromptSettings.AfterStatus.Text = "]`n"
    $GitPromptSettings.DefaultPromptPath.ForegroundColor = 0x569CD6

    Import-Module PSReadLine

    Set-PSReadlineOption -BellStyle None
    Set-PSReadlineOption -ShowToolTips
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Remove-PSReadlineKeyHandler "Ctrl+r"

    Import-Module PSFzf
    Import-Module BitsTransfer
}

Initialize-Personal-Powershell
