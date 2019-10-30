let s:preview_script = expand('<sfile>:p:h:h') . '/scripts/preview.py'

" Print a warning message
function! mediawiki#warning(message) abort
    redraw
    echohl WarningMsg
    echom 'vim-mediawiki: ' . a:message
    echohl None
endfunction

" Get a variable (preferably buffer-local)
function! mediawiki#get_var(bufnr, name) abort
    let l:var_name = 'vim_mediawiki_' . a:name
    let l:variables = getbufvar(str2nr(a:bufnr), '', {})
    return get(l:variables, l:var_name, g:[l:var_name])
endfunction

" Get a site-specific setting (merge global and buffer-local dicts)
function! mediawiki#get_site_var(bufnr, name) abort
    let l:var = mediawiki#get_var(a:bufnr, a:name)
    if exists('b:vim_mediawiki_' . a:name) &&
    \  exists('g:vim_mediawiki_' . a:name)
        let l:var = extend(copy(l:var), g:vim_mediawiki_{a:name}, 'keep')
    endif
    let l:site = mediawiki#get_var(a:bufnr, 'site')
    return index(keys(l:var), l:site) >= 0 ? l:var[l:site] : l:var['default']
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

" Generate a preview of the page in the current buffer
function! mediawiki#preview() abort
    if &filetype !=# 'mediawiki'
        call mediawiki#warning('not a mediawiki buffer')
        return
    endif

    let l:site = mediawiki#get_var(bufnr(''), 'site')

    if l:site =~# '^\s*$'
        call mediawiki#warning('g:vim_mediawiki_site is not set')
        return
    endif

    let l:wikitext_file = tempname()
    let l:output_file = tempname() . '.html'

    let l:preview_cmd = [
    \   'python', s:preview_script,
    \   '--site', l:site,
    \   '--wikitext-file', l:wikitext_file,
    \   '--skin', mediawiki#get_site_var(bufnr(''), 'skins'),
    \   '--output-file', l:output_file,
    \ ]

    let l:browser_cmd = mediawiki#get_var(bufnr(''), 'browser_command')
    let l:browser_cmd = substitute(l:browser_cmd, "\r", l:output_file, '')

    exec 'silent write! ' . l:wikitext_file

    if has('nvim')
        call jobstart(l:preview_cmd, {'on_exit': {... -> jobstart(l:browser_cmd)}})
    elseif has('job')
        call job_start(l:preview_cmd, {'exit_cb': {... -> job_start(l:browser_cmd)}})
    else
        call system(l:preview_cmd)
        call system(l:browser_cmd)
    endif
endfunction

