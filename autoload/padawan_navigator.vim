if (get(g:, 'padawan_navigator#loaded', 0))
    finish
endif

let g:padawan_navigator#loaded = 1

let lib_path = expand('<sfile>:p:h:h') . '/rplugin/python3/padawan/'

let g:padawan_navigator#server_addr =
            \ get(g:, 'padawan_navigator#server_addr', 'http://127.0.0.1:15155')
let g:padawan_navigator#server_command =
            \ get(g:, 'padawan_navigator#server_command', 'padawan-server')
let g:padawan_navigator#log_file =
            \ get(g:, 'padawan_navigator#log_file', '/tmp/padawan-server.log')

let g:padawan_navigator#server_autostart =
            \ get(g:, 'padawan_navigator#server_autostart', 1)

let PHPNavigatorBuffer = "__PHPNavigator__"
function! padawan_navigator#PopulateList(candidates)
    let s:nav_bufnum = bufnr(g:PHPNavigatorBuffer)
    let s:previous_winnr = winnr()
    let l:baseFile = expand('%:t:r').'.'.expand('%:e')
    let g:padawan_navigator_candidateFiles = []
    let l:candidateFqcns = []

    for candidate in a:candidates
        call add(l:candidateFqcns, substitute(candidate['fqcn'], '\\\\', '\\', 'g'))
        call add(g:padawan_navigator_candidateFiles, substitute(candidate['file'], '^/', '', ''))
    endfor

    if len(a:candidates) == 1
        try
            call padawan_navigator#CloseWindow()
        catch
        endtry
        execute ":e ".g:padawan_navigator_candidateFiles[0]
        return
    endif

    let s:nav_bufnum = bufnr(g:PHPNavigatorBuffer)
    if s:nav_bufnum > -1
        execute s:nav_bufnum.'bw'
    endif

    execute 'bo '.len(a:candidates).'new '.g:PHPNavigatorBuffer

    call append(0, l:candidateFqcns)
    normal! ddgg0

    " Avoid the user modify the buffer contents.
    setlocal cursorline
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal buflisted

    " Syntax highlighting
    " I'm not sure if this is a good place to write syntax highlight :/
    syn keyword elementType Class Trait Inter
    hi def link elementType Keyword

    " This buffer command will be called when user select an option.
    command! -buffer PadawanSelectOption call s:SelectOption(line('.') - 1)

    " Map common keys to select or close the options window.
    nnoremap <buffer> <esc> :q!<cr>:echo "Canceled"<cr>
    nnoremap <buffer> <cr> :PadawanSelectOption<cr>

endfunction

function! s:SelectOption(index)
    execute ":".s:previous_winnr."wincmd w"
    let l:selected = g:padawan_navigator_candidateFiles[a:index]
    execute ":e ".l:selected
endfunction

function! padawan_navigator#CloseWindow()
    let s:nav_bufnum = bufnr(g:PHPNavigatorBuffer)
    if s:nav_bufnum > -1
        execute ":bd! ".s:nav_bufnum
    endif
endfunction
