#!/usr/bin/env python3
"""Upload screenshots to ASC for the current app store version."""
import jwt, time, requests, os, hashlib, glob

KEY_ID = 'WDXGY9WX55'
ISSUER = '2be0734f-943a-4d61-9dc9-5d9045c46fec'
APP_ID = '6764789904'
p8 = open('/tmp/asc_key.p8').read()

def make_token():
    return jwt.encode(
        {'iss': ISSUER, 'iat': int(time.time()), 'exp': int(time.time()) + 1200, 'aud': 'appstoreconnect-v1'},
        p8, algorithm='ES256', headers={'kid': KEY_ID})

def api(method, path, **kwargs):
    return requests.request(method, f'https://api.appstoreconnect.apple.com/v1{path}',
        headers={'Authorization': f'Bearer {make_token()}', 'Content-Type': 'application/json'}, **kwargs)

# Find latest version
r = api('GET', f'/apps/{APP_ID}/appStoreVersions?filter[platform]=IOS&limit=1')
version_id = r.json()['data'][0]['id']
state = r.json()['data'][0]['attributes']['appStoreState']
print(f'Version: {version_id} state={state}')

# Get ja localization
r = api('GET', f'/appStoreVersions/{version_id}/appStoreVersionLocalizations')
loc_id = None
for loc in r.json().get('data', []):
    if loc['attributes']['locale'] in ('ja', 'en-US'):
        loc_id = loc['id']
        print(f'Using locale: {loc["attributes"]["locale"]} id={loc_id}')
        break
if not loc_id:
    loc_id = r.json()['data'][0]['id']
    print(f'Fallback locale: {r.json()["data"][0]["attributes"]["locale"]}')

# Get existing screenshot sets
r = api('GET', f'/appStoreVersionLocalizations/{loc_id}/appScreenshotSets')
existing_sets = {s['attributes']['screenshotDisplayType']: s['id'] for s in r.json().get('data', [])}

DISPLAY_TYPE = 'APP_IPHONE_67'
screenshots = sorted(glob.glob('screenshots-new/*.png'))
if not screenshots:
    print('No screenshots found in screenshots-new/')
    exit(0)

print(f'Found {len(screenshots)} screenshots')

# Get or create screenshot set
if DISPLAY_TYPE in existing_sets:
    set_id = existing_sets[DISPLAY_TYPE]
    # Delete existing
    r = api('GET', f'/appScreenshotSets/{set_id}/appScreenshots')
    for ss in r.json().get('data', []):
        api('DELETE', f'/appScreenshots/{ss["id"]}')
    print(f'Cleared existing {DISPLAY_TYPE} screenshots')
else:
    r = api('POST', '/appScreenshotSets', json={
        'data': {'type': 'appScreenshotSets',
                 'attributes': {'screenshotDisplayType': DISPLAY_TYPE},
                 'relationships': {'appStoreVersionLocalization': {
                     'data': {'type': 'appStoreVersionLocalizations', 'id': loc_id}}}}
    })
    set_id = r.json()['data']['id']
    print(f'Created screenshot set: {set_id}')

for filepath in screenshots:
    filename = os.path.basename(filepath)
    filesize = os.path.getsize(filepath)
    with open(filepath, 'rb') as f:
        file_data = f.read()
    checksum = hashlib.md5(file_data).hexdigest()

    r = api('POST', '/appScreenshots', json={
        'data': {'type': 'appScreenshots',
                 'attributes': {'fileName': filename, 'fileSize': filesize},
                 'relationships': {'appScreenshotSet': {
                     'data': {'type': 'appScreenshotSets', 'id': set_id}}}}
    })
    if r.status_code not in (200, 201):
        print(f'  Reserve failed {filename}: {r.status_code} {r.text[:200]}')
        continue
    ss_id = r.json()['data']['id']
    upload_ops = r.json()['data']['attributes'].get('uploadOperations', [])

    for op in upload_ops:
        uh = {h['name']: h['value'] for h in op['requestHeaders']}
        chunk = file_data[op['offset']:op['offset']+op['length']]
        requests.put(op['url'], headers=uh, data=chunk)

    r = api('PATCH', f'/appScreenshots/{ss_id}', json={
        'data': {'type': 'appScreenshots', 'id': ss_id,
                 'attributes': {'uploaded': True, 'sourceFileChecksum': {'type': 'md5', 'value': checksum}}}
    })
    status = r.json().get('data', {}).get('attributes', {}).get('assetDeliveryState', {}).get('state', '?')
    print(f'  {filename}: {status}')

print('Done!')
