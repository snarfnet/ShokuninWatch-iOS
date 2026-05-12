import jwt, time, requests, sys

KEY_ID = 'WDXGY9WX55'
ISSUER = '2be0734f-943a-4d61-9dc9-5d9045c46fec'
APP_ID = '6764789904'
BUILD_NUMBER = sys.argv[1]

p8 = open('/tmp/asc_key.p8').read()

def make_token():
    return jwt.encode(
        {'iss': ISSUER, 'iat': int(time.time()), 'exp': int(time.time()) + 1200, 'aud': 'appstoreconnect-v1'},
        p8, algorithm='ES256', headers={'kid': KEY_ID}
    )

def headers():
    return {'Authorization': f'Bearer {make_token()}', 'Content-Type': 'application/json'}

def api(method, path, **kwargs):
    r = requests.request(method, f'https://api.appstoreconnect.apple.com/v1{path}',
        headers=headers(), **kwargs)
    return r

print(f'Waiting for build {BUILD_NUMBER} to be processed...')
build_id = None
for i in range(80):
    r = api('GET', f'/builds?filter[app]={APP_ID}&filter[version]={BUILD_NUMBER}&filter[processingState]=VALID&limit=1')
    data = r.json()
    if data.get('data'):
        build_id = data['data'][0]['id']
        print(f'Build ready: {build_id}')
        break
    print(f'  Waiting... ({i+1}/80)')
    time.sleep(30)

if not build_id:
    print('WARNING: Build not found after 40 minutes. Check ASC manually.')
    sys.exit(0)

# Set export compliance
r = api('PATCH', f'/builds/{build_id}',
    json={'data': {'type': 'builds', 'id': build_id, 'attributes': {'usesNonExemptEncryption': False}}})
print(f'Export compliance: {r.status_code}')

# Find version - check all states
version_id = None
version_state = None
r = api('GET', f'/apps/{APP_ID}/appStoreVersions?filter[platform]=IOS&limit=1')
data = r.json()
if data.get('data'):
    version_id = data['data'][0]['id']
    version_state = data['data'][0]['attributes']['appStoreState']
    print(f'Found version: {version_id} state={version_state}')

if version_state in ('WAITING_FOR_REVIEW', 'IN_REVIEW'):
    print(f'Already in review ({version_state}). Nothing to do.')
    sys.exit(0)

if not version_id or version_state in ('READY_FOR_DISTRIBUTION', 'READY_FOR_SALE'):
    # Get version string from the build
    br = api('GET', f'/builds/{build_id}')
    version_string = br.json()['data']['attributes'].get('version', '1.0')
    print(f'Creating new version {version_string}...')
    r = api('POST', '/appStoreVersions', json={
        'data': {
            'type': 'appStoreVersions',
            'attributes': {'platform': 'IOS', 'versionString': version_string},
            'relationships': {'app': {'data': {'type': 'apps', 'id': APP_ID}}}
        }
    })
    if r.status_code not in (200, 201):
        print(f'Failed to create version: {r.text[:300]}')
        sys.exit(1)
    version_id = r.json()['data']['id']
    version_state = 'PREPARE_FOR_SUBMISSION'

print(f'Version ID: {version_id} state={version_state}')

# Assign build
r = api('PATCH', f'/appStoreVersions/{version_id}/relationships/build',
    json={'data': {'type': 'builds', 'id': build_id}})
print(f'Build assigned: {r.status_code}')

# Set marketing URL and whatsNew on all localizations
whats_new = {
    'ja': 'パフォーマンス改善と安定性の向上。',
    'en-US': 'Performance improvements and stability enhancements.'
}
r = api('GET', f'/appStoreVersions/{version_id}/appStoreVersionLocalizations')
if r.status_code == 200:
    for loc in r.json().get('data', []):
        loc_id = loc['id']
        locale = loc['attributes']['locale']
        attrs = {'marketingUrl': 'https://snarfnet.github.io/'}
        if locale in whats_new:
            attrs['whatsNew'] = whats_new[locale]
        else:
            attrs['whatsNew'] = whats_new['en-US']
        lr = api('PATCH', f'/appStoreVersionLocalizations/{loc_id}', json={
            'data': {'type': 'appStoreVersionLocalizations', 'id': loc_id,
                     'attributes': attrs}
        })
        print(f'Localization {locale}: {lr.status_code}')

