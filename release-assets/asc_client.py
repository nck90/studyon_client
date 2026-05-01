"""App Store Connect API helper for 자습ON."""
import jwt, time, urllib.request, urllib.error, json, sys

KEY_ID = "62YGDJ5M4Z"
ISSUER = "ee3bda54-fcc7-4e9c-9a7d-546d91534ace"
APP_ID = "6762423801"
BUILD_ID = "026666f9-c6ad-47f5-b261-258422f4d6c5"
P8 = '/Users/bagjun-won/Downloads/AuthKey_62YGDJ5M4Z.p8'

with open(P8) as f:
    KEY = f.read()

def tok():
    return jwt.encode(
        {"iss": ISSUER, "exp": int(time.time()) + 600, "aud": "appstoreconnect-v1"},
        KEY, algorithm='ES256',
        headers={"alg": "ES256", "kid": KEY_ID, "typ": "JWT"})

def api(path, method='GET', body=None, raw=False):
    url = f'https://api.appstoreconnect.apple.com{path}' if path.startswith('/') else path
    data = None
    headers = {'Authorization': f'Bearer {tok()}'}
    if body is not None:
        data = json.dumps(body).encode()
        headers['Content-Type'] = 'application/json'
    req = urllib.request.Request(url, data=data, method=method, headers=headers)
    try:
        resp = urllib.request.urlopen(req)
        content = resp.read()
        if raw:
            return content
        return json.loads(content or b'{}')
    except urllib.error.HTTPError as e:
        err_body = e.read().decode()
        print(f'HTTP {e.code} {method} {path}')
        print(err_body)
        raise
