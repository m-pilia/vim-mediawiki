#!/usr/bin/env python3

r'''
Query the MediaWiki API to get TemplateData for a given template.
Output the JSON schema for the template to stdout.
'''

import argparse
import json
import sys

import mwclient


def main(argv):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--site', type=str, required=True,
                        help='Address of the MediaWiki site to query')
    parser.add_argument('--template', type=str, required=True,
                        help='Desired template name (inclusive of namespace)')
    args = parser.parse_args(argv)

    site = mwclient.Site(args.site)

    kwargs = {
        'titles': args.template,
        'format': 'jsonfm',
        'redirects': True,
    }

    result = site.api('templatedata', **kwargs)

    output = {}

    if result and 'pages' in result and result['pages']:
        for p in result['pages'].values():
            output.update(p['params'])

    print(json.dumps(output))


if __name__ == '__main__':
    main(sys.argv[1:])
