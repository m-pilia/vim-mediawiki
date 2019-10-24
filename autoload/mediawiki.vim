" Get a variable (preferably buffer-local)
function! mediawiki#get_var(bufnr, name) abort
    let l:var_name = 'vim_mediawiki_' . a:name
    let l:variables = getbufvar(str2nr(a:bufnr), '', {})
    return get(l:variables, l:var_name, g:[l:var_name])
endfunction

