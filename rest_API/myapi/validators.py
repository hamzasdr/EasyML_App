import json
from json import JSONDecodeError

from django.core.exceptions import ValidationError
from django.utils.translation import gettext_lazy as _


def validate_hidden_layers(value):
    try:
        hidden_layers_list = json.loads(value)
        if type(hidden_layers_list) is not list:
            raise ValidationError(
                _('%(value)s is not a JSON list of integers.'),
                params={'value': value},
            )
        if len([val for val in hidden_layers_list if type(val) is not int]) > 0:
            raise ValidationError(
                _('%(value)s is not a JSON list of integers.'),
                params={'value': value},
            )
    except JSONDecodeError:
        raise ValidationError(
            _('%(value)s is not a JSON list of integers.'),
            params={'value': value},
        )


def validate_max_features(value):
    try:
        max_features = int(value)
        if max_features <= 0:
            raise ValidationError(
                _('%(value)s is non-positive. It must be positive if it\'s an int value.'),
                params={'value': value},
            )
    except ValueError:
        try:
            max_features = float(value)
            if max_features <= 0.0 or max_features > 1.0:
                raise ValidationError(
                    _('%(value)s is outside the range 0.0 (exclusive) to 1.0 (inclusive).'
                      'It must be inside this range if its a float value'),
                    params={'value': value},
                )
        except ValueError:
            if value is None or value in ('auto', 'sqrt', 'log2'):
                pass
            else:
                raise ValidationError(
                    _('"%(value)s" is not an int, a float or one of the values ["auto", "sqrt", "log2"].'),
                    params={'value': value},
                )