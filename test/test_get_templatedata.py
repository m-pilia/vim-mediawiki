import io
import json
import unittest
import unittest.mock as mock

import scripts.get_templatedata

_params = {
    "param1": {
        "label": {
            "en": "Label 1"
        },
        "description": {
            "en": "Description 1"
        },
        "type": "string",
        "required": False,
        "suggested": False,
        "example": None,
        "deprecated": False,
        "aliases": [],
        "autovalue": None,
        "default": None
    },
    "param2": {
        "label": None,
        "required": False,
        "suggested": False,
        "description": None,
        "example": None,
        "deprecated": False,
        "aliases": [],
        "autovalue": None,
        "default": None,
        "type": "unknown"
    },
}


# Get an example API output with given tamplate name and parameters
def get_expected_output(name='', params=None):
    return {
        "batchcomplete": "",
        "pages": {} if params is None else {
            "5474740": {
                "title": name,
                "description": {
                    "en": "Template description"
                },
                "params": params,
                "paramOrder": list(params.keys()),
                "format": None,
                "sets": [],
                "maps": {}
            }
        }
    }


class TestGetTemplatedata(unittest.TestCase):

    # Parametric sub-test
    @mock.patch('sys.stdout', new_callable=io.StringIO)
    @mock.patch('mwclient.Site', autospec=True)
    def _test_main_for_params(self, template_name, expected_stdout, expected_output, site_mock, stdout_mock):
        expected_site = 'some_site'
        expected_method = 'templatedata'

        api_mock = site_mock.return_value.api
        api_mock.return_value = expected_output

        argv = [
            '--site', expected_site,
            '--template', template_name,
        ]

        expected_args = {
            'titles': template_name,
            'format': 'jsonfm',
            'redirects': True,
        }

        # Act
        scripts.get_templatedata.main(argv)

        # Assert
        site_mock.assert_called_once_with(expected_site)
        api_mock.assert_called_once_with(expected_method, **expected_args)
        self.assertEqual(expected_stdout, stdout_mock.getvalue().strip())

    def test_main(self):
        template_name = 'Template:Some template'

        # (template_name, expected_stdout, expected_output)
        cases_to_test = [
            # No pages returned by API (e.g. non-existant template name)
            (template_name, json.dumps({}), get_expected_output()),
            # Empty list of parameters returned by API
            (template_name, json.dumps({}), get_expected_output(template_name, {})),
            # Valid list of parameters returned by API
            (template_name, json.dumps(_params), get_expected_output(template_name, _params)),
        ]

        for template_name, expected_stdout, expected_output in cases_to_test:
            with self.subTest(template_name=template_name,
                              expected_stdout=expected_stdout,
                              expected_output=expected_output,
                              ):
                self._test_main_for_params(template_name, expected_stdout, expected_output)