# Check version state
r = api('GET', f'/appStoreVersions/{version_id}')
if r.status_code == 200:
    current_state = r.json()['data']['attributes']['appStoreState']
    print(f'Version state: {current_state}')
    if current_state in ('WAITING_FOR_REVIEW', 'IN_REVIEW'):
        print(f'Already in review ({current_state}). Done!')
        sys.exit(0)

# Try to reuse existing READY_FOR_REVIEW submissions (ghosts with 0 items)
submission_id = None
r = api('GET', f'/apps/{APP_ID}/reviewSubmissions?filter[state]=READY_FOR_REVIEW')
if r.status_code == 200:
    for sub in r.json().get('data', []):
        sid = sub['id']
        ir = api('GET', f'/reviewSubmissions/{sid}/items')
        item_count = len(ir.json().get('data', [])) if ir.status_code == 200 else -1
        print(f'  Existing submission {sid}: {item_count} items')
        if item_count == 0:
            r2 = api('POST', '/reviewSubmissionItems', json={
                'data': {
                    'type': 'reviewSubmissionItems',
                    'relationships': {
                        'reviewSubmission': {'data': {'type': 'reviewSubmissions', 'id': sid}},
                        'appStoreVersion': {'data': {'type': 'appStoreVersions', 'id': version_id}}
                    }
                }
            })
            print(f'  Add item to {sid}: {r2.status_code}')
            if r2.status_code in (200, 201):
                submission_id = sid
                print(f'Reusing existing submission {sid}')
                break
            else:
                print(f'  {r2.text[:300]}')

if not submission_id:
    # Cancel any remaining blockers
    for sf in ['UNRESOLVED_ISSUES', 'READY_FOR_REVIEW', 'CANCELING']:
        r = api('GET', f'/apps/{APP_ID}/reviewSubmissions?filter[state]={sf}')
        if r.status_code == 200:
            for sub in r.json().get('data', []):
                api('PATCH', f'/reviewSubmissions/{sub["id"]}', json={
                    'data': {'type': 'reviewSubmissions', 'id': sub['id'], 'attributes': {'canceled': True}}
                })

    r = api('POST', '/reviewSubmissions', json={
        'data': {
            'type': 'reviewSubmissions',
            'relationships': {'app': {'data': {'type': 'apps', 'id': APP_ID}}}
        }
    })
    if r.status_code != 201:
        print(f'Create reviewSubmission: {r.status_code} {r.text[:500]}')
        sys.exit(1)
    submission_id = r.json()['data']['id']
    print(f'ReviewSubmission created: {submission_id}')

    r = api('POST', '/reviewSubmissionItems', json={
        'data': {
            'type': 'reviewSubmissionItems',
            'relationships': {
                'reviewSubmission': {'data': {'type': 'reviewSubmissions', 'id': submission_id}},
                'appStoreVersion': {'data': {'type': 'appStoreVersions', 'id': version_id}}
            }
        }
    })
    print(f'Add item: {r.status_code}')
    if r.status_code not in (200, 201):
        print(f'  Add item error: {r.text[:500]}')
        sys.exit(1)

# Submit
r = api('PATCH', f'/reviewSubmissions/{submission_id}', json={
    'data': {
        'type': 'reviewSubmissions',
        'id': submission_id,
        'attributes': {'submitted': True}
    }
})
if r.status_code == 200:
    state = r.json()['data']['attributes']['state']
    print(f'Submitted! State: {state}')
else:
    print(f'Submit failed: {r.status_code} {r.text[:500]}')
