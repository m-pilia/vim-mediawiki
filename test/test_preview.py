from tempfile import NamedTemporaryFile as tmpfile
import unittest
import unittest.mock as mock

import scripts.preview


class TestListPages(unittest.TestCase):

    @mock.patch('mwclient.Site', autospec=True)
    def test_main(self, site_mock):
        post_mock = site_mock.return_value.post
        post_mock.return_value = {
            'parse': {
                'text': {
                    '*': 'parsing_output',
                },
                'modulestyles': [
                    'some_module',
                    'some_other_module',
                ],
            },
        }

        expected_site = 'some_site'
        expected_text = 'some_content'
        expected_skin = 'some_skin'
        expected_extra_modules = ['some_extra_module', 'some_other_extra_module']
        expected_modules = post_mock.return_value['parse']['modulestyles'] + expected_extra_modules

        with tmpfile('w') as wikitext_file, tmpfile('r+') as out_file:
            wikitext_file.write(expected_text)
            wikitext_file.flush()

            argv = [
                '--site', expected_site,
                '--wikitext-file', wikitext_file.name,
                '--skin', expected_skin,
                '--extra-style-modules', *expected_extra_modules,
                '--output-file', out_file.name,
            ]

            expected_args = {
                'text': expected_text,
                'prop': 'text|modules|jsconfigvars',
                'contentmodel': 'wikitext',
            }

            # Act
            scripts.preview.main(argv)

            # Assert
            site_mock.assert_called_once_with(expected_site)
            post_mock.assert_called_once_with('parse', **expected_args)

            output_html = out_file.read()
            self.assertRegex(output_html, 'parsing_output')
            for module in expected_modules:
                self.assertRegex(output_html, module)
