if exists('g:vim_mediawiki_plugin_loaded')
    finish
endif
let g:vim_mediawiki_plugin_loaded = 1

if !exists('g:vim_mediawiki_site')
    let g:vim_mediawiki_site = ''
endif

let s:default_namespaces = {
    \ 'default': {
    \       '[[': 0,
    \   },
    \ }
if !exists('g:vim_mediawiki_completion_namespaces')
    let g:vim_mediawiki_completion_namespaces = s:default_namespaces
else
    let g:vim_mediawiki_completion_namespaces = extend(
    \   copy(s:default_namespaces),
    \   g:vim_mediawiki_completion_namespaces)
endif

if !exists('g:vim_mediawiki_completion_prefix_length')
    let g:vim_mediawiki_completion_prefix_length = 5
endif

if !exists('g:vim_mediawiki_completion_limit')
    let g:vim_mediawiki_completion_limit = 50
endif

if !exists('g:vim_mediawiki_mappings')
    let g:vim_mediawiki_mappings = 0
endif

if !exists('g:vim_mediawiki_ignored_wikilangs')
    let g:vim_mediawiki_ignored_wikilangs = []
endif

if !exists('g:vim_mediawiki_preloaded_wikilangs')
    let g:vim_mediawiki_preloaded_wikilangs = []
endif

if !exists('g:vim_mediawiki_wikilang_map')
    let g:vim_mediawiki_wikilang_map = {}
endif

if !exists('g:vim_mediawiki_surround')
    let g:vim_mediawiki_surround = 1
endif

if !exists('g:vim_mediawiki_surround_wikilink')
    let g:vim_mediawiki_surround_wikilink = 'l'
endif

if !exists('g:vim_mediawiki_surround_template')
    let g:vim_mediawiki_surround_template = 't'
endif

if !exists('g:vim_mediawiki_surround_bold')
    let g:vim_mediawiki_surround_bold = 'b'
endif

if !exists('g:vim_mediawiki_surround_italic')
    let g:vim_mediawiki_surround_italic = 'i'
endif

augroup vim_media_wiki
    autocmd!
    autocmd Syntax mediawiki call mediawiki#fenced_languages#perform_highlighting()
    autocmd BufWritePost * call mediawiki#fenced_languages#perform_highlighting()
augroup END
