provide-module visual-mode %{
    declare-user-mode visual-mode
    declare-user-mode visual-line-mode

    map global visual-mode w <s-w>
    map global visual-mode b <s-b>
    map global visual-mode e <s-e>
    map global visual-mode l <s-l>
    map global visual-mode h <s-h>
    map global visual-mode j <s-j>
    map global visual-mode k <s-j>
    map global visual-mode x <s-j>

    map global visual-line-mode j <s-j><a-x>
    map global visual-line-mode k <s-k><a-x>

    define-command visual-mode -params 1 -docstring 'Enter Visual mode' %{
        set-register v %opt{autoinfo}
        set-option global autoinfo ''
        set-register k "[wbelhjkx%arg{1}]"
        enter-user-mode -lock visual-mode
    }

    define-command visual-line-mode -params 1 -docstring 'Enter Visual line mode' %{
        set-register v %opt{autoinfo}
        set-option global autoinfo ''
        set-register k "[jk%arg{1}]"
        execute-keys x
        enter-user-mode -lock visual-line-mode
    }

    hook global ModeChange push:normal:next-key\[user.visual(-line)?-mode\] %{
        remove-hooks global visual-mode

        hook -once -always -group visual-mode global RawKey "^(?!%reg{k}).*" %{
            #echo -debug "executing key: %val{hook_param}"
            execute-keys -with-hooks -with-maps -save-regs 'v' <esc> %val{hook_param}
        }

        # if we exited visual mode with esc, then don't leave the hook there
        hook -once -always -group visual-mode global NormalIdle .* %{
            remove-hooks global visual-mode
        }
    }

    hook global ModeChange pop:next-key\[user\.visual(-line)?-mode\]:normal %{
        remove-hooks global visual-mode-autoinfo-restore
        hook -once -always -group visual-mode-autoinfo-restore global NormalIdle .* %{
            #echo -debug "restoring autoinfo: %reg{v}"
            set-option global autoinfo %reg{v}
        }
    }
}

