if exists('g:vim_mediawiki_plugin_loaded')
    finish
endif
let g:vim_mediawiki_plugin_loaded = 1

if !exists('g:vim_mediawiki_site')
    let g:vim_mediawiki_site = 'en.wikipedia.org'
endif

if !exists('g:vim_mediawiki_completion_namespaces')
    let g:vim_mediawiki_completion_namespaces = {
    \ 'default': {
    \       '[[': 0,
    \       '{{': 10,
    \       '[[File:': 6,
    \       '[[Category:': 14,
    \   },
    \ }
endif

if !exists('g:vim_mediawiki_completion_prefix_length')
    let g:vim_mediawiki_completion_prefix_length = 5
endif

if !exists('g:vim_mediawiki_completion_limit')
    let g:vim_mediawiki_completion_limit = 15
endif
