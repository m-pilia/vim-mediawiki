vim-mediawiki: vim plugin to edit MediaWiki pages
===============================================================
[![Travis CI Build Status](https://travis-ci.org/m-pilia/vim-mediawiki.svg?branch=master)](https://travis-ci.org/m-pilia/vim-mediawiki)
[![codecov](https://codecov.io/gh/m-pilia/vim-mediawiki/branch/master/graph/badge.svg)](https://codecov.io/gh/m-pilia/vim-mediawiki/branch/master)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/m-pilia/vim-mediawiki/blob/master/LICENSE)

This is a plugin to help editing pages of a MediaWiki site from vim/neovim. It
provides:
* filetype detection
* improved syntax highlighting
* page preview
* auto-completion of links and templates with a
  [coc.nvim](https://github.com/neoclide/coc.nvim) source
* `<plug>` mappings for text objects
* matching pairs for [matchit.vim](https://github.com/vim/vim/blob/master/runtime/pack/dist/opt/matchit/doc/matchit.txt)
* integration with [vim-surround](https://github.com/tpope/vim-surround)

Installation
============

The plugin can be installed with any package manager. Prerequisites are vim
8.1+ or neovim 0.4+, a working Python3 installation, and the `wmclient` Python
package (`pip install wmclient`).

Auto-completion
===============

If [coc.nvim](https://github.com/neoclide/coc.nvim) is installed and configured
properly, the completion source should work out-of-the-box for buffers of type
`mediawiki`. Completion is triggered when typing inside double square brackets
or double braces, and the minimum number of characters to type before
completion can be configured. Multi-word completion is supported, so
completions will be suggested when typing more than one word inside the
brackets, together with a hint of the full page name.

![image](https://user-images.githubusercontent.com/8300317/68047476-2894dc00-fce7-11e9-9f7f-9be1c0485616.png)

You can refer to the relevant [upstream
documentation](https://github.com/neoclide/coc.nvim/wiki/Completion-with-sources)
to configure the source in coc.nvim. Settings can be defined in the
[coc-settings.json](https://github.com/neoclide/coc.nvim/wiki/Using-the-configuration-file):
```json
{
    "coc": {
        "source": {
            "mediawiki": {
                "enable": true,
                "priority": 99
            }
        }
    }
}
```
To further configure completion, see the [following
section](#Completion).

If you do not use coc.nvim, you may be able to use the function
`coc#source#mediawiki#complete()` to implement an
[omnifunc](https://vimhelp.org/options.txt.html#%27omnifunc%27), or to write an
adapter to plug it in other completion mechanisms. Please refer to the
[upstream documentation of the
API](https://github.com/neoclide/coc.nvim/wiki/Create-custom-source) used by
this source.

Text objects
============

The plugin provides a set of text objects:
* `<plug>(mediawiki-text-object-inside-tick)` and
  `<plug>(mediawiki-text-object-around-tick)` to operate inside or around
  italic and bold markers
* `<plug>(mediawiki-text-object-inside-heading)` and
  `<plug>(mediawiki-text-object-around-heading)` to operate inside or around
  headings
* `<plug>(mediawiki-text-object-inside-pipes)` and
  `<plug>(mediawiki-text-object-around-pipes)` to operate inside or around
  pipes (e.g. positional template arguments)
* `<plug>(mediawiki-text-object-inside-link-page)` and
  `<plug>(mediawiki-text-object-around-link-page)` to operate inside or around
  the leftmost part of a link (between `[[` and `|`), containing the page of a
  link
* `<plug>(mediawiki-text-object-inside-link-name)` and
  `<plug>(mediawiki-text-object-around-link-name)` to operate inside or around
  the rightmost part of a link (between `|` and `]]`), containing the name of a
  link
* `<plug>(mediawiki-text-object-inside-template-begin)` and
  `<plug>(mediawiki-text-object-around-template-begin)` to operate inside or around
  the leftmost part of a template (between `{{` and `|`)
* `<plug>(mediawiki-text-object-inside-template-end)` and
  `<plug>(mediawiki-text-object-around-template-end)` to operate inside or around
  the rightmost part of a template (between `|` and `}}`)
* `<plug>(mediawiki-text-object-inside-named-argument)` and
  `<plug>(mediawiki-text-object-around-named-argument)` to operate inside or around
  a named argument (between `=` and `|`, where `|` is always excluded from the
  text object)

The `<plug>` mappings can be associated to key mappings, for instance:
```viml
vmap <silent> <buffer> i' <plug>(mediawiki-text-object-inside-tick)
vmap <silent> <buffer> a' <plug>(mediawiki-text-object-around-tick)
omap <silent> <buffer> i' <plug>(mediawiki-text-object-inside-tick)
omap <silent> <buffer> a' <plug>(mediawiki-text-object-around-tick)
```

Surround
========

If [vim-surround](https://github.com/tpope/vim-surround) is installed, mappings
are created to surround text with wiki-link or template double-brackets, or
with bold or italic ticks. The characters bound to the surround map can be
configured with the variables
```viml
let g:vim_mediawiki_surround_wikilink = 'l'
let g:vim_mediawiki_surround_template = 't'
let g:vim_mediawiki_surround_bold = 'b'
let g:vim_mediawiki_surround_italic = 'i'
```
and can be disabled by setting
```viml
let g:vim_mediawiki_surround = 0
```

Configuration
=============

A set of variables allows to customise the behaviour of the plugin. All
variables can either be set globally as `g:vim_mediawiki_...` or locally for
each buffer with `b:vim_mediawiki_...`.

## Site

The value of `g:vim_mediawiki_site` sets the address of the wiki to edit.
The default is an empty string, and you need to set this in order to use
features such as auto-completion. Example:
```viml
let g:vim_mediawiki_site = 'en.wikipedia.org'
```

## Completion

It is possible to customise which
[namespaces](https://www.mediawiki.org/wiki/Help:Namespaces) to auto-complete.
The configuration is stored on a per-site basis in a dictionary called
`g:vim_mediawiki_completion_namespaces`, whose keys are possible values of
`g:vim_mediawiki_site`. Each site is mapped to a dictionary, that associates
each trigger sequence to the number of the corresponding namespace on that
site. Example:
```viml
let g:vim_mediawiki_completion_namespaces = {
\   'en.wikipedia.org': {
\       '[[': 0,
\       '{{': 10,
\   },
\   'sv.wikipedia.org': {
\       '[[': 0,
\       '[[File:': 6,
\       '[[Kategori:': 14,
\   },
\ }
```
Only the namespaces listed in this map will be completed. A `default` entry is
used for sites not present among the keys. The pre-defined configuration is
```viml
let g:vim_mediawiki_completion_namespaces = {
\   'default': {
\       '[[': 0,
\   },
\ }
```
and the custom configuration is merged with it, so the `default` key is
present unless it is overridden. Moreover, the buffer-local configuration is
merged with the global configuration, so it is not necessary to duplicate the
whole configuration in buffer-local variables, but it is sufficient to add or
overwrite only the desired sites. To disable completion for a site, map it to
an empty dictionary.

A complete configuration to edit the English language Wikipedia
[would be](https://en.wikipedia.org/wiki/Wikipedia:Namespace):
```viml
let g:vim_mediawiki_completion_namespaces = {
\   'en.wikipedia.org': {
\       '[[': 0,
\       '[[Talk:': 1,
\       '[[User:': 2,
\       '[[User talk:': 3,
\       '[[Wikipedia:': 4,
\       '[[Wikipedia talk:': 5,
\       '[[File:': 6,
\       '[[:File:': 6,
\       '[[File talk:': 7,
\       '[[MediaWiki:': 8,
\       '[[MediaWiki talk:': 9,
\       '[[Template:': 10,
\       '{{': 10,
\       '[[Template talk:': 11,
\       '[[Help:': 12,
\       '[[Help talk:': 13,
\       '[[Category:': 14,
\       '[[:Category:': 14,
\       '[[Category talk:': 15,
\       '[[Portal:': 100,
\       '[[Portal talk:': 101,
\       '[[Book:': 108,
\       '[[Book talk:': 109,
\       '[[Draft:': 118,
\       '[[Draft talk:': 119,
\       '[[TimedText:': 710,
\       '[[TimedText talk:': 711,
\       '[[Module:': 828,
\       '[[Module talk:': 829,
\   },
\ }
```

The value of `g:vim_mediawiki_completion_prefix_length` determines the minimum
number of characters required after the trigger sequence to trigger completion.
Default:
```viml
let g:vim_mediawiki_completion_prefix_length = 5
```

The value of `g:vim_mediawiki_completion_limit` determines how many suggestions are
fetched. Default:
```viml
let g:vim_mediawiki_completion_limit = 15
```

## Preview

The command `MediaWikiPreview` generates a preview of the page being edited,
and loads it in a web browser window. It is possible to customise the command
used to open the browser, by setting
```viml
let g:vim_mediawiki_browser_command = "chromium \r"
```
where the carriage return character `\r` will be replaced with the address of
the page to open (attention should be paid to insert an actual carriage return
character, and to not escape the backslash).

## Mappings

No mappings are set out-of-the-box. The following optional navigation mappings
```viml
nnoremap <buffer> j gj
nnoremap <buffer> k gk
nnoremap <buffer> 0 g0
nnoremap <buffer> ^ g^
nnoremap <buffer> $ g$
nnoremap <buffer> D dg$
nnoremap <buffer> C cg$
nnoremap <buffer> A g$a
```
can be enabled by setting to true the variable
```viml
let g:vim_mediawiki_mappings = 1
```

## Syntax highlighting

Languages within `<source>` or `<syntaxhighlight>` tags will be highlighted. A
list of languages (identified by their wiki name) to be ignored can be set:
```viml
let g:vim_mediawiki_ignored_wikilangs = ['cobol', 'pascal']
```

Syntax highlight settings are loaded for the languages detected within the
buffer at load or save time. Language settings can be preloaded for selected
languages:
```viml
let g:vim_mediawiki_preloaded_wikilangs = ['c', 'python']
```

A language name can be remapped to a different vim syntax highlighting:
```viml
let g:vim_mediawiki_wikilang_map = {'c': 'cpp'}
```

Credits and license
===================

The `syntax/mediawiki.vim` file is based on code originally published on
[Wikipedia:Text editor
support](http://en.wikipedia.org/wiki/Wikipedia:Text_editor_support) as public
domain, and distributed within the plugins
[wikipedia.vim](https://www.vim.org/scripts/script.php?script_id=1787) and
[mediawiki.vim](https://www.vim.org/scripts/script.php?script_id=3970).

The `ftplugin/mediawiki.vim` file contains some portions of code from the [HTML
ftplugin](https://github.com/vim/vim/blob/946e27ab65/runtime/ftplugin/html.vim#L28-L35)
of the vim runtime, by Johannes Zellner and Benji Fisher, and from
[mediawiki.vim](https://github.com/chikamichi/mediawiki.vim) by Jean-Denis
Vauguet (a.k.a. chikamichi).

The `autoload/mediawiki/fenced_languages.vim` file is adapted from
[mediawiki.vim](https://github.com/chikamichi/mediawiki.vim/blob/26e573726/autoload/mediawiki.vim)
by Olivier Teulière (a.k.a. ipkiss42).

All the original parts of this software, where not differently attributed or
licensed, are distributed under the MIT license. The full text of the license
is available in the [LICENSE
file](https://github.com/m-pilia/vim-mediawiki/blob/master/LICENSE) distributed
alongside the source code.

