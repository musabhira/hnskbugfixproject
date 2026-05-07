import urllib.request
import json

url = "https://gswhynuabdspnwudltth.supabase.co/rest/v1/"
headers = {
    "apikey": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdzd2h5bnVhYmRzcG53dWRsdHRoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjM1NzMyNTcsImV4cCI6MjAzOTE0OTI1N30.zHIM5iEITnzAzED7neVkMJR7VAHIlSpR_ipNLSPhH_U",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdzd2h5bnVhYmRzcG53dWRsdHRoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjM1NzMyNTcsImV4cCI6MjAzOTE0OTI1N30.zHIM5iEITnzAzED7neVkMJR7VAHIlSpR_ipNLSPhH_U"
}

try:
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode('utf-8'))
        with open("supabase_schema_rest.json", "w") as f:
            json.dump(data, f, indent=2)
    print("Schema fetched successfully and saved to supabase_schema_rest.json")
except Exception as e:
    print(f"Error: {e}")
