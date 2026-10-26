const BASE = "/api";

export interface AuthState {
  token: string | null;
  refreshToken: string | null;
  id: number | null;
  email: string | null;
  role: string | null;
  name: string | null;
  code: string | null;
  mustChangePassword?: boolean;
}

export function getStoredAuth(): AuthState | null {
  const s = localStorage.getItem("auth");
  if (!s) return null;
  try {
    return JSON.parse(s);
  } catch {
    return null;
  }
}

export function saveAuth(a: AuthState) {
  localStorage.setItem("auth", JSON.stringify(a));
}

export function clearAuth() {
  localStorage.removeItem("auth");
}

export async function apiReq<T = any>(url: string, opts: RequestInit = {}): Promise<T> {
  const auth = getStoredAuth();
  const headers = new Headers(opts.headers || {});
  if (!headers.has("Content-Type") && !(opts.body instanceof FormData)) {
    headers.set("Content-Type", "application/json");
  }
  if (auth?.token) {
    headers.set("Authorization", `Bearer ${auth.token}`);
  }

  const res = await fetch(`${BASE}${url}`, { ...opts, headers });
  if (res.status === 401) {
    clearAuth();
    if (!window.location.pathname.includes("/login")) {
      window.location.href = "/admin/login";
    }
    throw new Error("Session expired. Please log in again.");
  }

  if (!res.ok) {
    let msg = `Request failed (${res.status})`;
    try {
      const err = await res.json();
      msg = err.message || err.error || msg;
    } catch {
      // Ignore text
    }
    throw new Error(msg);
  }

  if (res.headers.get("content-type")?.includes("application/json")) {
    return res.json();
  }
  return res.text() as any;
}

export async function downloadBlob(url: string, filename: string): Promise<void> {
  const auth = getStoredAuth();
  const headers = new Headers();
  if (auth?.token) {
    headers.set("Authorization", `Bearer ${auth.token}`);
  }
  const res = await fetch(`${BASE}${url}`, { headers });
  if (!res.ok) throw new Error(`Download failed with status ${res.status}`);
  const blob = await res.blob();
  const link = document.createElement("a");
  link.href = window.URL.createObjectURL(blob);
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  window.URL.revokeObjectURL(link.href);
}

export const api = {
  // Auth
  loginAdmin: (req: any) => apiReq("/auth/login/admin", { method: "POST", body: JSON.stringify(req) }),
  loginFaculty: (req: any) => apiReq("/auth/login/faculty", { method: "POST", body: JSON.stringify(req) }),
  loginStudent: (req: any) => apiReq("/auth/login/student", { method: "POST", body: JSON.stringify(req) }),
  setInitialPassword: (newPassword: string) => apiReq("/auth/set-initial-password", { method: "POST", body: JSON.stringify({ newPassword }) }),
  changePassword: (req: any) => apiReq("/auth/change-password", { method: "POST", body: JSON.stringify(req) }),
  forgotRequest: (identifier: string) => apiReq("/auth/forgot-password/request", { method: "POST", body: JSON.stringify({ identifier }) }),
  forgotReset: (req: any) => apiReq("/auth/forgot-password/reset", { method: "POST", body: JSON.stringify(req) }),
  getMe: () => apiReq("/auth/me"),

  // Admin APIs
  admin: {
    getDashboard: () => apiReq("/admin/dashboard"),
    getStudents: (params?: any) => {
      const qs = new URLSearchParams(params).toString();
      return apiReq(`/admin/students?${qs}`);
    },
    getStudentDetail: (id: number) => apiReq(`/admin/students/${id}`),
    createStudent: (data: any) => apiReq("/admin/students", { method: "POST", body: JSON.stringify(data) }),
    revealAadhaar: (id: number) => apiReq(`/admin/students/${id}/reveal-aadhaar`, { method: "POST" }),
    getFaculty: () => apiReq("/admin/faculty"),
    createFaculty: (data: any) => apiReq("/admin/faculty", { method: "POST", body: JSON.stringify(data) }),
    getPayrollRuns: () => apiReq("/admin/payroll/runs"),
    generatePayroll: (monthYear?: string) => apiReq("/admin/payroll/generate", { method: "POST", body: JSON.stringify({ monthYear }) }),
    markPayrollPaid: (id: number) => apiReq(`/admin/payroll/runs/${id}/mark-paid`, { method: "POST" }),
    getDepartments: () => apiReq("/admin/departments"),
    getProgrammes: () => apiReq("/admin/programmes"),
    getCourses: () => apiReq("/admin/courses"),
    createCourse: (data: any) => apiReq("/admin/courses", { method: "POST", body: JSON.stringify(data) }),
    getTimetable: (secId: number) => apiReq(`/admin/timetable/${secId}`),
    createTimetableSlot: (data: any) => apiReq("/admin/timetable/slot", { method: "POST", body: JSON.stringify(data) }),
    getArrears: () => apiReq("/admin/arrears"),
    getAnnouncements: () => apiReq("/admin/announcements"),
    createAnnouncement: (data: any) => apiReq("/admin/announcements", { method: "POST", body: JSON.stringify(data) }),
    getAuditLogs: () => apiReq("/admin/logs/audit"),
    getLoginLogs: () => apiReq("/admin/logs/login"),
    getBlockedAccounts: () => apiReq("/admin/logs/blocked"),
    getCommunicationLogs: () => apiReq("/admin/logs/communication"),
    toggleBlockUser: (userId: number, reason?: string) => apiReq(`/admin/users/${userId}/toggle-block`, { method: "POST", body: JSON.stringify({ reason }) }),
  },

  // Faculty APIs
  faculty: {
    getDashboard: () => apiReq("/faculty/dashboard"),
    getCourses: () => apiReq("/faculty/courses"),
    getCourseStudents: (offeringId: number) => apiReq(`/faculty/courses/${offeringId}/students`),
    markAttendance: (data: any) => apiReq("/faculty/attendance/mark", { method: "POST", body: JSON.stringify(data) }),
    getTimetable: () => apiReq("/faculty/timetable"),
    getPayslips: () => apiReq("/faculty/payslips"),
  },

  // Student APIs
  student: {
    getDashboard: () => apiReq("/student/dashboard"),
    getAttendance: () => apiReq("/student/attendance"),
    getResults: () => apiReq("/student/results"),
    getFees: () => apiReq("/student/fees"),
    getArrears: () => apiReq("/student/arrears"),
    registerReExam: (arrearId: number) => apiReq(`/student/arrears/${arrearId}/register-reexam`, { method: "POST" }),
  },
};
