import itertools
import io
import unittest
import unittest.mock as mock

import scripts.list_pages


def _allpages(*_args, **_kwargs):
    for i in range(1, 100000):
        yield f'Page {i}'


class TestListPages(unittest.TestCase):

    @mock.patch('sys.stdout', new_callable=io.StringIO)
    @mock.patch('mwclient.Site', autospec=True)
    def test_main(self, site_mock, stdout_mock):
        allpages_mock = site_mock.return_value.allpages
        allpages_mock.return_value = _allpages()

        expected_site = 'some_site'
        expected_prefix = 'some_prefix'
        expected_namespace = 10
        expected_limit = 20
        expected_stdout = '\n'.join(itertools.islice(_allpages(), expected_limit)) + '\n'

        argv = [
            '--site', expected_site,
            '--prefix', expected_prefix,
            '--namespace', str(expected_namespace),
            '--limit', str(expected_limit),
        ]

        expected_args = {
            'prefix': expected_prefix,
            'namespace': str(expected_namespace),
            'filterredir': 'nonredirects',
            'limit': expected_limit,
            'generator': False,
        }

        # Act
        scripts.list_pages.main(argv)

        # Assert
        site_mock.assert_called_once_with(expected_site)
        allpages_mock.assert_called_once_with(**expected_args)
        self.assertEqual(expected_stdout, stdout_mock.getvalue())
