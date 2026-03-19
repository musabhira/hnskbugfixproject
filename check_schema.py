import urllib.request
import json

url1 = "https://gswhynuabdspnwudltth.supabase.co/rest/v1/group_messages?select=*&limit=1"
url2 = "https://gswhynuabdspnwudltth.supabase.co/rest/v1/messages?select=*&limit=1"
headers = {
    "apikey": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdzd2h5bnVhYmRzcG53dWRsdHRoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjM1NzMyNTcsImV4cCI6MjAzOTE0OTI1N30.zHIM5iEITnzAzED7neVkMJR7VAHIlSpR_ipNLSPhH_U",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdzd2h5bnVhYmRzcG53dWRsdHRoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjM1NzMyNTcsImV4cCI6MjAzOTE0OTI1N30.zHIM5iEITnzAzED7neVkMJR7VAHIlSpR_ipNLSPhH_U"
}

with open("schema_dump.txt", "w") as f:
    req1 = urllib.request.Request(url1, headers=headers)
    with urllib.request.urlopen(req1) as response:
        data1 = json.loads(response.read().decode('utf-8'))
        f.write(f"Group Messages keys: {list(data1[0].keys()) if data1 else []}\n")

    req2 = urllib.request.Request(url2, headers=headers)
    with urllib.request.urlopen(req2) as response:
        data2 = json.loads(response.read().decode('utf-8'))
        f.write(f"Messages keys: {list(data2[0].keys()) if data2 else []}\n")
