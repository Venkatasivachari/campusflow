import urllib.request
import json

def test_login(endpoint, identifier, password):
    url = f"http://localhost:8080/api/auth/{endpoint}"
    data = json.dumps({"identifier": identifier, "password": password}).encode("utf-8")
    req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req) as resp:
            body = json.loads(resp.read().decode("utf-8"))
            role = body.get("role")
            name = body.get("name")
            token = body.get("token") or body.get("accessToken", "")
            print(f"SUCCESS: {endpoint} | {identifier} | {password} -> {role} ({name}) token_len={len(token)}")
            return token
    except urllib.error.HTTPError as e:
        err = e.read().decode("utf-8")
        print(f"FAILED {e.code}: {endpoint} | {identifier} | {password} -> {err}")
        return None

def test_protected(token, path):
    url = f"http://localhost:8080/api{path}"
    req = urllib.request.Request(url, headers={"Authorization": f"Bearer {token}"})
    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            total = data.get("total") if isinstance(data, dict) else len(data)
            print(f"SUCCESS PROTECTED: {path} -> total/size: {total}")
    except Exception as e:
        print(f"FAILED PROTECTED: {path} -> {e}")

print("--- TESTING LOGINS ---")
t_owner1 = test_login("login/owner", "owner@college.local", "Owner@12345")
t_owner2 = test_login("login/owner", "owner@college.local", "Demo@12345")
t_owner3 = test_login("login/owner", "OWN0001", "Owner@12345")
t_admin1 = test_login("login/admin", "admin@college.local", "Admin@12345")
t_admin2 = test_login("login/admin", "admin@college.local", "Demo@12345")

print("\n--- TESTING PROTECTED ROUTES ---")
if t_owner1:
    test_protected(t_owner1, "/owner/overview")
if t_admin1:
    test_protected(t_admin1, "/admin/dashboard")
    test_protected(t_admin1, "/admin/students?page=1&size=5")
    test_protected(t_admin1, "/admin/students?yearOfStudy=1&size=5")
    test_protected(t_admin1, "/admin/students?gender=FEMALE&size=5")
    test_protected(t_admin1, "/admin/students?minCgpa=9.0&size=5")
    test_protected(t_admin1, "/admin/students?search=Sofiur&size=5")
