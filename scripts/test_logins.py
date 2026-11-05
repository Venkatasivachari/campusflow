import urllib.request
import json

def test_login(name, path, user, pwd):
    url = f"http://localhost:3000/api/auth/{path}"
    data = json.dumps({"identifier": user, "password": pwd}).encode("utf-8")
    req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req) as resp:
            body = json.loads(resp.read().decode("utf-8"))
            print(f"[SUCCESS] {name} -> Role: {body.get('role')}, Name: {body.get('name')}, Code: {body.get('code')}")
            return body.get("token")
    except Exception as e:
        print(f"[FAILED]  {name} -> Error: {e}")
        return None

print("=== TESTING ALL 4 PORTAL LOGIN WORKFLOWS ===")
token_owner = test_login("Root Owner (Email)", "login/owner", "owner@college.local", "Owner@12345")
token_owner_code = test_login("Root Owner (Code)", "login/owner", "OWN0001", "Owner@12345")
token_admin = test_login("Administration (Email)", "login/admin", "admin@college.local", "Admin@12345")
token_faculty = test_login("Faculty (Email)", "login/faculty", "teacher1@college.local", "Demo@12345")
token_faculty_code = test_login("Faculty (Employee ID)", "login/faculty", "FAC25001", "Demo@12345")
token_student_reg = test_login("Student (Reg Number)", "login/student", "25CSE0001", "Demo@12345")

if token_owner:
    print("\n=== TESTING ROOT OWNER SECURED APIS ===")
    req = urllib.request.Request("http://localhost:3000/api/owner/overview", headers={"Authorization": f"Bearer {token_owner}"})
    with urllib.request.urlopen(req) as resp:
        ov = json.loads(resp.read().decode("utf-8"))
        print(f"Overview KPIs: {ov.get('kpis')}")
        print(f"Year Strength: {ov.get('yearStrength')}")
        print(f"Gender Breakdown: {ov.get('gender')}")

    req2 = urllib.request.Request("http://localhost:3000/api/owner/historical-analytics", headers={"Authorization": f"Bearer {token_owner}"})
    with urllib.request.urlopen(req2) as resp:
        ha = json.loads(resp.read().decode("utf-8"))
        print(f"Historical Analytics Cohorts count: {len(ha)}")
