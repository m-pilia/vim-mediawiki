#!/usr/bin/env python3

r'''
Query the MediaWiki API to get a list of pages starting with a given prefix.
'''

import argparse
import itertools
import sys

import mwclient


def main(argv):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--site', type=str, required=True,
                        help='Address of the MediaWiki site to query')
    parser.add_argument('--prefix', type=str, required=True,
                        help='Prefix for the desired pages')
    parser.add_argument('--namespace', type=int, required=True,
                        help='Namespace for the desired pages')
    parser.add_argument('--limit', type=int, required=True,
                        help='Maximum number of pages to retrieve')
    args = parser.parse_args(argv)

    site = mwclient.Site(args.site)

    kwargs = {
        'prefix': args.prefix,
        'namespace': str(args.namespace),
        'filterredir': 'nonredirects',
        'limit': min(50, args.limit),
        'generator': False,
    }

    result = site.allpages(**kwargs)
    result = list(itertools.islice(result, args.limit))

    if result:
        print('\n'.join(result))


if __name__ == '__main__':
    main(sys.argv[1:])
