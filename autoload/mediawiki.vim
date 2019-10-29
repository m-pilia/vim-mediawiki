" Get a variable (preferably buffer-local)
function! mediawiki#get_var(bufnr, name) abort
    let l:var_name = 'vim_mediawiki_' . a:name
    let l:variables = getbufvar(str2nr(a:bufnr), '', {})
    return get(l:variables, l:var_name, g:[l:var_name])
endfunction

" Visually select a text object in the current line, delimited by a pattern
function! mediawiki#text_object(pattern) abort
    let l:line = getline('.')
    let l:col = col('.')
    let l:left = join(reverse(split(l:line[0 : l:col - 1], '.\zs')), '')
    let l:right = l:line[l:col - 1:]
    let l:left = l:col - match(l:left, a:pattern)
    let l:right = l:col + match(l:right, a:pattern)
    execute 'normal! ' . l:left . '|v' l:right . '|'
endfunction

