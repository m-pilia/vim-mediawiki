if exists('b:did_ftplugin')
    finish
endif
let b:did_ftplugin = 1
let s:keepcpo= &cpoptions

" Use the comment leader to continue lists and tables.
"
" Credits: Jean-Denis Vauguet (a.k.a. chikamichi)
" https://github.com/chikamichi/mediawiki.vim/blob/26e573726/README.md
setlocal comments=n:#,n:*,n:\:,s:{\|,m:\|,ex:\|}
setlocal formatoptions+=roq

" Fold sections
"
" Credits: Jean-Denis Vauguet (a.k.a. chikamichi)
" https://github.com/chikamichi/mediawiki.vim/blob/26e573726/README.md
setlocal foldexpr=getline(v:lnum)=~'^\\(=\\+\\)[^=]\\+\\1\\(\\s*<!--.*-->\\)\\=\\s*$'?\">\".(len(matchstr(getline(v:lnum),'^=\\+'))-1):\"=\"
setlocal foldmethod=expr

" To match delimiters with % when using the matchit plugin
if exists('loaded_matchit')
    let b:match_ignorecase = 1

    " Match bold/italic markers and heading section delimiters
    let b:match_words =
    \ get(b:, 'match_words', '') .
    \ (get(b:, 'match_words', '') =~# '\s*' ? '' : ',') .
    \ '\(^\|[^'']\@<=\)\(''\{2}\|''\{3}\|''\{5}\)\<:\>\(''\{2}\|''\{3}\|''\{5}\)\([^'']\@=\|$\),' .
    \ '\(^\|[^=]\@<=\)=\{2\}[^=]\@=:[^=]\@<==\{2\}\([^=]\@=\|$\),' .
    \ '\(^\|[^=]\@<=\)=\{3\}[^=]\@=:[^=]\@<==\{3\}\([^=]\@=\|$\),' .
    \ '\(^\|[^=]\@<=\)=\{4\}[^=]\@=:[^=]\@<==\{4\}\([^=]\@=\|$\),' .
    \ '\(^\|[^=]\@<=\)=\{5\}[^=]\@=:[^=]\@<==\{5\}\([^=]\@=\|$\),' .
    \ '\(^\|[^=]\@<=\)=\{6\}[^=]\@=:[^=]\@<==\{6\}\([^=]\@=\|$\)'

    " Credits: HTML tag matching patterns by Johannes Zellner and Benji Fisher
    " https://github.com/vim/vim/blob/946e27ab65/runtime/ftplugin/html.vim#L28-L35
    let b:match_words .=
    \ ',' .
    \ '<:>,' .
    \ '<\@<=[ou]l\>[^>]*\%(>\|$\):<\@<=li\>:<\@<=/[ou]l>,' .
    \ '<\@<=dl\>[^>]*\%(>\|$\):<\@<=d[td]\>:<\@<=/dl>,' .
    \ '<\@<=\([^/][^ \t>]*\)[^>]*\%(>\|$\):<\@<=/\1>'
endif

setlocal matchpairs+=<:>

" No line wrap.
" Most wikis use line breaks only at the end of paragraphs.
setlocal wrap linebreak
setlocal textwidth=0
setlocal formatoptions+=l
setlocal formatoptions-=t
setlocal formatoptions-=c
setlocal formatoptions-=a

" Optional mappings to simplify navigation over wrapped lines
if mediawiki#get_var(bufnr(''), 'mappings')
    noremap <buffer> <expr> j v:count == 0 ? 'gj' : 'j'
    noremap <buffer> <expr> k v:count == 0 ? 'gk' : 'k'
    noremap <buffer> 0 g0
    noremap <buffer> ^ g^
    noremap <buffer> $ g$
    nnoremap <buffer> D dg$
    nnoremap <buffer> C cg$
    nnoremap <buffer> A g$a
endif

" Settings for vim-surround: https://github.com/tpope/vim-surround
if exists('g:loaded_surround') && mediawiki#get_var(bufnr(''), 'surround')
    let b:surround_{char2nr(mediawiki#get_var(bufnr(''), 'surround_wikilink'))} = "[[\r|]]"
    let b:surround_{char2nr(mediawiki#get_var(bufnr(''), 'surround_template'))} = "{{\r}}"
    let b:surround_{char2nr(mediawiki#get_var(bufnr(''), 'surround_bold'))} = "'''\r'''"
    let b:surround_{char2nr(mediawiki#get_var(bufnr(''), 'surround_italic'))} = "''\r''"
    let b:surround_{char2nr(mediawiki#get_var(bufnr(''), 'surround_formatnum'))} = "{{FORMATNUM:\r}}"
endif

" Text objects for section headings
vnoremap <silent> <buffer> <plug>(mediawiki-text-object-inside-heading) :<C-U>silent! normal! T=vt=<CR>
vnoremap <silent> <buffer> <plug>(mediawiki-text-object-around-heading) :<C-U>call mediawiki#text_object('\v(\=+)@<=\=(\=)@!')<CR>
omap <silent> <buffer> <plug>(mediawiki-text-object-inside-heading) :normal v:<C-U>silent! normal! T=vt=<CR>
omap <silent> <buffer> <plug>(mediawiki-text-object-around-heading) :normal v:<C-U>call mediawiki#text_object('\v(\=+)@<=\=(\=)@!')<CR>

" Text objects for bold and italic
vnoremap <silent> <buffer> <plug>(mediawiki-text-object-inside-tick) :<C-U>silent! normal! T'vt'<CR>
vnoremap <silent> <buffer> <plug>(mediawiki-text-object-around-tick) :<C-U>call mediawiki#text_object("\\v(\\'+)@<=\\'(\\')@!")<CR>
omap <silent> <buffer> <plug>(mediawiki-text-object-inside-tick) :normal v:<C-U>silent! normal! T'vt'<CR>
omap <silent> <buffer> <plug>(mediawiki-text-object-around-tick) :normal v:<C-U>call mediawiki#text_object("\\v(\\'+)@<=\\'(\\')@!")<CR>

" Text objects for arguments between pipes
vnoremap <silent> <buffer> <plug>(mediawiki-text-object-inside-pipes) :<C-U>silent! normal! T<bar>vt<bar><CR>
vnoremap <silent> <buffer> <plug>(mediawiki-text-object-around-pipes) :<C-U>silent! normal! F<bar>vlf<bar><CR>
omap <silent> <buffer> <plug>(mediawiki-text-object-inside-pipes) :normal v:<C-U>silent! normal! T<bar>vt<bar><CR>
omap <silent> <buffer> <plug>(mediawiki-text-object-around-pipes) :normal v:<C-U>silent! normal! F<bar>vlf<bar><CR>

" Text objects for leftmost section of link (between the '[[' and the first '|')
vnoremap <silent> <buffer> <plug>(mediawiki-text-object-inside-link-page) :<C-U>silent! normal! T[vt<bar><CR>
vnoremap <silent> <buffer> <plug>(mediawiki-text-object-around-link-page) :<C-U>silent! normal! F[hvf<bar><CR>
omap <silent> <buffer> <plug>(mediawiki-text-object-inside-link-page) :normal v:<C-U>silent! normal! T[vt<bar><CR>
omap <silent> <buffer> <plug>(mediawiki-text-object-around-link-page) :normal v:<C-U>silent! normal! F[hvf<bar><CR>

" Text objects for rightmost section of link (between the last '|' and the ']]')
vnoremap <silent> <buffer> <plug>(mediawiki-text-object-inside-link-name) :<C-U>silent! normal! T<bar>vt]<CR>
vnoremap <silent> <buffer> <plug>(mediawiki-text-object-around-link-name) :<C-U>silent! normal! F<bar>vf]l<CR>
omap <silent> <buffer> <plug>(mediawiki-text-object-inside-link-name) :normal v:<C-U>silent! normal! T<bar>vt]<CR>
omap <silent> <buffer> <plug>(mediawiki-text-object-around-link-name) :normal v:<C-U>silent! normal! F<bar>vf]l<CR>

" Text objects for leftmost section of template (between the '{{' and the first '|')
vnoremap <silent> <buffer> <plug>(mediawiki-text-object-inside-template-begin) :<C-U>silent! normal! T{vt<bar><CR>
vnoremap <silent> <buffer> <plug>(mediawiki-text-object-around-template-begin) :<C-U>silent! normal! F{hvf<bar><CR>
omap <silent> <buffer> <plug>(mediawiki-text-object-inside-template-begin) :normal v:<C-U>silent! normal! T{vt<bar><CR>
omap <silent> <buffer> <plug>(mediawiki-text-object-around-template-begin) :normal v:<C-U>silent! normal! F{hvf<bar><CR>

" Text objects for rightmost section of template (between the last '|' and the '}}')
vnoremap <silent> <buffer> <plug>(mediawiki-text-object-inside-template-end) :<C-U>silent! normal! T<bar>vt}<CR>
vnoremap <silent> <buffer> <plug>(mediawiki-text-object-around-template-end) :<C-U>silent! normal! F<bar>vf}l<CR>
omap <silent> <buffer> <plug>(mediawiki-text-object-inside-template-end) :normal v:<C-U>silent! normal! T<bar>vt}<CR>
omap <silent> <buffer> <plug>(mediawiki-text-object-around-template-end) :normal v:<C-U>silent! normal! F<bar>vf}l<CR>

" Text objects for named argument (between '=' and '|')
vnoremap <silent> <buffer> <plug>(mediawiki-text-object-inside-named-argument) :<C-U>silent! normal! T=vt<bar><CR>
vnoremap <silent> <buffer> <plug>(mediawiki-text-object-around-named-argument) :<C-U>silent! normal! F=vt<bar><CR>
omap <silent> <buffer> <plug>(mediawiki-text-object-inside-named-argument) :normal v:<C-U>silent! normal! T=vt<bar><CR>
omap <silent> <buffer> <plug>(mediawiki-text-object-around-named-argument) :normal v:<C-U>silent! normal! F=vt<bar><CR>

" Detect fenced languages (updated on buffer writing)
call mediawiki#fenced_languages#perform_highlighting()
augroup vim_media_wiki
    autocmd! * <buffer>
    autocmd BufWritePost <buffer> call mediawiki#fenced_languages#perform_highlighting()
augroup END

let &cpoptions = s:keepcpo
unlet! s:keepcpo
