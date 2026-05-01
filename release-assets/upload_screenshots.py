"""Upload App Store screenshots for 자습ON."""
import os, sys, hashlib, urllib.request
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from asc_client import api, tok

VER_LOC = '16e86620-dba4-4b94-98f4-1f1fe8c98b8e'

SETS = [
    ('APP_IPHONE_67', [
        '/Users/bagjun-won/studyon/release-assets/submission/iphone-6.7/1-hero-home.png',
        '/Users/bagjun-won/studyon/release-assets/submission/iphone-6.7/2-timer.png',
        '/Users/bagjun-won/studyon/release-assets/submission/iphone-6.7/3-records.png',
        '/Users/bagjun-won/studyon/release-assets/submission/iphone-6.7/4-summary.png',
        '/Users/bagjun-won/studyon/release-assets/submission/iphone-6.7/5-rankings.png',
        '/Users/bagjun-won/studyon/release-assets/submission/iphone-6.7/6-profile.png',
    ]),
    # iPad already uploaded
    # ('APP_IPAD_PRO_3GEN_129', [
    #     '/Users/bagjun-won/studyon/release-assets/submission/ipad-13/1-hero-home.png',
    #     '/Users/bagjun-won/studyon/release-assets/submission/ipad-13/2-timer.png',
    #     '/Users/bagjun-won/studyon/release-assets/submission/ipad-13/3-summary.png',
    # ]),
]


def create_set(display_type):
    r = api('/v1/appScreenshotSets', 'POST', {
        'data': {
            'type': 'appScreenshotSets',
            'attributes': {'screenshotDisplayType': display_type},
            'relationships': {
                'appStoreVersionLocalization': {
                    'data': {'type': 'appStoreVersionLocalizations', 'id': VER_LOC}
                }
            }
        }
    })
    return r['data']['id']


def reserve_screenshot(set_id, file_path):
    size = os.path.getsize(file_path)
    name = os.path.basename(file_path)
    r = api('/v1/appScreenshots', 'POST', {
        'data': {
            'type': 'appScreenshots',
            'attributes': {'fileSize': size, 'fileName': name},
            'relationships': {
                'appScreenshotSet': {'data': {'type': 'appScreenshotSets', 'id': set_id}}
            }
        }
    })
    return r['data']['id'], r['data']['attributes']['uploadOperations']


def do_upload(file_path, operations):
    with open(file_path, 'rb') as f:
        data = f.read()
    for op in operations:
        length = op['length']
        offset = op['offset']
        url = op['url']
        method = op['method']
        chunk = data[offset:offset + length]
        headers = {h['name']: h['value'] for h in op['requestHeaders']}
        req = urllib.request.Request(url, data=chunk, method=method, headers=headers)
        urllib.request.urlopen(req).read()


def commit(screenshot_id, file_path):
    with open(file_path, 'rb') as f:
        md5 = hashlib.md5(f.read()).hexdigest()
    api(f'/v1/appScreenshots/{screenshot_id}', 'PATCH', {
        'data': {
            'type': 'appScreenshots',
            'id': screenshot_id,
            'attributes': {'uploaded': True, 'sourceFileChecksum': md5}
        }
    })


def main():
    for display_type, files in SETS:
        print(f'\n=== {display_type} ===')
        try:
            set_id = create_set(display_type)
        except Exception as e:
            print(f'  skip set creation: {e}')
            continue
        print(f'  set_id={set_id}')
        for f in files:
            name = os.path.basename(f)
            try:
                sid, ops = reserve_screenshot(set_id, f)
                do_upload(f, ops)
                commit(sid, f)
                print(f'  ✓ {name}')
            except Exception as e:
                print(f'  ✗ {name}: {e}')


if __name__ == '__main__':
    main()
