let s:script = expand('<sfile>:p:h:h:h:h') . '/scripts/list_pages.py'

" Get the dictionary of completion namespaces for a buffer
function! s:get_namespaces(bufnr) abort
    let l:ns = mediawiki#get_var(a:bufnr, 'completion_namespaces')
    if exists('b:vim_mediawiki_completion_namespaces') &&
    \  exists('g:vim_mediawiki_completion_namespaces')
        let l:ns = extend(copy(l:ns), g:vim_mediawiki_completion_namespaces, 'keep')
    endif
    let l:site = mediawiki#get_var(a:bufnr, 'site')
    return index(keys(l:ns), l:site) >= 0 ? l:ns[l:site] : l:ns['default']
endfunction

" Get the completion prefix at cursor position
"
" The namespace prefix is one of the keys in the namespaces dictionary,
" e.g. for wikilinks it is '[[', for templates '{{', for files '[[File:'
" and so on. The completion prefix is the prefix of the page to be
" completed, i.e. the characters inserted after the namespace prefix.
"
" When looking for the opening signs, avoid matching `{{{` (template
" arguments) and `{{#` (magic words).
function! s:get_prefix(options) abort
    let l:namespaces = keys(s:get_namespaces(a:options.bufnr))
    let l:min_prefix_length = mediawiki#get_var(a:options.bufnr, 'completion_prefix_length')
    for l:namespace in reverse(sort(l:namespaces))
        let l:pattern = '\c\V\^\.\*{\@<!' . l:namespace . '\[{#]\@!\(\[^\]\}]\*\)\$'
        let l:match = matchlist(a:options.line[0:a:options.colnr - 2], l:pattern)
        if len(l:match)
            if len(l:match[1]) < l:min_prefix_length
                return []
            endif
            return [l:namespace, l:match[1]]
        endif
    endfor
    return []
endfunction

" Handle results from the API query
function! s:handler(prefix, callback, channel, data, stream) abort
    call filter(a:data, {i, v -> v !~# '\v^\s*$'})
    if len(a:data) < 1
        call a:callback(v:false)
        return
    endif

    " Remove namespace and previous words (for multi-word completion)
    " from the completion text. Leave full page name as 'menu'
    " information in the item.
    let l:namespace_prefix = a:prefix[0] ==# '{{' ? '\[^:]\+:' : a:prefix[0][2:]
    if l:namespace_prefix[0] ==# ':'
        let l:namespace_prefix = l:namespace_prefix[1:]
    endif
    let l:previous_words = join(split(escape(a:prefix[1], '/\'), ' ')[0:-2], ' ')
    let l:pattern = '\c\V\^' . l:namespace_prefix . l:previous_words . '\s\*'
    call map(a:data, {i, v -> {'menu': v, 'word': substitute(v, l:pattern, '', '')}})

    call a:callback(a:data)
endfunction

" Initialise completion source
function! coc#source#mediawiki#init() abort
    return {
    \ 'priority': 90,
    \ 'shortcut': 'MW',
    \ 'filetypes': ['mediawiki'],
    \ }
endfunction

" Check if the word should be completed, i.e. if the cursor is inside
" double square brackets or double braces.
function! coc#source#mediawiki#should_complete(options) abort
    return s:get_prefix(a:options) != []
endfunction

" Provide completions by querying the API
function! coc#source#mediawiki#complete(options, callback) abort
    let l:site = mediawiki#get_var(a:options.bufnr, 'site')

    if l:site =~# '^\s*$'
        call a:callback(v:false)
    endif

    let l:prefix = s:get_prefix(a:options)
    let l:namespace = s:get_namespaces(a:options.bufnr)[l:prefix[0]]

    let l:command = [
    \   'python', s:script,
    \   '--site', l:site,
    \   '--prefix', l:prefix[1],
    \   '--namespace', string(l:namespace),
    \   '--limit', string(mediawiki#get_var(a:options.bufnr, 'completion_limit')),
    \ ]

    if has('nvim')
        call jobstart(l:command, {
        \   'on_stdout': function('s:handler', [l:prefix, a:callback]),
        \   'stdout_buffered': 1,
        \ })
    elseif has('job')
        call job_start(l:command, {
        \   'out_cb': {_, msg -> s:handler(l:prefix, a:callback, 0, split(msg, '\n'), 0)},
        \   'out_mode': 'raw',
        \ })
    else
        call s:handler(l:prefix, a:callback, 0, systemlist(l:command), 0)
    endif
endfunction
