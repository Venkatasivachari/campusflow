import urllib.request
import json

def test_deletion_and_audit():
    # 1. Login as Admin
    login_req = urllib.request.Request(
        "http://localhost:3000/api/auth/login/admin",
        data=json.dumps({"identifier": "admin@college.local", "password": "Admin@12345"}).encode("utf-8"),
        headers={"Content-Type": "application/json"}
    )
    with urllib.request.urlopen(login_req) as resp:
        login_res = json.loads(resp.read().decode("utf-8"))
        token = login_res["token"]
        print("[1] Admin Login: SUCCESS! Token acquired.")

    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

    # 2. Fetch student with ID 9000
    st_req = urllib.request.Request("http://localhost:3000/api/admin/students?search=9000", headers=headers)
    with urllib.request.urlopen(st_req) as resp:
        st_data = json.loads(resp.read().decode("utf-8"))
        print(f"[2] Found active student 9000: Total matches = {st_data.get('totalCount')}")

    # 3. Perform Deletion
    del_req = urllib.request.Request("http://localhost:3000/api/admin/students/9000", headers=headers, method="DELETE")
    with urllib.request.urlopen(del_req) as resp:
        del_res = json.loads(resp.read().decode("utf-8"))
        print(f"[3] Student 9000 Deletion Response: {del_res}")

    # 4. Login as Owner to inspect real-time audit logs
    owner_login = urllib.request.Request(
        "http://localhost:3000/api/auth/login/owner",
        data=json.dumps({"identifier": "owner@college.local", "password": "Owner@12345"}).encode("utf-8"),
        headers={"Content-Type": "application/json"}
    )
    with urllib.request.urlopen(owner_login) as resp:
        owner_token = json.loads(resp.read().decode("utf-8"))["token"]

    log_req = urllib.request.Request("http://localhost:3000/api/owner/audit-logs?limit=5", headers={"Authorization": f"Bearer {owner_token}"})
    with urllib.request.urlopen(log_req) as resp:
        logs = json.loads(resp.read().decode("utf-8"))
        print("\n[4] Real-Time Database Audit Logs:")
        for l in logs:
            print(f"    - Action: {l.get('action')} | Entity: {l.get('entity_name')} (ID: {l.get('entity_id')}) | Details: {l.get('details')} | Actor: {l.get('actor_email')}")

if __name__ == "__main__":
    test_deletion_and_audit()
