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

let refreshPromise: Promise<string | null> | null = null;

async function refreshAccessToken(): Promise<string | null> {
  const auth = getStoredAuth();
  if (!auth?.refreshToken) return null;

  try {
    const res = await fetch(`${BASE}/auth/refresh`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refreshToken: auth.refreshToken }),
    });
    if (!res.ok) return null;
    const data = await res.json();
    if (data?.token) {
      const updated: AuthState = {
        ...auth,
        token: data.token,
        refreshToken: data.refreshToken || auth.refreshToken,
      };
      saveAuth(updated);
      return data.token;
    }
  } catch {
    return null;
  }
  return null;
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

  let res = await fetch(`${BASE}${url}`, { ...opts, headers });

  // If 401 on non-auth endpoint, attempt token refresh once
  if (res.status === 401 && !url.startsWith("/auth/")) {
    if (!refreshPromise) {
      refreshPromise = refreshAccessToken().finally(() => {
        refreshPromise = null;
      });
    }
    const newToken = await refreshPromise;
    if (newToken) {
      headers.set("Authorization", `Bearer ${newToken}`);
      res = await fetch(`${BASE}${url}`, { ...opts, headers });
    }
  }

  if (res.status === 401) {
    const role = auth?.role?.toLowerCase();
    clearAuth();
    if (!window.location.pathname.includes("/login")) {
      if (role === "owner" || role === "super_admin") window.location.href = "/owner/login";
      else if (role === "student") window.location.href = "/student/login";
      else if (role === "faculty") window.location.href = "/faculty/login";
      else window.location.href = "/admin/login";
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
  try {
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
  } catch (err: any) {
    console.error("Download error:", err);
    alert("Download failed: " + (err.message || "Server error"));
  }
}

export const api = {
  // Auth
  loginOwner: (req: any) => apiReq("/auth/login/owner", { method: "POST", body: JSON.stringify(req) }),
  loginAdmin: (req: any) => apiReq("/auth/login/admin", { method: "POST", body: JSON.stringify(req) }),
  loginFaculty: (req: any) => apiReq("/auth/login/faculty", { method: "POST", body: JSON.stringify(req) }),
  loginStudent: (req: any) => apiReq("/auth/login/student", { method: "POST", body: JSON.stringify(req) }),
  setInitialPassword: (newPassword: string) => apiReq("/auth/set-initial-password", { method: "POST", body: JSON.stringify({ newPassword }) }),
  changePassword: (req: any) => apiReq("/auth/change-password", { method: "POST", body: JSON.stringify(req) }),
  forgotRequest: (identifier: string) => apiReq("/auth/forgot-password/request", { method: "POST", body: JSON.stringify({ identifier }) }),
  forgotReset: (req: any) => apiReq("/auth/forgot-password/reset", { method: "POST", body: JSON.stringify(req) }),
  getMe: () => apiReq("/auth/me"),
  logout: () => apiReq("/auth/logout", { method: "POST" }),
  refresh: (refreshToken: string) => apiReq("/auth/refresh", { method: "POST", body: JSON.stringify({ refreshToken }) }),

  // Notifications (all roles)
  notifications: {
    getMyNotifications: () => apiReq("/notifications"),
    markRead: (id: number) => apiReq(`/notifications/${id}/mark-read`, { method: "POST" }),
    markAllRead: () => apiReq("/notifications/mark-all-read", { method: "POST" }),
  },

  // Owner APIs
  owner: {
    getOverview: () => apiReq("/owner/overview"),
    getHistoricalAnalytics: (year?: number) => apiReq(`/owner/historical-analytics${year ? `?year=${year}` : ""}`),
    getDepartments: () => apiReq("/owner/departments"),
    getAdmins: () => apiReq("/owner/admins"),
    createAdmin: (req: any) => apiReq("/owner/admins", { method: "POST", body: JSON.stringify(req) }),
    getFinancialSummary: () => apiReq("/owner/financial-summary"),
    getAuditLogs: (limit?: number) => apiReq(`/owner/audit-logs${limit ? `?limit=${limit}` : ""}`),
  },

  // Admin APIs
  admin: {
    getDashboard: () => apiReq("/admin/dashboard"),
    getStudents: (params?: any) => {
      if (!params) return apiReq("/admin/students");
      const cleanParams: any = {};
      Object.keys(params).forEach((k) => {
        if (params[k] !== undefined && params[k] !== null && params[k] !== "") {
          cleanParams[k] = String(params[k]);
        }
      });
      const qs = new URLSearchParams(cleanParams).toString();
      return apiReq(`/admin/students${qs ? `?${qs}` : ""}`);
    },
    getStudentDetail: (id: number) => apiReq(`/admin/students/${id}`),
    createStudent: (data: any) => apiReq("/admin/students", { method: "POST", body: JSON.stringify(data) }),
    updateStudent: (id: number, data: any) => apiReq(`/admin/students/${id}`, { method: "PUT", body: JSON.stringify(data) }),
    deleteStudent: (id: number) => apiReq(`/admin/students/${id}`, { method: "DELETE" }),
    revealAadhaar: (id: number) => apiReq(`/admin/students/${id}/reveal-aadhaar`, { method: "POST" }),
    getFaculty: () => apiReq("/admin/faculty"),
    createFaculty: (data: any) => apiReq("/admin/faculty", { method: "POST", body: JSON.stringify(data) }),
    updateFaculty: (id: number, data: any) => apiReq(`/admin/faculty/${id}`, { method: "PUT", body: JSON.stringify(data) }),
    getPayrollRuns: () => apiReq("/admin/payroll/runs"),
    generatePayroll: (monthYear?: string) => apiReq("/admin/payroll/generate", { method: "POST", body: JSON.stringify({ monthYear }) }),
    markPayrollPaid: (id: number) => apiReq(`/admin/payroll/runs/${id}/mark-paid`, { method: "POST" }),
    getDepartments: () => apiReq("/admin/departments"),
    getProgrammes: () => apiReq("/admin/programmes"),
    getCourses: () => apiReq("/admin/courses"),
    createCourse: (data: any) => apiReq("/admin/courses", { method: "POST", body: JSON.stringify(data) }),
    getSections: () => apiReq("/admin/sections"),
    getTimetable: (secId: number) => apiReq(`/admin/timetable/${secId}`),
    createTimetableSlot: (data: any) => apiReq("/admin/timetable/slot", { method: "POST", body: JSON.stringify(data) }),
    getAssignments: () => apiReq("/admin/assignments"),
    recordFeePayment: (data: any) => apiReq("/admin/fees/payments", { method: "POST", body: JSON.stringify(data) }),
    getArrears: () => apiReq("/admin/arrears"),
    getAnnouncements: () => apiReq("/admin/announcements"),
    createAnnouncement: (data: any) => apiReq("/admin/announcements", { method: "POST", body: JSON.stringify(data) }),
    getAuditLogs: () => apiReq("/admin/logs/audit"),
    getLoginLogs: () => apiReq("/admin/logs/login"),
    getBlockedAccounts: () => apiReq("/admin/logs/blocked"),
    getCommunicationLogs: () => apiReq("/admin/logs/communication"),
    toggleBlockUser: (userId: number, reason?: string) => apiReq(`/admin/users/${userId}/toggle-block`, { method: "POST", body: JSON.stringify({ reason }) }),
    search: (q: string) => apiReq(`/admin/search?q=${encodeURIComponent(q)}`),
    getReportsSummary: () => apiReq("/admin/reports/summary"),
  },

  // Faculty APIs
  faculty: {
    getDashboard: () => apiReq("/faculty/dashboard"),
    getCourses: () => apiReq("/faculty/courses"),
    getCourseStudents: (offeringId: number) => apiReq(`/faculty/courses/${offeringId}/students`),
    markAttendance: (data: any) => apiReq("/faculty/attendance/mark", { method: "POST", body: JSON.stringify(data) }),
    getTimetable: () => apiReq("/faculty/timetable"),
    getPayslips: () => apiReq("/faculty/payslips"),
    getAssignments: () => apiReq("/faculty/assignments"),
    createAssignment: (data: any) => apiReq("/faculty/assignments", { method: "POST", body: JSON.stringify(data) }),
    getSubmissions: (assignmentId: number) => apiReq(`/faculty/assignments/${assignmentId}/submissions`),
    gradeSubmission: (subId: number, data: any) => apiReq(`/faculty/assignments/submissions/${subId}/grade`, { method: "POST", body: JSON.stringify(data) }),
    getCourseMarks: (offeringId: number) => apiReq(`/faculty/courses/${offeringId}/marks`),
    saveCourseMarks: (offeringId: number, data: any) => apiReq(`/faculty/courses/${offeringId}/marks`, { method: "POST", body: JSON.stringify(data) }),
  },

  // Student APIs
  student: {
    getDashboard: () => apiReq("/student/dashboard"),
    getAttendance: () => apiReq("/student/attendance"),
    getResults: () => apiReq("/student/results"),
    getFees: () => apiReq("/student/fees"),
    getArrears: () => apiReq("/student/arrears"),
    registerReExam: (arrearId: number) => apiReq(`/student/arrears/${arrearId}/register-reexam`, { method: "POST" }),
    getAssignments: () => apiReq("/student/assignments"),
    submitAssignment: (assignmentId: number, data: any) => apiReq(`/student/assignments/${assignmentId}/submit`, { method: "POST", body: JSON.stringify(data) }),
    getTimetable: () => apiReq("/student/timetable"),
    updateProfile: (data: any) => apiReq("/student/profile", { method: "PUT", body: JSON.stringify(data) }),
  },
};
