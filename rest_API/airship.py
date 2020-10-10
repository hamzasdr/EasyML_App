import urbanairship as ua
import json

from myapi.enums import DeviceType
from myapi.models import Device

_appKey = "i8hkLB77RzaA6o2zEOyMQg"
_masterSecret = "cHb5tqB5SiuKnrxqKtiBTQ"

airship = ua.Airship(key=_appKey, secret=_masterSecret)


def push_notification(devices: list, title: str, message: str, extra: dict):
    push = airship.create_push()
    push.device_types = ua.device_types(*DeviceType.choices_list())

    channels = [ua.android_channel(device.channel_id) for device in devices if device.device_type == 'android'] + \
               [ua.ios_channel(device.channel_id) for device in devices if device.device_type == 'ios']

    if len(channels) == 0:
        return

    push.audience = ua.and_(*channels)

    push.notification = ua.notification(
        alert=message,
        android=ua.android(
            alert=message,
            title=title,
            extra={'payload': json.dumps(extra)}
        ),
        ios=ua.ios(
            alert=message,
            title=title,
            extra={'payload': json.dumps(extra)}
        )
    )
    # print(push.payload)
    response = push.send()
    print(response.ok)
    return response


