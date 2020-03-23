let s:script_folder = expand('<sfile>:p:h:h:h:h') . '/scripts'
let s:list_pages_script = s:script_folder . '/list_pages.py'
let s:get_templatedata_script = s:script_folder . '/get_templatedata.py'
let s:completion_cache = {}

" Run an external command and handle its output with the given callback
"
" Use an asynchronous job if possible.
function! s:job(command, stdout_cb) abort
    if has('nvim')
        call jobstart(a:command, {
        \   'on_stdout': a:stdout_cb,
        \   'stdout_buffered': 1,
        \ })
    elseif has('job')
        call job_start(a:command, {
        \   'out_cb': {_, msg -> a:stdout_cb(0, split(msg, '\n') + [''], 0)},
        \   'out_mode': 'raw',
        \ })
    else
        call a:stdout_cb(0, systemlist(a:command), 0)
    endif
endfunction

" Check if the cursor is inserting in a template
"
" Note: This is a best-effort heuristic. It checks the syntax
" region of the character before the cursor position (to avoid getting
" no syntax region when the cursor is inserting at the end of a line).
" When the cursor is inserting inside a template, the character before
" is expected to be part of the template syntax. This will fail for
" instance when inserting in an empty line, but this is not considered
" an important case for completion.
function! s:not_inside_template() abort
    return synIDattr(synID(line('.'), col('.') - 1, 0), 'name') !~# '^wikiTemplate'
endfunction

" Return the name of the template surrounding the cursor
"
" If the cursor is inside a wiki template, return its name, or v:null
" otherwise.
"
" Note: This is a best-effort implementation, that considers the closest
" pair of braces as template boundaries. It may fail, for instance, when
" invoked with the cursor located inside a pair of curly braces
" contained somewhere within a template. However, this implementation
" should be good enough for its use case (template parameter
" completion), since the cursor is expected to be within a parameter
" name and no braces should be normally present there.
function! s:get_template_name() abort
    if s:not_inside_template()
        return v:null
    endif

    try
        let l:saved_curpos = getpos('.')
        let l:saved_clipboard = &clipboard
        set clipboard=
        let l:saved_reg = getreg('"')
        let l:saved_regmode = getregtype('"')
        silent keepjumps normal! yi}
        let l:text = @@
    finally
        call setpos('.', l:saved_curpos)
        call setreg('"', l:saved_reg, l:saved_regmode)
        let &clipboard = l:saved_clipboard
    endtry

    let l:res = matchlist(l:text, '\v^([^|]+)\|')
    if len(l:res) < 2
        return v:null
    endif

    " 'Template:' works as namespace prefix regardless of the
    " localisation of the MediaWiki installation
    return substitute(trim(l:res[1]), '\v^([^:]+\:)?', 'Template:', '')
endfunction

