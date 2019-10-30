import argparse
import re
import sys

import mwclient

style_modules = [
    'mediawiki.legacy.commonPrint,shared',
    'mediawiki.skinning.elements',
    'mediawiki.skinning.content',
    'mediawiki.skinning.interface',
    'skins.vector.styles',
    'site',
    'site.styles',
    'mediawiki.skinning.content.parsoid',
    'ext.cite.style',
]

css_link = '<link rel="stylesheet" href="https://{site}/w/load.php?{args}"/>'
js_link = '<script async="" src="/w/load.php?{args}"></script>'

html = r'''\
<!DOCTYPE html>
<html class="client-nojs" dir="ltr">
<head>
    <meta charset="UTF-8"/>
    {css_link}
    {js_link}
</head>
<body class="mediawiki ltr sitedir-ltr">
    <div id="content" class="mw-body" role="main">
        <div id="bodyContent" class="mw-body-content">
            <div id="mw-content-text" dir="ltr" class="mw-content-ltr">
            {body}
            </div>
        </div>
    </div>
</body>
</html>
'''


def main(argv):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--site', type=str, required=True,
                        help='Address of the MediaWiki site to query')
    parser.add_argument('--wikitext-file', type=str, required=True,
                        help='Path to the file containig the wikitext')
    parser.add_argument('--skin', type=str, required=True,
                        help='Skin used for the preview')
    parser.add_argument('--extra-style-modules', type=str, nargs='*', default=[],
                        help='Skin used for the preview')
    parser.add_argument('--output-file', type=str, required=True,
                        help='Destination for the output HTML')
    args = parser.parse_args(argv)

    site = mwclient.Site(args.site)

    with open(args.wikitext_file, 'r') as f:
        kwargs = {
            'text': f.read(),
            'prop': 'text|modules|jsconfigvars',
            'contentmodel': 'wikitext',
        }

    result = site.post('parse', **kwargs)

    # Build CSS and js links
    # https://www.mediawiki.org/wiki/API:Styling_content
    all_modules = style_modules + result['parse']['modulestyles'] + args.extra_style_modules
    css_args = {
        'modules': '|'.join(all_modules),
        'only': 'styles',
        'skin': args.skin,
    }
    js_args = {
        'modules': 'startup',
        'only': 'scripts',
        'raw': '1',
        'skin': args.skin,
    }
    css = css_link.format(site=args.site,
                          args='&amp;'.join(['%s=%s' % (k, v) for k, v in css_args.items()]))
    js = js_link.format(args='&amp;'.join(['%s=%s' % (k, v) for k, v in js_args.items()]))

    # Replace local resources with remote resources
    def fix_resources(text):
        text = re.sub(r'([^ps:])\/\/', r'\1https://', text)
        text = re.sub(r'(href|src)="/w', 'href="https://%s/w' % args.site, text)
        return text

    # Write result to file
    with open(args.output_file, 'w') as f:
        f.write(html.format(css_link=fix_resources(css),
                            js_link=fix_resources(js),
                            body=fix_resources(result['parse']['text']['*'])))


if __name__ == '__main__':
    main(sys.argv[1:])
