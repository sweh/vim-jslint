"
" JavaScript filetype plugin for running jshint
" Language:     JavaScript (ft=javascript)
" Maintainer:   Sebastian Wehrmann (sebastian.wehrmann@icloud.com)
" Version:      Vim 7 (may work with lower Vim versions, but not tested)
" URL:          http://bitbucket.org/sweh/vim-jshint
"
" Only do this when not done yet for this buffer
if exists("b:loaded_jshint_ftplugin")
    finish
endif
let b:loaded_jshint_ftplugin=1

if !exists("*JSHint()")
    function JSHint()
        if exists("g:jshint_cmd")
            let s:jshint_cmd=g:jshint_cmd
        else
            let s:jshint_cmd="jslint"
        endif

        if !executable(s:jshint_cmd)
            echoerr "File " . s:jshint_cmd . " not found. Please install it first."
            return
        endif

        set lazyredraw   " delay redrawing
        cclose           " close any existing cwindows

        " store old grep settings (to restore later)
        let l:old_gfm=&grepformat
        let l:old_gp=&grepprg

        " write any changes before continuing
        if &readonly == 0
            update
        endif

        " perform the grep itself
        let &grepformat="%-P%f,
                    \%E%>\ #%n\ %m,%Z%.%#Line\ %l\\,\ Pos\ %c,
                    \%-G%f\ is\ OK.,%-Q"
        let &grepprg=s:jshint_cmd
        silent! grep! %

        " restore grep settings
        let &grepformat=l:old_gfm
        let &grepprg=l:old_gp

        " open cwindow
        let has_results=getqflist() != []
        if has_results
            execute 'belowright copen'
            setlocal wrap
            nnoremap <buffer> <silent> c :cclose<CR>
            nnoremap <buffer> <silent> q :cclose<CR>
        endif

        set nolazyredraw
        redraw!

        if has_results == 0
            " Show OK status
            hi Green ctermfg=green
            echohl Green
            echon "JSHint check OK"
            echohl
        endif
    endfunction
endif

" Add mappings, unless the user didn't want this.
" The default mapping is registered under to <F7> by default, unless the user
" remapped it already (or a mapping exists already for <F7>)
if !exists("no_plugin_maps") && !exists("no_jshint_maps")
    if !hasmapto('JSHint(')
        noremap <buffer> <F7> :call JSHint()<CR>
    endif
endif