" Get the completion prefix for a page at cursor position
"
" The namespace prefix is one of the keys in the namespaces dictionary,
" e.g. for wikilinks it is '[[', for templates '{{', for files '[[File:'
" and so on. The completion prefix is the prefix of the page to be
" completed, i.e. the characters inserted after the namespace prefix.
"
" When looking for the opening signs, avoid matching `{{{` (template
" arguments) and `{{#` (magic words).
function! s:get_page_prefix(options) abort
    let l:namespaces = keys(mediawiki#get_site_var(a:options.bufnr, 'completion_namespaces'))
    let l:min_prefix_length = mediawiki#get_var(a:options.bufnr, 'completion_prefix_length')
    for l:namespace in reverse(sort(l:namespaces))
        let l:pattern = '\c\V\^\.\*{\@<!' . l:namespace . '\[{#]\@!\(\[^\]\}]\*\)\$'
        let l:match = matchlist(a:options.line[0:a:options.colnr - 2], l:pattern)
        if len(l:match)
            if l:match[1] =~# '|' || len(l:match[1]) < l:min_prefix_length
                return []
            endif
            return [l:namespace, l:match[1]]
        endif
    endfor
    return []
endfunction

" Get the completion prefix for a template parameter
function! s:get_template_parameter_prefix(options) abort
    if s:not_inside_template()
        return v:null
    endif

    let l:match = matchlist(a:options.line[0:a:options.colnr - 2], '\v\|([^=|]*)$')
    return len(l:match) > 1 ? trim(l:match[1]) : v:null
endfunction

" Get a localised string
"
" Given a dictionary of localised messages, return:
" - the message in the current locale (if available);
" - if not, the message in English (if available);
" - if not, the message in the first language available.
"
" If the input is not a dictionary, return its conversion to string.
function! s:get_local_message(messages) abort
    if type(a:messages) == type(v:null)
        return ''
    elseif type(a:messages) != v:t_dict
        return string(a:messages)
    endif

    let l:lang = v:lang[0:1]
    if has_key(a:messages, l:lang)
        return a:messages[l:lang]
    elseif has_key(a:messages, 'en')
        return a:messages['en']
    else
        return a:messages[keys(a:messages)[0]]
    endif
endfunction

" Handle results from the API query
function! s:handle_pages(prefix, callback, channel, data, stream) abort
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

" Format menu entry from template data
function! s:get_menu(name, data) abort
    let l:result = ''

    if has_key(a:data, 'label') && type(a:data.label) != type(v:null)
        let l:result .= trim(s:get_local_message(a:data.label))
    else
        let l:result .= a:name
    endif

    if has_key(a:data, 'deprecated') && a:data.deprecated
        let l:result .= ' (deprecated)'
    endif

    return l:result
endfunction

" Format info entry from template data
function! s:get_info(data) abort
    let l:result = []

    let l:description = ''
    if has_key(a:data, 'description')
        let l:description = trim(s:get_local_message(a:data.description))
    endif
    if l:description !=? ''
        let l:result += [l:description, '']
    endif

    if has_key(a:data, 'default') && type(a:data.default) != type(v:null)
        let l:result += ['Default: ' . s:get_local_message(a:data.default)]
    endif

    if has_key(a:data, 'example') && type(a:data.example) != type(v:null)
        let l:result += ['Example: ' . s:get_local_message(a:data.example)]
    endif

    if has_key(a:data, 'aliases') && len(a:data.aliases) > 0
        let l:result += ['Aliases: ' . join(a:data.aliases, ', ')]
    endif

    return join(l:result, "\n")
endfunction

" Handle results from the API query
function! s:handle_template_parameters(bufnr, template_name, callback, channel, data, stream) abort
    let l:templatedata = {}
    try
        let l:templatedata = json_decode(join(a:data, "\n"))
    catch
        call a:callback(v:false)
        return
    endtry

    if type(l:templatedata) != v:t_dict || l:templatedata == {}
        call a:callback(v:false)
        return
    endif

    call map(l:templatedata, {name, data -> {
    \   'word': name,
    \   'menu': s:get_menu(name, data),
    \   'info': s:get_info(data),
    \ }})
    let l:completions = values(l:templatedata)

    if !has_key(s:completion_cache, a:bufnr)
        let s:completion_cache[a:bufnr] = {}
    endif
    let s:completion_cache[a:bufnr][a:template_name] = l:completions

    call a:callback(l:completions)
endfunction

" Provide completions for template parameter names
function! s:template_completion(bufnr, site, callback) abort
    let l:template_name = s:get_template_name()

    if has_key(s:completion_cache, a:bufnr) &&
    \  has_key(s:completion_cache[a:bufnr], l:template_name)
        call a:callback(s:completion_cache[a:bufnr][l:template_name])
        return
    endif

    let l:command = [
    \   'python', s:get_templatedata_script,
    \   '--site', a:site,
    \   '--template', l:template_name,
    \ ]

    call s:job(l:command, function('s:handle_template_parameters', [a:bufnr, l:template_name, a:callback]))
endfunction

" Provide completions for page names
function! s:page_completion(site, options, callback) abort
    let l:prefix = s:get_page_prefix(a:options)
    let l:namespace = mediawiki#get_site_var(a:options.bufnr, 'completion_namespaces')[l:prefix[0]]

    let l:command = [
    \   'python', s:list_pages_script,
    \   '--site', a:site,
    \   '--prefix', l:prefix[1],
    \   '--namespace', string(l:namespace),
    \   '--limit', string(mediawiki#get_var(a:options.bufnr, 'completion_limit')),
    \ ]

    call s:job(l:command, function('s:handle_pages', [l:prefix, a:callback]))
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
    let l:is_page = s:get_page_prefix(a:options) != []
    let l:is_template_parameter = s:get_template_parameter_prefix(a:options) != v:null
    return l:is_page || l:is_template_parameter
endfunction

" Provide completions by querying the API
function! coc#source#mediawiki#complete(options, callback) abort
    let l:site = mediawiki#get_var(a:options.bufnr, 'site')

    if l:site =~# '^\s*$'
        call a:callback(v:false)
    endif

    if s:get_template_parameter_prefix(a:options) != v:null
        call s:template_completion(a:options.bufnr, l:site, a:callback)
    else
        call s:page_completion(l:site, a:options, a:callback)
    endif
endfunction
