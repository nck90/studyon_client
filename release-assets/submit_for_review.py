"""Submit 자습ON 1.0 for App Store review.

Run after the App Privacy section is filled in the App Store Connect UI.

Pre-reqs (already completed via API):
- Version 1.0 created, build 1.0.0 (6) VALID
- Metadata, keywords, URLs set (ko)
- Category: Education / Productivity
- Age rating: 4+
- Copyright, content rights
- Pricing: Free, KOR only
- Review details + demo account
- Screenshots: iPhone 6.7 (6) + iPad 12.9 (3)

Only remaining: App Privacy questionnaire in ASC UI.
After that completes, run:
    PYTHONPATH=~/Library/Python/3.9/lib/python/site-packages /usr/bin/python3 submit_for_review.py
"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from asc_client import api, APP_ID
import urllib.error
import json

VER = '3aa837c4-7e85-439c-b532-885e9d4edad1'


def main():
    # Create reviewSubmission
    try:
        rs = api('/v1/reviewSubmissions', 'POST', {
            'data': {
                'type': 'reviewSubmissions',
                'attributes': {'platform': 'IOS'},
                'relationships': {'app': {'data': {'type': 'apps', 'id': APP_ID}}}
            }
        })
        rs_id = rs['data']['id']
        print(f'[1/3] reviewSubmission created id={rs_id}')
    except urllib.error.HTTPError as e:
        print('Create reviewSubmission failed:')
        print(e.read().decode())
        sys.exit(1)

    # Attach version
    try:
        rsi = api('/v1/reviewSubmissionItems', 'POST', {
            'data': {
                'type': 'reviewSubmissionItems',
                'relationships': {
                    'reviewSubmission': {'data': {'type': 'reviewSubmissions', 'id': rs_id}},
                    'appStoreVersion': {'data': {'type': 'appStoreVersions', 'id': VER}},
                }
            }
        })
        print(f'[2/3] version attached item_id={rsi["data"]["id"]}')
    except urllib.error.HTTPError as e:
        err = e.read().decode()
        print('Attach version failed:')
        print(err)
        if 'APP_DATA_USAGES_REQUIRED' in err:
            print()
            print('>>> App Privacy section not filled yet. Complete it at:')
            print(f'>>> https://appstoreconnect.apple.com/apps/{APP_ID}/distribution/privacy')
        sys.exit(1)

    # Submit
    try:
        r = api(f'/v1/reviewSubmissions/{rs_id}', 'PATCH', {
            'data': {
                'type': 'reviewSubmissions', 'id': rs_id,
                'attributes': {'submitted': True}
            }
        })
        print(f'[3/3] submitted. state={r["data"]["attributes"].get("state")}')
        print(json.dumps(r['data']['attributes'], indent=2))
    except urllib.error.HTTPError as e:
        print('Submit failed:')
        print(e.read().decode())


if __name__ == '__main__':
    main()
