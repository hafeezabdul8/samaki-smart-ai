import os
import json
import requests
from google.oauth2 import service_account
from google.auth.transport.requests import Request

def get_credentials():
    """Get credentials from environment variable or file."""
    creds_json = os.environ.get('FIREBASE_CREDENTIALS')
    if creds_json:
        return service_account.Credentials.from_service_account_info(
            json.loads(creds_json),
            scopes=['https://www.googleapis.com/auth/firebase.messaging']
        )
    return None

def get_access_token():
    credentials = get_credentials()
    if not credentials:
        return None
    credentials.refresh(Request())
    return credentials.token

def send_push_notification(tokens, title, body, data=None):
    if not tokens:
        print('No tokens to send to')
        return
    
    access_token = get_access_token()
    if not access_token:
        print('No credentials found')
        return
    
    creds_json = os.environ.get('FIREBASE_CREDENTIALS')
    if creds_json:
        cred_data = json.loads(creds_json)
        project_id = cred_data.get('project_id', 'samaki-smart-ai')
    else:
        project_id = 'samaki-smart-ai'
    
    url = f'https://fcm.googleapis.com/v1/projects/{project_id}/messages:send'
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Content-Type': 'application/json',
    }
    
    results = []
    for token in tokens:
        payload = {
            'message': {
                'token': token,
                'notification': {'title': title, 'body': body},
                'data': data or {},
                'android': {'notification': {'sound': 'default', 'click_action': 'FLUTTER_NOTIFICATION_CLICK', 'priority': 'high'}},
            }
        }
        try:
            response = requests.post(url, headers=headers, json=payload)
            results.append(response.json())
        except Exception as e:
            results.append({'error': str(e)})
    
    return results
