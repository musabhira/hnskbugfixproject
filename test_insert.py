import urllib.request
import json

headers = {
    "apikey": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdzd2h5bnVhYmRzcG53dWRsdHRoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjM1NzMyNTcsImV4cCI6MjAzOTE0OTI1N30.zHIM5iEITnzAzED7neVkMJR7VAHIlSpR_ipNLSPhH_U",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdzd2h5bnVhYmRzcG53dWRsdHRoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjM1NzMyNTcsImV4cCI6MjAzOTE0OTI1N30.zHIM5iEITnzAzED7neVkMJR7VAHIlSpR_ipNLSPhH_U",
    "Content-Type": "application/json",
    "Prefer": "return=representation"
}
# Try to simulate _sendMessage
payload = {
    "group_id": 16, # assuming a group id exists, we need to try finding one. Let's fetch one first.
    "sender_id": "c76ecea0-12ab-469b-bbb9-328afc2f829f", # wait, we need an auth user. 
    # let's just do a dummy request without valid FK to see if it complains about FK
    "message_text": "hello test",
    "message_type": "text",
    "gallery_id": "123" # TRY STRING
}

# 1. get a valid group id and user id from group_messages
url1 = "https://gswhynuabdspnwudltth.supabase.co/rest/v1/group_messages?select=group_id,sender_id&limit=1"
req1 = urllib.request.Request(url1, headers=headers)
with urllib.request.urlopen(req1) as response:
    data = json.loads(response.read().decode('utf-8'))
    if data:
        payload["group_id"] = data[0]["group_id"]
        payload["sender_id"] = data[0]["sender_id"]

url_insert = "https://gswhynuabdspnwudltth.supabase.co/rest/v1/group_messages?select=*,reply_to:reply_to_message_id(*),sender:users!sender_id(profile:profile!user_id(*)),gallery:gallery_id(*,user:users!user_id(profile:profile!user_id(*))),thought:thought_id(*,user:users!user_id(profile:profile!user_id(*)))"

print("Trying insert with payload:", payload)
req_insert = urllib.request.Request(url_insert, data=json.dumps(payload).encode('utf-8'), headers=headers, method="POST")

try:
    with urllib.request.urlopen(req_insert) as response:
        print("Success:", response.read().decode('utf-8'))
except urllib.error.HTTPError as e:
    print("Error:", e.read().decode('utf-8'))
