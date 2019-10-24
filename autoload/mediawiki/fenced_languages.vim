" This file is adapted from mediawiki.vim
" Credits: Olivier Teulière (a.k.a. ipkiss42)
"   https://github.com/chikamichi/mediawiki.vim/blob/26e573726/autoload/mediawiki.vim

scriptencoding utf-8

" Known mappings
let s:mediawiki_wikilang_to_vim = {
\   'abap': 'abap',
\   'ada': 'ada',
\   'apache': 'apache',
\   'apt_sources': 'debsources',
\   'asm': 'asm',
\   'autohotkey': 'autohotkey',
\   'autoit': 'autoit',
\   'awk': 'awk',
\   'bash': 'sh',
\   'bibtex': 'bib',
\   'c': 'c',
\   'chaiscript': 'chaiscript',
\   'clojure': 'clojure',
\   'cmake': 'cmake',
\   'cobol': 'cobol',
\   'cpp': 'cpp',
\   'csharp': 'cs',
\   'css': 'css',
\   'd': 'd',
\   'dcl': 'dcl',
\   'diff': 'diff',
\   'dot': 'dot',
\   'eiffel': 'eiffel',
\   'email': 'mail',
\   'erlang': 'erlang',
\   'falcon': 'falcon',
\   'freebasic': 'freebasic',
\   'gdb': 'gdb',
\   'gnuplot': 'gnuplot',
\   'groovy': 'groovy',
\   'haskell': 'haskell',
\   'html4strict': 'html',
\   'html5': 'html',
\   'icon': 'icon',
\   'idl': 'idl',
\   'ini': 'dosini',
\   'j': 'j',
\   'java': 'java',
\   'java5': 'java',
\   'javascript': 'javascript',
\   'kixtart': 'kix',
\   'latex': 'tex',
\   'lisp': 'lisp',
\   'logtalk': 'logtalk',
\   'lscript': 'lscript',
\   'lua': 'lua',
\   'make': 'make',
\   'matlab': 'matlab',
\   'mmix': 'mmix',
\   'modula2': 'modula2',
\   'modula3': 'modula3',
\   'mysql': 'mysql',
\   'nsis': 'nsis',
\   'objc': 'objc',
\   'ocaml': 'ocaml',
\   'oracle11': 'sql',
\   'oracle8': 'sql',
\   'pascal': 'pascal',
\   'perl': 'perl',
\   'perl6': 'perl6',
\   'pf': 'pf',
\   'php': 'php',
\   'pic16': 'pic',
\   'pike': 'pike',
\   'pli': 'pli',
\   'plsql': 'plsql',
\   'povray': 'pov',
\   'progress': 'progress',
\   'prolog': 'prolog',
\   'python': 'python',
\   'rebol': 'rebol',
\   'rexx': 'rexx',
\   'robots': 'robots',
\   'ruby': 'ruby',
\   'sas': 'sas',
\   'scheme': 'scheme',
\   'scilab': 'scilab',
\   'smalltalk': 'st',
\   'sql': 'sql',
\   'tcl': 'tcl',
\   'vb': 'vb',
\   'verilog': 'verilog',
\   'vhdl': 'vhdl',
\   'vim': 'vim',
\   'whitespace': 'whitespace',
\   'winbatch': 'winbatch',
\   'yaml': 'yaml'
\ }

function! s:find_languages_in_buffer() abort
    let l:save_cursor = getpos('.')
    let l:languages_dict = {}
    call cursor('$', 1)
    let l:flags = 'w'
    while search('<\(source\|syntaxhighlight\)\s\+lang="', l:flags) > 0
        " Assumes there is only one match per line
        let l:lang = substitute(getline('.'), '.*<\(source\|syntaxhighlight\)\s\+lang="\(\w\+\)".*', '\2', '')
        let l:languages_dict[l:lang] = 1
        " Do not wrap search anymore
        let l:flags = 'W'
    endwhile
    call setpos('.', l:save_cursor)
    return keys(l:languages_dict)
endfunction

" Include the syntax file for the given filetype
function! s:include_syntax(filetype, group_name) abort
    " Most syntax files do nothing if b:current_syntax is defined.
    " Make sure to unset it.
    if exists('b:current_syntax')
        let b:saved_current_syntax = b:current_syntax
        unlet b:current_syntax
    endif

    exe 'syntax include @' . a:group_name . ' syntax/' . a:filetype . '.vim'

    " Restore b:current_syntax
    if exists('b:saved_current_syntax')
        let b:current_syntax = b:saved_current_syntax
        unlet b:saved_current_syntax
    elseif exists('b:current_syntax')
        unlet b:current_syntax
    endif
endfunction

" Define the highlighted region. Must be called after IncludeSyntax()
function! s:define_region(filetype, group_name, wiki_lang) abort
    " <source> tag
    exe 'syntax region wiki_' . a:filetype . '_region ' .
    \   "start='<source lang=\"" . a:wiki_lang . "\">' " .
    \   "end='</source>' ".
    \   'keepend contains=wikiSourceTag,wikiSourceEndTag,@' . a:group_name

    " <syntaxhighlight> tag
    exe 'syntax region wiki_' . a:filetype . '_region ' .
    \   "start='<syntaxhighlight lang=\"" . a:wiki_lang . "\">' " .
    \   "end='</syntaxhighlight>' ".
    \   'keepend contains=wikiSyntaxHLTag,wikiSyntaxHLEndTag,@' . a:group_name
endfunction

" Perform highlighting for a given wiki language
function! s:highlight_wiki_lang(wiki_lang, filetype, already_included_ft) abort
    let l:group_name = a:filetype . '_group'

    " Include syntax file, if not yet included
    if !has_key(a:already_included_ft, a:filetype)
        call s:include_syntax(a:filetype, l:group_name)
        let a:already_included_ft[a:filetype] = 1
    endif

    call s:define_region(a:filetype, l:group_name, a:wiki_lang)
endfunction

" Perform highlighting
function! mediawiki#fenced_languages#perform_highlighting() abort
    let l:wikilang_map = mediawiki#get_var(bufnr(''), 'wikilang_map')
    let l:ignored_wikilangs = mediawiki#get_var(bufnr(''), 'ignored_wikilangs')
    let l:preloaded_wikilangs = mediawiki#get_var(bufnr(''), 'preloaded_wikilangs')

    " Apply user overrides
    call extend(s:mediawiki_wikilang_to_vim, l:wikilang_map)

    " Convert list into a dict
    let l:ignoredDict = {}
    for l:wiki_lang in l:ignored_wikilangs
        let l:ignoredDict[l:wiki_lang] = 1
    endfor

    let l:already_included_ft = {}
    " Load languages
    for l:wiki_lang in s:find_languages_in_buffer() + l:preloaded_wikilangs
        if has_key(l:ignoredDict, l:wiki_lang)
            continue
        endif

        " Get corresponding filetype
        if !has_key(s:mediawiki_wikilang_to_vim, l:wiki_lang)
            let l:msg = 'Warning: no filetype mapped to wiki language "' . l:wiki_lang . '"'
            echohl WarningMsg | echom l:msg | echohl None
            continue
        endif
        let l:ft = s:mediawiki_wikilang_to_vim[l:wiki_lang]

        call s:highlight_wiki_lang(l:wiki_lang, l:ft, l:already_included_ft)
    endfor
endfunction

