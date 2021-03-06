if !exists("g:hindent_on_save")
    let g:hindent_on_save = 1
endif


command! Hindent exe "call hindent#Hindent()"


function! hindent#Hindent()
    let l:winview = winsaveview()

    if !executable("hindent")
        echomsg "Hindent not found in $PATH, did you installed it?
                    \ (stack install hindent)"
        return
    endif

    " Write the buffer to hindent, rather than having it use the
    " file on disk, because that file might not have been created yet!
    silent! w !hindent > /dev/null 2>&1

    if v:shell_error
        echohl WarningMsg
        echo "Hindent: Parsing error\n"
        echohl None
    else
        let l:indent_opt = ""
        if exists("g:hindent_indent_size")
          let l:indent_opt = " --indent-size " . g:hindent_indent_size
        endif

        let l:line_length_opt = ""
        if exists("g:hindent_line_length")
          let l:line_length_opt = " --line-length " . g:hindent_line_length
        endif

        silent! exe "undojoin"
        silent! exe "keepjumps %!hindent" . l:indent_opt . l:line_length_opt
    endif

    call winrestview(l:winview)
endfunction


if g:hindent_on_save == 1
    augroup hindent
        autocmd!
        autocmd BufWritePre *.hs call hindent#Hindent()
    augroup END
endif


" For use with the gq operator (:help gq)
setlocal formatprg=hindent
