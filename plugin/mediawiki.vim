if exists('g:vim_mediawiki_plugin_loaded')
    finish
endif
let g:vim_mediawiki_plugin_loaded = 1

if !exists('g:vim_mediawiki_site')
    let g:vim_mediawiki_site = 'en.wikipedia.org'
endif

let s:default_namespaces = {
    \ 'default': {
    \       '[[': 0,
    \       '{{': 10,
    \       '[[File:': 6,
    \       '[[Category:': 14,
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
    let g:vim_mediawiki_completion_limit = 15
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

augroup vim_media_wiki
    autocmd!
    autocmd Syntax mediawiki call mediawiki#fenced_languages#perform_highlighting()
    autocmd BufWritePost * call mediawiki#fenced_languages#perform_highlighting()
augroup END
