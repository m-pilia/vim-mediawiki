vim-mediawiki: plugin to edit MediaWiki pages from vim/neovim
===============================================================
[![Travis CI Build Status](https://travis-ci.org/m-pilia/vim-mediawiki.svg?branch=master)](https://travis-ci.org/m-pilia/vim-mediawiki)
[![codecov](https://codecov.io/gh/m-pilia/vim-mediawiki/branch/master/graph/badge.svg)](https://codecov.io/gh/m-pilia/vim-mediawiki/branch/master)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/m-pilia/vim-mediawiki/blob/master/LICENSE)

This is a plugin to help editing pages of a MediaWiki site from vim/neovim.

It provides a [coc.nvim](https://github.com/neoclide/coc.nvim) completion
source for auto-completion of wikilinks and templates.

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
or double braces. Multi-word completion is supported, so completions will be
suggested when typing more than one word inside the brackets, together with a
hint of the full page name.

![image](https://user-images.githubusercontent.com/8300317/67492770-9bff7380-f67f-11e9-9dd5-bf621ffb30df.png)

If you do not use coc.nvim, you may be able to use the function
`coc#source#mediawiki#complete()` to implement an
[omnifunc](https://vimhelp.org/options.txt.html#%27omnifunc%27), or to write an
adapter to plug it in other completion mechanisms. The API used by this source
is documented
[here](https://github.com/neoclide/coc.nvim/wiki/Create-custom-source).

Configuration
=============

A set of variables allows to customise the behaviour of the plugin. All
variables can either be set globally as `g:vim_mediawiki_...` or locally for
each buffer with `b:vim_mediawiki_...`.

The value of `g:vim_mediawiki_site` sets the address of the wiki to edit.
Default:
```viml
let g:vim_mediawiki_site = 'en.wikipedia.org'
```

It is possible to customise which
[namespaces](https://www.mediawiki.org/wiki/Help:Namespaces) to auto-complete.
The configuration is stored on a per-site basis in a dictionary called
`g:vim_mediawiki_completion_namespaces`, whose keys are possible values of
`g:vim_mediawiki_site`. Each site is mapped to a dictionary, that associates
each trigger sequence to the number of the corresponding namespace on that
site. Only the namespaces listed in this map will be completed. A `default`
entry is used when a site is not present among the keys. The default value is:
```viml
let g:vim_mediawiki_completion_namespaces = {
\ 'default': {
\       '[[': 0,
\       '{{': 10,
\       '[[File:': 6,
\       '[[Category:': 14,
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

License
=======

This software is distributed under the MIT license. The full text of the license
is available in the [LICENSE
file](https://github.com/m-pilia/vim-mediawiki/blob/master/LICENSE) distributed
alongside the source code.

