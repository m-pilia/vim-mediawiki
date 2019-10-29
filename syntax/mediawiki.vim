" This file contains code originally published on
"   http://en.wikipedia.org/wiki/Wikipedia:Text_editor_support
" as public domain.
"
" See also:
" * wikipedia.vim (https://www.vim.org/scripts/script.php?script_id=1787
" * mediawiki.vim (https://www.vim.org/scripts/script.php?script_id=3970
"
" Credits: [[User:Aepd87]], [[User:Danny373]], [[User:Ingo Karkat]], et al.

scriptencoding utf-8

if exists('b:current_syntax')
    finish
endif
let s:keepcpo= &cpoptions
set cpoptions&vim

" Load HTML syntax
runtime! syntax/html.vim
unlet! b:current_syntax

syntax case ignore
syntax spell toplevel

" Allowed HTML tag names
syntax clear htmlTagName
syntax keyword htmlTagName contained big blockquote br caption center cite code
syntax keyword htmlTagName contained dd del div dl dt font hr ins li
syntax keyword htmlTagName contained ol p poem pre rb rp rt ruby s small span strike sub
syntax keyword htmlTagName contained sup table td th tr tt ul var
syntax match   htmlTagName contained "\<\(b\|i\|u\|h[1-6]\|em\|strong\)\>"

" Allowed Wiki tag names
syntax keyword htmlTagName contained math nowiki ref references source syntaxhighlight

" Allowed arg names
syntax clear htmlArg
syntax keyword htmlArg contained align lang dir width height nowrap bgcolor clear
syntax keyword htmlArg contained noshade cite datetime size face color type start
syntax keyword htmlArg contained value compact summary border frame rules
syntax keyword htmlArg contained cellspacing cellpadding valign char charoff
syntax keyword htmlArg contained colgroup col span abbr axis headers scope rowspan
syntax keyword htmlArg contained colspan id class name style title

" No htmlTop and wikiPre inside HTML preformatted areas, because
" MediaWiki renders everything in there literally (HTML tags and
" entities, too): <pre> tags work as the combination of <nowiki> and
" the standard HTML <pre> tag: the content will preformatted, and it
" will not be parsed, but shown as in the wikitext source.
"
" With wikiPre, indented lines would be rendered differently from
" unindented lines.
syntax match htmlPreTag         /<pre\>[^>]*>/                contains=htmlTag
syntax match htmlPreEndTag      /<\/pre>/                     contains=htmlEndTag
syntax match wikiNowikiTag      /<nowiki>/                    contains=htmlTag
syntax match wikiNowikiEndTag   /<\/nowiki>/                  contains=htmlEndTag
syntax match wikiSourceTag      /<source\s\+[^>]\+>/          contains=htmlTag
syntax match wikiSourceEndTag   /<\/source>/                  contains=htmlEndTag
syntax match wikiSyntaxHLTag    /<syntaxhighlight\s\+[^>]\+>/ contains=htmlTag
syntax match wikiSyntaxHLEndTag /<\/syntaxhighlight>/         contains=htmlEndTag

" Note: Cannot use 'start="<pre>"rs=e', so still have the <pre> tag
" highlighted correctly via separate syntax-match. Unfortunately, this will
" also highlight <pre> tags inside the preformatted region.
syntax region htmlPre    start="<pre\>[^>]*>"                          end="<\/pre>"me=e-6              contains=htmlPreTag
syntax region wikiNowiki start="<nowiki>"                              end="<\/nowiki>"me=e-9           contains=wikiNowikiTag
syntax region wikiSource start="<source\s\+[^>]\+>"            keepend end="<\/source>"me=e-9           contains=wikiSourceTag
syntax region wikiSyntaxHL start="<syntaxhighlight\s\+[^>]\+>" keepend end="<\/syntaxhighlight>"me=e-18 contains=wikiSyntaxHLTag

" Include TeX syntax for math
syntax include @TeX syntax/tex.vim
unlet! b:current_syntax

syntax region wikiTeX matchgroup=htmlTag start="<math>" end="<\/math>"  contains=@texMathZoneGroup,wikiNowiki,wikiNowikiEndTag

syntax cluster wikiText contains=wikiExternalLink,wikiLink,wikiTemplate,wikiNowiki,wikiNowikiEndTag,wikiItalic,wikiBold,wikiBoldAndItalic

