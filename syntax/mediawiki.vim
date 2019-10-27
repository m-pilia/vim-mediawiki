" This file contains code originally published on
"   http://en.wikipedia.org/wiki/Wikipedia:Text_editor_support
" as public domain.
"
" See also:
" * wikipedia.vim (https://www.vim.org/scripts/script.php?script_id=1787
" * mediawiki.vim (https://www.vim.org/scripts/script.php?script_id=3970
"
" Credits: [[User:Aepd87]], [[User:Danny373]], [[User:Ingo Karkat]], et al.

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
syntax keyword htmlTagName contained math nowiki references source syntaxhighlight

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
syntax region wikiRef matchgroup=htmlTag start="<ref>"  end="<\/ref>"   contains=wikiNowiki,wikiNowikiEndTag

syntax cluster wikiText contains=wikiLink,wikiTemplate,wikiNowiki,wikiNowikiEndTag,wikiItalic,wikiBold,wikiBoldAndItalic

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

syntax cluster wikiTop contains=@Spell,wikiLink,wikiNowiki,wikiNowikiEndTag

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

syntax region wikiLink start="\[\[" end="\]\]\(s\|'s\|es\|ing\|\)" oneline contains=wikiLink,wikiNowiki,wikiNowikiEndTag

syntax region wikiLink start="https\?://" end="\W*\_s"me=s-1 oneline
syntax region wikiLink start="\[http:"   end="\]" oneline contains=wikiNowiki,wikiNowikiEndTag
syntax region wikiLink start="\[https:"  end="\]" oneline contains=wikiNowiki,wikiNowikiEndTag
syntax region wikiLink start="\[ftp:"    end="\]" oneline contains=wikiNowiki,wikiNowikiEndTag
syntax region wikiLink start="\[gopher:" end="\]" oneline contains=wikiNowiki,wikiNowikiEndTag
syntax region wikiLink start="\[news:"   end="\]" oneline contains=wikiNowiki,wikiNowikiEndTag
syntax region wikiLink start="\[mailto:" end="\]" oneline contains=wikiNowiki,wikiNowikiEndTag

syntax match  wikiTemplateName /{{[^{|}<>\[\]]\+/hs=s+2 contained
syntax region wikiTemplate start="{{" end="}}" keepend extend contains=wikiNowiki,wikiNowikiEndTag,wikiTemplateName,wikiTemplateParam,wikiTemplate,wikiLink
syntax region wikiTemplateParam start="{{{\s*\d" end="}}}" extend contains=wikiTemplateName

syntax match wikiParaFormatChar /^[\:|\*|;|#]\+/
syntax match wikiParaFormatChar /^-----*/
syntax match wikiPre            /^\ .*$/         contains=wikiNowiki,wikiNowikiEndTag

hi def link wikiItalic        htmlItalic
hi def link wikiBold          htmlBold
hi def link wikiBoldItalic    htmlBoldItalic
hi def link wikiItalicBold    htmlBoldItalic
hi def link wikiBoldAndItalic htmlBoldItalic

hi def link wikiH1 htmlTitle
hi def link wikiH2 htmlTitle
hi def link wikiH3 htmlTitle
hi def link wikiH4 htmlTitle
hi def link wikiH5 htmlTitle
hi def link wikiH6 htmlTitle

hi def link wikiLink           htmlLink
hi def link wikiTemplate       htmlSpecial
hi def link wikiTemplateParam  htmlSpecial
hi def link wikiTemplateName   Type
hi def link wikiParaFormatChar htmlSpecial
hi def link wikiPre            htmlConstant
hi def link wikiRef            htmlComment

hi def link htmlPre            wikiPre
hi def link wikiSource         wikiPre
hi def link wikiSyntaxHL       wikiPre

hi def link wikiTableSeparator Statement
hi def link wikiTableFormatEnd wikiTableSeparator
hi def link wikiTableHeadingCell htmlBold

let b:current_syntax = 'mediawiki'

let &cpoptions = s:keepcpo
unlet! s:keepcpo