" Tables
syntax cluster wikiTableFormat contains=wikiTemplate,htmlString,htmlArg,htmlValue
syntax region wikiTable matchgroup=wikiTableSeparator start="{|" end="|}" contains=wikiTableHeaderLine,wikiTableCaptionLine,wikiTableNewRow,wikiTableHeadingCell,wikiTableNormalCell,@wikiText
syntax match  wikiTableSeparator /^!/ contained
syntax match  wikiTableSeparator /^|/ contained
syntax match  wikiTableSeparator /^|[+-]/ contained
syntax match  wikiTableSeparator /||/ contained
syntax match  wikiTableSeparator /!!/ contained
syntax match  wikiTableFormatEnd /[!|]/ contained
syntax match  wikiTableHeadingCell /\(^!\|!!\)\([^!|]*|\)\?.*/ contains=wikiTableSeparator,@wikiText,wikiTableHeadingFormat
" Require at least one '=' in the format, to avoid spurious matches (e.g.
" the | in [[foo|bar]] might be taken as the final |, indicating the beginning
" of the cell). The same is done for wikiTableNormalFormat below.
syntax match  wikiTableHeadingFormat /\%(^!\|!!\)[^!|]\+=[^!|]\+\([!|]\)\(\1\)\@!/me=e-1 contains=@wikiTableFormat,wikiTableSeparator nextgroup=wikiTableFormatEnd
syntax match  wikiTableNormalCell /\(^|\|||\)\([^|]*|\)\?.*/ contains=wikiTableSeparator,@wikiText,wikiTableNormalFormat
syntax match  wikiTableNormalFormat /\(^|\|||\)[^|]\+=[^|]\+||\@!/me=e-1 contains=@wikiTableFormat,wikiTableSeparator nextgroup=wikiTableFormatEnd
syntax match  wikiTableHeaderLine /\(^{|\)\@<=.*$/ contained contains=@wikiTableFormat
syntax match  wikiTableCaptionLine /^|+.*$/ contained contains=wikiTableSeparator,@wikiText
syntax match  wikiTableNewRow /^|-.*$/ contained contains=wikiTableSeparator,@wikiTableFormat

syntax cluster wikiTop contains=@Spell,wikiExternalLink,wikiLink,wikiNowiki,wikiNowikiEndTag

syntax region wikiItalic        start=+'\@<!'''\@!+ end=+''+    oneline contains=@wikiTop,wikiItalicBold
syntax region wikiBold          start=+'''+         end=+'''+   oneline contains=@wikiTop,wikiBoldItalic
syntax region wikiBoldAndItalic start=+'''''+       end=+'''''+ oneline contains=@wikiTop

syntax region wikiBoldItalic contained start=+'\@<!'''\@!+ end=+''+  oneline contains=@wikiTop
syntax region wikiItalicBold contained start=+'''+         end=+'''+ oneline contains=@wikiTop

syntax region wikiH1 start="^="      end="="      oneline contains=@wikiTop
syntax region wikiH2 start="^=="     end="=="     oneline contains=@wikiTop
syntax region wikiH3 start="^==="    end="==="    oneline contains=@wikiTop
syntax region wikiH4 start="^===="   end="===="   oneline contains=@wikiTop
syntax region wikiH5 start="^====="  end="====="  oneline contains=@wikiTop
syntax region wikiH6 start="^======" end="======" oneline contains=@wikiTop

syntax region wikiLink start="\[\[" end="\v\]\].{-}([\[\],.;:#{}'`!"£$%&/()=?^|\\–—[:space:]]|$)@=" keepend oneline transparent contains=wikiLinkBracket,wikiLinkSuffix
syntax region wikiLinkBracket matchgroup=wikiLinkDelimiter start="\[\[" end="\]\]" keepend oneline contained contains=wikiLinkPage,wikiLinkDelimiter,wikiLinkName
syntax match wikiLinkPage /\v[^|]+(\|)@=/ contained
syntax match wikiLinkDelimiter /\V|/ contained nextgroup=wikiLinkName
syntax match wikiLinkName /\v(\|)@<=.*/ contained contains=wikiExternalLink,wikiLink,wikiNowiki,wikiNowikiEndTag
syntax match wikiLinkSuffix /\v[^\[].*/ contained

syntax match wikiExternalLink "\vhttps?\:\/\/[^[:space:]]*(\_s)@="
syntax region wikiExternalLink matchgroup=wikiExternalLinkDelimiter start="\[\(http:\)\@="   end="\]" oneline keepend contains=wikiNowiki,wikiNowikiEndTag,wikiExternalLinkName
syntax region wikiExternalLink matchgroup=wikiExternalLinkDelimiter start="\[\(https:\)\@="  end="\]" oneline keepend contains=wikiNowiki,wikiNowikiEndTag,wikiExternalLinkName
syntax region wikiExternalLink matchgroup=wikiExternalLinkDelimiter start="\[\(ftp:\)\@="    end="\]" oneline keepend contains=wikiNowiki,wikiNowikiEndTag,wikiExternalLinkName
syntax region wikiExternalLink matchgroup=wikiExternalLinkDelimiter start="\[\(gopher:\)\@=" end="\]" oneline keepend contains=wikiNowiki,wikiNowikiEndTag,wikiExternalLinkName
syntax region wikiExternalLink matchgroup=wikiExternalLinkDelimiter start="\[\(news:\)\@="   end="\]" oneline keepend contains=wikiNowiki,wikiNowikiEndTag,wikiExternalLinkName
syntax region wikiExternalLink matchgroup=wikiExternalLinkDelimiter start="\[\(mailto:\)\@=" end="\]" oneline keepend contains=wikiNowiki,wikiNowikiEndTag,wikiExternalLinkName
syntax match wikiExternalLinkName '[[:space:]][^\]]*' contained

syntax match wikiTemplateName /{{[^{|}<>\[\]]\+/hs=s+2 contained
syntax match wikiTemplateArgName /\v(\|)@<=[^=]+(\=)@=/ contained
syntax match wikiTemplateArgVal /\v(\|)@<=[^=|]+(\||$)@=/ contained contains=wikiNowiki,wikiNowikiEndTag,wikiTemplateParam,wikiTemplate,wikiExternalLink,wikiLink
syntax match wikiTemplateArgVal /\v(\=)@<=[^|]+/ contained contains=wikiNowiki,wikiNowikiEndTag,wikiTemplateParam,wikiTemplate,wikiExternalLink,wikiLink
syntax match wikiTemplateArgVal /\v^\s*[^|{]+/ contained contains=wikiNowiki,wikiNowikiEndTag,wikiTemplateParam,wikiTemplate,wikiExternalLink,wikiLink
syntax region wikiTemplate start="{{" matchgroup=wikiTemplateDelim end="}}" keepend extend contains=wikiTemplateName,wikiTemplateArgName,wikiTemplateArgVal
syntax region wikiTemplateParam start="{{{\s*\d" end="}}}" extend contains=wikiTemplateName

syntax match wikiParaFormatChar /^[\:|\*|;|#]\+/
syntax match wikiParaFormatChar /^-----*/
syntax match wikiPre            /^\ .*$/         contains=wikiNowiki,wikiNowikiEndTag

highlight def wikiLinkText cterm=underline gui=underline

highlight def link wikiItalic        htmlItalic
highlight def link wikiBold          htmlBold
highlight def link wikiBoldItalic    htmlBoldItalic
highlight def link wikiItalicBold    htmlBoldItalic
highlight def link wikiBoldAndItalic htmlBoldItalic

highlight def link wikiH1 htmlTitle
highlight def link wikiH2 htmlTitle
highlight def link wikiH3 htmlTitle
highlight def link wikiH4 htmlTitle
highlight def link wikiH5 htmlTitle
highlight def link wikiH6 htmlTitle

highlight def link wikiLinkDelimiter         Statement
highlight def link wikiLinkpage              wikiLinkText
highlight def link wikiLinkName              wikiLinkText
highlight def link wikiLinkSuffix            wikiLinkText
highlight def link wikiExternalLink          htmlLink
highlight def link wikiExternalLinkName      htmlPreProc
highlight def link wikiExternalLinkDelimiter htmlPreProc
highlight def link wikiTemplateArgName       Identifier
highlight def link wikiTemplateArgVal        String
highlight def link wikiTemplate              Statement
highlight def link wikiTemplateDelim         Statement
highlight def link wikiTemplateParam         htmlSpecial
highlight def link wikiTemplateName          Type
highlight def link wikiParaFormatChar        htmlSpecial
highlight def link wikiPre                   htmlConstant

highlight def link htmlPre            wikiPre
highlight def link wikiSource         wikiPre
highlight def link wikiSyntaxHL       wikiPre

highlight def link wikiTableSeparator Statement
highlight def link wikiTableFormatEnd wikiTableSeparator
highlight def link wikiTableHeadingCell htmlBold

let b:current_syntax = 'mediawiki'

let &cpoptions = s:keepcpo
unlet! s:keepcpo
