import React, { useState, useEffect } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import {
  LayoutDashboard, Users, UserCheck, BookOpen, Calendar, DollarSign,
  AlertTriangle, Bell, FileText, Settings, ShieldAlert, Plus, Eye,
  CheckCircle, ArrowUpRight, Search, Download, Lock, Unlock, ChevronRight,
  LogOut, Menu, X
} from "lucide-react";
import { ResponsiveContainer, BarChart, Bar, XAxis, YAxis, Tooltip } from "recharts";
import { api, clearAuth } from "./api";
import { StatCard, SkeletonCard, SkeletonTable, Badge, Toast } from "./ui";

export function AdminPortal() {
  const navigate = useNavigate();
  const location = useLocation();

  // Extract active tab from URL path (e.g. /admin/students -> "students")
  const pathSegments = location.pathname.split("/").filter(Boolean);
  const tab = pathSegments[1] || "dashboard";

  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [toast, setToast] = useState<{ msg: string; type: "success" | "error" | "info" } | null>(null);
  const [mobileOpen, setMobileOpen] = useState(false);

  // Modals state
  const [studentModal, setStudentModal] = useState(false);
  const [facultyModal, setFacultyModal] = useState(false);
  const [courseModal, setCourseModal] = useState(false);
  const [announcementModal, setAnnouncementModal] = useState(false);
  const [studentDetail, setStudentDetail] = useState<any>(null);

  // Student form state
  const [newStudent, setNewStudent] = useState({
    fullName: "",
    personalEmail: "",
    phone: "",
    dob: "2005-01-15",
    gender: "MALE",
    aadhaar: "",
    abcId: "",
    departmentId: 1,
    programmeId: 1,
    fatherName: "",
    parentPhone: ""
  });

  // Faculty form state
  const [newFaculty, setNewFaculty] = useState({
    fullName: "",
    email: "",
    phone: "",
    departmentId: 1,
    designationId: 1,
    qualification: "Ph.D in Computer Science",
    experienceYears: 5,
    basicPay: 75000
  });

  // Course form state
  const [newCourse, setNewCourse] = useState({
    code: "",
    name: "",
    credits: 4,
    departmentId: 1,
    courseType: "CORE"
  });

  // Announcement form state
  const [newAnn, setNewAnn] = useState({
    title: "",
    content: "",
    priority: "NORMAL",
    targetType: "ALL"
  });

  useEffect(() => {
    loadTab(tab);
  }, [tab]);

  async function loadTab(t: string) {
    setLoading(true);
    try {
      if (t === "dashboard") {
        const res = await api.admin.getDashboard();
        setData(res);
      } else if (t === "students") {
        const res = await api.admin.getStudents();
        setData(res);
      } else if (t === "faculty") {
        const res = await api.admin.getFaculty();
        setData(res);
      } else if (t === "payroll") {
        const res = await api.admin.getPayrollRuns();
        setData(res);
      } else if (t === "academics") {
        const [depts, progs, courses] = await Promise.all([
          api.admin.getDepartments(),
          api.admin.getProgrammes(),
          api.admin.getCourses()
        ]);
        setData({ depts, progs, courses });
      } else if (t === "arrears") {
        const res = await api.admin.getArrears();
        setData(res);
      } else if (t === "announcements") {
        const res = await api.admin.getAnnouncements();
        setData(res);
      } else if (t === "logs") {
        const [audit, login, blocked, comms] = await Promise.all([
          api.admin.getAuditLogs(),
          api.admin.getLoginLogs(),
          api.admin.getBlockedAccounts(),
          api.admin.getCommunicationLogs()
        ]);
        setData({ audit, login, blocked, comms, subtab: "audit" });
      }
    } catch (e: any) {
      setToast({ msg: e.message || "Failed to load data", type: "error" });
    } finally {
      setLoading(false);
    }
  }

  async function handleCreateStudent(e: React.FormEvent) {
    e.preventDefault();
    try {
      await api.admin.createStudent(newStudent);
      setToast({ msg: "Student enrolled successfully.", type: "success" });
      setStudentModal(false);
      setNewStudent({
        fullName: "",
        personalEmail: "",
        phone: "",
        dob: "2005-01-15",
        gender: "MALE",
        aadhaar: "",
        abcId: "",
        departmentId: 1,
        programmeId: 1,
        fatherName: "",
        parentPhone: ""
      });
      loadTab("students");
    } catch (err: any) {
      setToast({ msg: err.message || "Failed to create student.", type: "error" });
    }
  }

  async function handleCreateFaculty(e: React.FormEvent) {
    e.preventDefault();
    try {
      await api.admin.createFaculty(newFaculty);
      setToast({ msg: "Faculty member added successfully.", type: "success" });
      setFacultyModal(false);
      setNewFaculty({
        fullName: "",
        email: "",
        phone: "",
        departmentId: 1,
        designationId: 1,
        qualification: "Ph.D in Computer Science",
        experienceYears: 5,
        basicPay: 75000
      });
      loadTab("faculty");
    } catch (err: any) {
      setToast({ msg: err.message || "Failed to add faculty.", type: "error" });
    }
  }

  async function handleCreateCourse(e: React.FormEvent) {
    e.preventDefault();
    try {
      await api.admin.createCourse(newCourse);
      setToast({ msg: "Course created successfully.", type: "success" });
      setCourseModal(false);
      setNewCourse({ code: "", name: "", credits: 4, departmentId: 1, courseType: "CORE" });
      loadTab("academics");
    } catch (err: any) {
      setToast({ msg: err.message || "Failed to create course.", type: "error" });
    }
  }

  async function handleCreateAnnouncement(e: React.FormEvent) {
    e.preventDefault();
    try {
      await api.admin.createAnnouncement(newAnn);
      setToast({ msg: "Announcement published successfully.", type: "success" });
      setAnnouncementModal(false);
      setNewAnn({ title: "", content: "", priority: "NORMAL", targetType: "ALL" });
      loadTab("announcements");
    } catch (err: any) {
      setToast({ msg: err.message || "Failed to publish announcement.", type: "error" });
    }
  }

  const navItems = [
    { id: "dashboard", label: "Dashboard", icon: LayoutDashboard },
    { id: "students", label: "Students", icon: Users },
    { id: "faculty", label: "Faculty", icon: UserCheck },
    { id: "payroll", label: "Payroll & Salary", icon: DollarSign },
    { id: "academics", label: "Academics", icon: BookOpen },
    { id: "arrears", label: "Arrear Registry", icon: AlertTriangle },
    { id: "announcements", label: "Announcements", icon: Bell },
    { id: "logs", label: "Logs & Registers", icon: ShieldAlert },
  ];

  return (
    <div className="flex h-screen overflow-hidden bg-[#F6F7FB] dark:bg-[#0B1020]">
      {/* Mobile Sidebar Overlay */}
      {mobileOpen && (
        <div
          onClick={() => setMobileOpen(false)}
          className="fixed inset-0 z-40 bg-black/50 md:hidden backdrop-blur-sm"
        />
      )}

      {/* Sidebar Navigation */}
      <aside className={`
        fixed md:static inset-y-0 left-0 z-50 w-64 bg-white dark:bg-[#11162A] border-r border-[#E5E8F0] dark:border-[#1F293D] flex flex-col justify-between shrink-0 transition-transform duration-300
        ${mobileOpen ? "translate-x-0 shadow-2xl" : "-translate-x-full md:translate-x-0"}
      `}>
        <div>
          <div className="p-5 border-b border-[#E5E8F0] dark:border-[#1F293D] flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-xl bg-indigo-600 flex items-center justify-center text-white font-bold shadow-md shadow-indigo-500/20">
                IIT
              </div>
              <div>
                <span className="font-bold text-sm text-[#0B1020] dark:text-white font-heading">Imperial Admin</span>
                <span className="block text-[10px] text-[#64708A] font-mono">PORTAL V2</span>
              </div>
            </div>
            <button onClick={() => setMobileOpen(false)} className="md:hidden text-slate-400 hover:text-slate-600">
              <X className="w-5 h-5" />
            </button>
          </div>

          <nav className="p-3 space-y-1">
            {navItems.map((item) => {
              const Icon = item.icon;
              const active = tab === item.id;
              return (
                <button
                  key={item.id}
                  onClick={() => {
                    navigate(`/admin/${item.id}`);
                    setMobileOpen(false);
                  }}
                  className={`w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-xs font-semibold transition ${
                    active
                      ? "bg-indigo-600 text-white shadow-sm shadow-indigo-600/30"
                      : "text-[#64708A] hover:bg-slate-100 dark:hover:bg-slate-800/60 hover:text-[#0B1020] dark:hover:text-white"
                  }`}
                >
                  <Icon className="w-4 h-4" />
                  <span>{item.label}</span>
                </button>
              );
            })}
          </nav>
        </div>

        <div className="p-4 border-t border-[#E5E8F0] dark:border-[#1F293D] space-y-3">
          <div className="flex items-center justify-between text-xs text-[#64708A]">
            <span>System Status</span>
            <span className="flex items-center gap-1.5 font-semibold text-emerald-600 dark:text-emerald-400">
              <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" /> MySQL Live
            </span>
          </div>
          <button
            onClick={() => {
              clearAuth();
              window.location.href = "/admin/login";
            }}
            className="w-full flex items-center justify-center gap-2 py-2 px-3 rounded-xl text-xs font-semibold text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/40 border border-rose-200 dark:border-rose-900 transition"
          >
            <LogOut className="w-3.5 h-3.5" /> Sign Out
          </button>
        </div>
      </aside>

      {/* Main Content View */}
      <main className="flex-1 overflow-y-auto">
        {/* Top Header */}
        <header className="sticky top-0 z-20 bg-white/80 dark:bg-[#11162A]/80 backdrop-blur border-b border-[#E5E8F0] dark:border-[#1F293D] px-4 md:px-8 py-3.5 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <button
              onClick={() => setMobileOpen(true)}
              className="md:hidden p-2 rounded-lg border border-[#E5E8F0] dark:border-[#1F293D] text-[#0B1020] dark:text-white"
            >
              <Menu className="w-5 h-5" />
            </button>
            <h1 className="text-lg font-bold text-[#0B1020] dark:text-white capitalize">{tab} Management</h1>
          </div>
          <div className="flex items-center gap-3">
            <span className="text-xs px-2.5 py-1 rounded-full bg-indigo-50 dark:bg-indigo-950 text-indigo-700 dark:text-indigo-300 font-mono font-semibold">
              ROLE_SUPER_ADMIN
            </span>
            <button
              onClick={() => {
                clearAuth();
                window.location.href = "/admin/login";
              }}
              className="hidden md:flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/40 border border-rose-200 dark:border-rose-900 transition"
            >
              <LogOut className="w-3.5 h-3.5" /> Sign Out
            </button>
          </div>
        </header>

        {/* Viewport Container */}
        <div className="p-4 md:p-8 max-w-7xl mx-auto space-y-6">
          {loading ? (
            <div className="space-y-4">
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <SkeletonCard /><SkeletonCard /><SkeletonCard /><SkeletonCard />
              </div>
              <SkeletonTable rows={6} />
            </div>
          ) : (
            <>
              {/* 5.1 DASHBOARD TAB */}
              {tab === "dashboard" && data && (
                <div className="space-y-6">
                  <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
                    <StatCard title="Total Students" value={data.cards?.totalStudents || 0} subtitle="Active degree candidates" icon={Users} color="indigo" />
                    <StatCard title="Total Faculty" value={data.cards?.totalFaculty || 0} subtitle="Teaching & academic staff" icon={UserCheck} color="teal" />
                    <StatCard title="Active Courses" value={data.cards?.activeCourses || 0} subtitle="Current semester offerings" icon={BookOpen} color="violet" />
                    <StatCard title="Today's Attendance" value={`${data.cards?.todayAttendance || 0}%`} subtitle="Institutional campus average" icon={Calendar} color="emerald" />
                    <StatCard title="Fee Collected" value={`INR ${Number(data.cards?.feeCollected || 0).toLocaleString()}`} icon={DollarSign} color="emerald" />
                    <StatCard title="Fee Pending" value={`INR ${Number(data.cards?.feePending || 0).toLocaleString()}`} icon={AlertTriangle} color="rose" />
                    <StatCard title="Open Arrears" value={data.cards?.openArrears || 0} subtitle="Pending re-examinations" icon={AlertTriangle} color="amber" />
                    <StatCard title="Blocked Accounts" value={data.cards?.blockedAccounts || 0} subtitle="Security lockouts" icon={ShieldAlert} color="rose" />
                  </div>

                  <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    <div className="card p-6">
                      <h3 className="text-sm font-bold text-[#0B1020] dark:text-white mb-4">Department Enrollment Strength</h3>
                      <div className="h-64">
                        <ResponsiveContainer width="100%" height="100%">
                          <BarChart data={data.charts?.deptStrength || []}>
                            <XAxis dataKey="code" stroke="#888888" fontSize={11} />
                            <YAxis stroke="#888888" fontSize={11} />
                            <Tooltip contentStyle={{ backgroundColor: "#11162A", border: "1px solid #1F293D", borderRadius: 8, color: "#fff", fontSize: 12 }} />
                            <Bar dataKey="students" fill="#4F46E5" radius={[6, 6, 0, 0]} />
                          </BarChart>
                        </ResponsiveContainer>
                      </div>
                    </div>

                    <div className="card p-6">
                      <h3 className="text-sm font-bold text-[#0B1020] dark:text-white mb-4">Grade Distribution Scale</h3>
                      <div className="h-64">
                        <ResponsiveContainer width="100%" height="100%">
                          <BarChart data={data.charts?.gradeDistribution || []}>
                            <XAxis dataKey="grade" stroke="#888888" fontSize={11} />
                            <YAxis stroke="#888888" fontSize={11} />
                            <Tooltip contentStyle={{ backgroundColor: "#11162A", border: "1px solid #1F293D", borderRadius: 8, color: "#fff", fontSize: 12 }} />
                            <Bar dataKey="count" fill="#7C3AED" radius={[6, 6, 0, 0]} />
                          </BarChart>
                        </ResponsiveContainer>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* 5.2 STUDENTS TAB */}
              {tab === "students" && data && (
                <div className="space-y-4">
                  <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
                    <div>
                      <h2 className="text-base font-bold text-[#0B1020] dark:text-white">Enrolled Students ({data.total || 0})</h2>
                      <p className="text-xs text-[#64708A]">Comprehensive student directory with atomic ID generation & encryption</p>
                    </div>
                    <button
                      onClick={() => setStudentModal(true)}
                      className="px-4 py-2.5 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-semibold text-xs shadow-md shadow-indigo-600/20 flex items-center gap-2 transition"
                    >
                      <Plus className="w-4 h-4" /> Enroll New Student
                    </button>
                  </div>

                  <div className="table-container">
                    <table>
                      <thead>
                        <tr>
                          <th>Registration No</th>
                          <th>Full Name</th>
                          <th>Department</th>
                          <th>Semester</th>
                          <th>CGPA</th>
                          <th>Attendance</th>
                          <th>Status</th>
                          <th>Action</th>
                        </tr>
                      </thead>
                      <tbody>
                        {(data.items || []).map((s: any) => (
                          <tr key={s.id}>
                            <td className="font-mono font-bold text-indigo-600 dark:text-indigo-400">{s.registration_number}</td>
                            <td className="font-semibold text-[#0B1020] dark:text-white">{s.full_name}</td>
                            <td>{s.department_code || "CSE"}</td>
                            <td>Sem {s.current_semester}</td>
                            <td className="font-mono font-bold">{s.current_cgpa || "0.00"}</td>
                            <td>
                              <Badge
                                label={`${s.attendance_percentage || 100}%`}
                                variant={Number(s.attendance_percentage) < 75 ? "danger" : "success"}
                              />
                            </td>
                            <td><Badge label={s.status} variant={s.status === "ACTIVE" ? "success" : "default"} /></td>
                            <td>
                              <button
                                onClick={async () => {
                                  const detail = await api.admin.getStudentDetail(s.id);
                                  setStudentDetail(detail);
                                }}
                                className="px-2.5 py-1 rounded-lg border border-[#E5E8F0] dark:border-[#1F293D] text-xs font-semibold hover:bg-indigo-50 dark:hover:bg-indigo-950/40 hover:text-indigo-600 transition"
                              >
                                View Profile
                              </button>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}

              {/* 5.3 FACULTY TAB */}
              {tab === "faculty" && data && (
                <div className="space-y-4">
                  <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
                    <div>
                      <h2 className="text-base font-bold text-[#0B1020] dark:text-white">Teaching & Research Faculty</h2>
                      <p className="text-xs text-[#64708A]">Academic appointments, departments, and payroll association</p>
                    </div>
                    <button
                      onClick={() => setFacultyModal(true)}
                      className="px-4 py-2.5 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-semibold text-xs shadow-md shadow-teal-600/20 flex items-center gap-2 transition"
                    >
                      <Plus className="w-4 h-4" /> Add Faculty Member
                    </button>
                  </div>

                  <div className="table-container">
                    <table>
                      <thead>
                        <tr>
                          <th>Employee ID</th>
                          <th>Name</th>
                          <th>Department</th>
                          <th>Designation</th>
                          <th>Email</th>
                          <th>Base Pay</th>
                          <th>Status</th>
                        </tr>
                      </thead>
                      <tbody>
                        {(data || []).map((f: any) => (
                          <tr key={f.id}>
                            <td className="font-mono font-bold text-teal-600 dark:text-teal-400">{f.employee_id}</td>
                            <td className="font-semibold text-[#0B1020] dark:text-white">{f.full_name}</td>
                            <td>{f.department_name}</td>
                            <td>{f.designation}</td>
                            <td className="font-mono text-xs">{f.email}</td>
                            <td className="font-mono font-bold">INR {Number(f.net_salary || 0).toLocaleString()}</td>
                            <td><Badge label={f.status} variant="success" /></td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}

              {/* 5.4 PAYROLL TAB */}
              {tab === "payroll" && data && (
                <div className="space-y-6">
                  <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
                    <div>
                      <h2 className="text-base font-bold text-[#0B1020] dark:text-white">Monthly Institutional Payroll Runs</h2>
                      <p className="text-xs text-[#64708A]">Deterministic salary calculations: Basic + HRA + DA - Deductions</p>
                    </div>
                    <button
                      onClick={async () => {
                        try {
                          await api.admin.generatePayroll();
                          setToast({ msg: "Monthly payroll generated successfully.", type: "success" });
                          loadTab("payroll");
                        } catch (e: any) {
                          setToast({ msg: e.message || "Failed to generate payroll.", type: "error" });
                        }
                      }}
                      className="px-4 py-2.5 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-semibold text-xs shadow-md shadow-indigo-600/20 flex items-center gap-2 transition"
                    >
                      <DollarSign className="w-4 h-4" /> Run Monthly Payroll
                    </button>
                  </div>

                  <div className="table-container">
                    <table>
                      <thead>
                        <tr>
                          <th>Month / Year</th>
                          <th>Total Faculty</th>
                          <th>Total Gross (INR)</th>
                          <th>Total Net Disbursed (INR)</th>
                          <th>Status</th>
                          <th>Generated At</th>
                          <th>Action</th>
                        </tr>
                      </thead>
                      <tbody>
                        {(data || []).map((r: any) => (
                          <tr key={r.id}>
                            <td className="font-bold text-[#0B1020] dark:text-white">{r.month_year}</td>
                            <td className="font-mono">{r.total_faculty}</td>
                            <td className="font-mono">INR {Number(r.total_gross).toLocaleString()}</td>
                            <td className="font-mono font-bold text-emerald-600">INR {Number(r.total_net).toLocaleString()}</td>
                            <td><Badge label={r.status} variant={r.status === "PAID" ? "success" : "warning"} /></td>
                            <td className="text-xs text-[#64708A]">{r.generated_at}</td>
                            <td>
                              {r.status !== "PAID" && (
                                <button
                                  onClick={async () => {
                                    await api.admin.markPayrollPaid(r.id);
                                    setToast({ msg: "Payroll marked as PAID.", type: "success" });
                                    loadTab("payroll");
                                  }}
                                  className="px-2.5 py-1 rounded bg-emerald-50 hover:bg-emerald-100 text-emerald-700 font-semibold text-xs transition"
                                >
                                  Disburse & Mark Paid
                                </button>
                              )}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}

              {/* 5.5 ACADEMICS TAB */}
              {tab === "academics" && data && (
                <div className="space-y-6">
                  <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
                    <div>
                      <h2 className="text-base font-bold text-[#0B1020] dark:text-white">Courses & Academic Offerings</h2>
                      <p className="text-xs text-[#64708A]">Curriculum catalog, credit distributions, and departments</p>
                    </div>
                    <button
                      onClick={() => setCourseModal(true)}
                      className="px-4 py-2.5 rounded-xl bg-violet-600 hover:bg-violet-700 text-white font-semibold text-xs shadow-md shadow-violet-600/20 flex items-center gap-2 transition"
                    >
                      <Plus className="w-4 h-4" /> Add New Course
                    </button>
                  </div>

                  <div className="table-container">
                    <table>
                      <thead>
                        <tr>
                          <th>Course Code</th>
                          <th>Course Name</th>
                          <th>Credits</th>
                          <th>Department</th>
                          <th>Type</th>
                        </tr>
                      </thead>
                      <tbody>
                        {(data.courses || []).map((c: any) => (
                          <tr key={c.id}>
                            <td className="font-mono font-bold text-violet-600 dark:text-violet-400">{c.code}</td>
                            <td className="font-semibold">{c.name}</td>
                            <td className="font-mono font-bold">{c.credits}</td>
                            <td>{c.department_name}</td>
                            <td><Badge label={c.course_type} variant="info" /></td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}

              {/* 5.6 ARREAR REGISTRY */}
              {tab === "arrears" && data && (
                <div className="space-y-4">
                  <div>
                    <h2 className="text-base font-bold text-[#0B1020] dark:text-white">Examination Arrear Registry</h2>
                    <p className="text-xs text-[#64708A]">Centralized registry of failed subjects and re-examination status</p>
                  </div>

                  <div className="table-container">
                    <table>
                      <thead>
                        <tr>
                          <th>Student Name</th>
                          <th>Registration No</th>
                          <th>Failed Course</th>
                          <th>Credits</th>
                          <th>Attempts</th>
                          <th>Status</th>
                        </tr>
                      </thead>
                      <tbody>
                        {(data || []).map((a: any) => (
                          <tr key={a.id}>
                            <td className="font-semibold">{a.student_name}</td>
                            <td className="font-mono text-xs">{a.registration_number}</td>
                            <td className="font-bold text-rose-600">{a.course_code}: {a.course_name}</td>
                            <td className="font-mono">{a.credits}</td>
                            <td className="font-mono">{a.attempt_count}</td>
                            <td><Badge label={a.status} variant={a.status === "CLEARED" ? "success" : "danger"} /></td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}

              {/* 5.7 ANNOUNCEMENTS TAB */}
              {tab === "announcements" && data && (
                <div className="space-y-4">
                  <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
                    <div>
                      <h2 className="text-base font-bold text-[#0B1020] dark:text-white">Institutional Broadcasts & Notices</h2>
                      <p className="text-xs text-[#64708A]">Targeted announcements across students and faculty</p>
                    </div>
                    <button
                      onClick={() => setAnnouncementModal(true)}
                      className="px-4 py-2.5 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-semibold text-xs shadow-md shadow-indigo-600/20 flex items-center gap-2 transition"
                    >
                      <Plus className="w-4 h-4" /> New Announcement
                    </button>
                  </div>

                  <div className="space-y-3">
                    {(data || []).map((ann: any) => (
                      <div key={ann.id} className="card p-5">
                        <div className="flex justify-between items-start mb-2">
                          <div>
                            <h3 className="font-bold text-sm text-[#0B1020] dark:text-white">{ann.title}</h3>
                            <span className="text-[11px] text-[#64708A]">Target: {ann.target_type} • Priority: {ann.priority}</span>
                          </div>
                          <Badge label={ann.priority} variant={ann.priority === "URGENT" ? "danger" : "info"} />
                        </div>
                        <p className="text-xs text-[#64708A]">{ann.content}</p>
                        <div className="mt-3 pt-3 border-t border-[#E5E8F0] dark:border-[#1F293D] flex justify-between text-[11px] text-[#64708A]">
                          <span>Published by: {ann.author_email}</span>
                          <span>{ann.created_at}</span>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* 5.8 LOGS & SECURITY AUDIT */}
              {tab === "logs" && data && (
                <div className="space-y-4">
                  <div className="flex flex-wrap gap-2 border-b border-[#E5E8F0] dark:border-[#1F293D] pb-3">
                    {[
                      { id: "audit", label: "Audit Trail" },
                      { id: "login", label: `Authentication Logs (${(data.login || []).length})` },
                      { id: "blocked", label: `Blocked Accounts (${(data.blocked || []).length})` },
                      { id: "comms", label: `Email Outbox (${(data.comms || []).length})` },
                    ].map((sub: any) => (
                      <button
                        key={sub.id}
                        onClick={() => setData({ ...data, subtab: sub.id })}
                        className={`px-3.5 py-1.5 rounded-xl text-xs font-semibold transition ${
                          data.subtab === sub.id
                            ? "bg-indigo-600 text-white shadow-sm shadow-indigo-600/30"
                            : "text-[#64708A] hover:bg-slate-100 dark:hover:bg-slate-800 hover:text-[#0B1020] dark:hover:text-white"
                        }`}
                      >
                        {sub.label}
                      </button>
                    ))}
                  </div>

                  {data.subtab === "audit" && (
                    <div className="table-container">
                      <table>
                        <thead>
                          <tr>
                            <th>Action</th>
                            <th>Target Entity</th>
                            <th>Entity ID</th>
                            <th>Author</th>
                            <th>IP Address</th>
                            <th>Timestamp</th>
                          </tr>
                        </thead>
                        <tbody>
                          {(data.audit || []).length === 0 ? (
                            <tr><td colSpan={6} className="text-center py-6 text-xs text-[#64708A]">No audit events logged yet.</td></tr>
                          ) : (
                            (data.audit || []).map((a: any) => (
                              <tr key={a.id}>
                                <td><Badge label={a.action} variant="info" /></td>
                                <td className="font-semibold">{a.entity_name}</td>
                                <td className="font-mono text-xs">{a.entity_id || "N/A"}</td>
                                <td className="text-xs">{a.user_email || "System"}</td>
                                <td className="font-mono text-xs">{a.ip_address}</td>
                                <td className="text-xs text-[#64708A]">{a.created_at}</td>
                              </tr>
                            ))
                          )}
                        </tbody>
                      </table>
                    </div>
                  )}

                  {data.subtab === "login" && (
                    <div className="table-container">
                      <table>
                        <thead>
                          <tr>
                            <th>Identifier</th>
                            <th>Role</th>
                            <th>Status</th>
                            <th>IP Address</th>
                            <th>Client / User Agent</th>
                            <th>Logged At</th>
                          </tr>
                        </thead>
                        <tbody>
                          {(data.login || []).length === 0 ? (
                            <tr><td colSpan={6} className="text-center py-6 text-xs text-[#64708A]">No login activity recorded yet.</td></tr>
                          ) : (
                            (data.login || []).map((l: any) => (
                              <tr key={l.id}>
                                <td className="font-mono font-bold text-xs">{l.identifier}</td>
                                <td><Badge label={l.role || "USER"} /></td>
                                <td><Badge label={l.status} variant={l.status === "SUCCESS" ? "success" : "danger"} /></td>
                                <td className="font-mono text-xs">{l.ip_address}</td>
                                <td className="text-xs text-[#64708A] truncate max-w-xs">{l.user_agent}</td>
                                <td className="text-xs text-[#64708A] font-mono">{l.logged_at}</td>
                              </tr>
                            ))
                          )}
                        </tbody>
                      </table>
                    </div>
                  )}

                  {data.subtab === "blocked" && (
                    <div className="table-container">
                      <table>
                        <thead>
                          <tr>
                            <th>Account Email</th>
                            <th>Role</th>
                            <th>Action</th>
                            <th>Reason</th>
                            <th>IP Address</th>
                            <th>Timestamp</th>
                          </tr>
                        </thead>
                        <tbody>
                          {(data.blocked || []).length === 0 ? (
                            <tr><td colSpan={6} className="text-center py-6 text-xs text-[#64708A]">No blocked accounts. All institutional credentials are active.</td></tr>
                          ) : (
                            (data.blocked || []).map((b: any) => (
                              <tr key={b.id}>
                                <td className="font-semibold">{b.account_email}</td>
                                <td><Badge label={b.account_role || "USER"} /></td>
                                <td><Badge label={b.action} variant="danger" /></td>
                                <td className="text-xs text-[#64708A]">{b.reason}</td>
                                <td className="font-mono text-xs">{b.ip_address}</td>
                                <td className="text-xs text-[#64708A]">{b.created_at}</td>
                              </tr>
                            ))
                          )}
                        </tbody>
                      </table>
                    </div>
                  )}

                  {data.subtab === "comms" && (
                    <div className="table-container">
                      <table>
                        <thead>
                          <tr>
                            <th>Recipient</th>
                            <th>Subject</th>
                            <th>Template</th>
                            <th>Status</th>
                            <th>Sent At</th>
                          </tr>
                        </thead>
                        <tbody>
                          {(data.comms || []).length === 0 ? (
                            <tr><td colSpan={5} className="text-center py-6 text-xs text-[#64708A]">No email dispatches recorded in outbox queue.</td></tr>
                          ) : (
                            (data.comms || []).map((c: any) => (
                              <tr key={c.id}>
                                <td className="font-mono text-xs font-semibold">{c.recipient_email}</td>
                                <td>{c.subject}</td>
                                <td className="font-mono text-xs">{c.template_name || "SYSTEM_MAIL"}</td>
                                <td><Badge label={c.status} variant={c.status === "SENT" ? "success" : "info"} /></td>
                                <td className="text-xs text-[#64708A]">{c.sent_at || c.created_at}</td>
                              </tr>
                            ))
                          )}
                        </tbody>
                      </table>
                    </div>
                  )}
                </div>
              )}
            </>
          )}
        </div>
      </main>

      {/* Enroll Student Modal */}
      {studentModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
          <div className="bg-white dark:bg-[#11162A] rounded-2xl max-w-lg w-full border border-[#E5E8F0] dark:border-[#1F293D] shadow-2xl p-6 overflow-y-auto max-h-[90vh]">
            <div className="flex justify-between items-center pb-3 border-b border-[#E5E8F0] dark:border-[#1F293D]">
              <h3 className="font-bold text-base text-[#0B1020] dark:text-white">Enroll New Student</h3>
              <button onClick={() => setStudentModal(false)} className="text-slate-400 hover:text-slate-600 text-lg">✕</button>
            </div>
            <form onSubmit={handleCreateStudent} className="space-y-3 mt-4 text-xs">
              <div>
                <label className="block font-semibold mb-1">Full Legal Name</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Rahul Gupta"
                  value={newStudent.fullName}
                  onChange={(e) => setNewStudent({ ...newStudent, fullName: e.target.value })}
                  className="w-full"
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold mb-1">Personal Email</label>
                  <input
                    type="email"
                    required
                    placeholder="student@gmail.com"
                    value={newStudent.personalEmail}
                    onChange={(e) => setNewStudent({ ...newStudent, personalEmail: e.target.value })}
                    className="w-full"
                  />
                </div>
                <div>
                  <label className="block font-semibold mb-1">Phone Number</label>
                  <input
                    type="tel"
                    required
                    placeholder="9876543210"
                    value={newStudent.phone}
                    onChange={(e) => setNewStudent({ ...newStudent, phone: e.target.value })}
                    className="w-full"
                  />
                </div>
              </div>
              <div>
                <label className="block font-semibold mb-1">Aadhaar (Stored AES-256-GCM Encrypted)</label>
                <input
                  type="text"
                  required
                  maxLength={12}
                  placeholder="12 digit Aadhaar number"
                  value={newStudent.aadhaar}
                  onChange={(e) => setNewStudent({ ...newStudent, aadhaar: e.target.value })}
                  className="w-full font-mono"
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold mb-1">Father / Guardian Name</label>
                  <input
                    type="text"
                    required
                    placeholder="Father Name"
                    value={newStudent.fatherName}
                    onChange={(e) => setNewStudent({ ...newStudent, fatherName: e.target.value })}
                    className="w-full"
                  />
                </div>
                <div>
                  <label className="block font-semibold mb-1">Parent Phone</label>
                  <input
                    type="tel"
                    required
                    placeholder="9876543211"
                    value={newStudent.parentPhone}
                    onChange={(e) => setNewStudent({ ...newStudent, parentPhone: e.target.value })}
                    className="w-full"
                  />
                </div>
              </div>
              <div className="flex justify-end gap-2 pt-4 border-t border-[#E5E8F0] dark:border-[#1F293D]">
                <button
                  type="button"
                  onClick={() => setStudentModal(false)}
                  className="px-4 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] font-semibold text-xs"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-semibold text-xs shadow-md transition"
                >
                  Confirm Enrollment
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Add Faculty Modal */}
      {facultyModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
          <div className="bg-white dark:bg-[#11162A] rounded-2xl max-w-lg w-full border border-[#E5E8F0] dark:border-[#1F293D] shadow-2xl p-6 overflow-y-auto max-h-[90vh]">
            <div className="flex justify-between items-center pb-3 border-b border-[#E5E8F0] dark:border-[#1F293D]">
              <h3 className="font-bold text-base text-[#0B1020] dark:text-white">Add Faculty Member</h3>
              <button onClick={() => setFacultyModal(false)} className="text-slate-400 hover:text-slate-600 text-lg">✕</button>
            </div>
            <form onSubmit={handleCreateFaculty} className="space-y-3 mt-4 text-xs">
              <div>
                <label className="block font-semibold mb-1">Full Legal Name</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Dr. Rajesh Kumar"
                  value={newFaculty.fullName}
                  onChange={(e) => setNewFaculty({ ...newFaculty, fullName: e.target.value })}
                  className="w-full"
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold mb-1">Email</label>
                  <input
                    type="email"
                    required
                    placeholder="rajesh@college.local"
                    value={newFaculty.email}
                    onChange={(e) => setNewFaculty({ ...newFaculty, email: e.target.value })}
                    className="w-full"
                  />
                </div>
                <div>
                  <label className="block font-semibold mb-1">Phone</label>
                  <input
                    type="tel"
                    required
                    placeholder="9876543220"
                    value={newFaculty.phone}
                    onChange={(e) => setNewFaculty({ ...newFaculty, phone: e.target.value })}
                    className="w-full"
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold mb-1">Qualification</label>
                  <input
                    type="text"
                    required
                    value={newFaculty.qualification}
                    onChange={(e) => setNewFaculty({ ...newFaculty, qualification: e.target.value })}
                    className="w-full"
                  />
                </div>
                <div>
                  <label className="block font-semibold mb-1">Basic Salary (INR)</label>
                  <input
                    type="number"
                    required
                    value={newFaculty.basicPay}
                    onChange={(e) => setNewFaculty({ ...newFaculty, basicPay: Number(e.target.value) })}
                    className="w-full font-mono"
                  />
                </div>
              </div>
              <div className="flex justify-end gap-2 pt-4 border-t border-[#E5E8F0] dark:border-[#1F293D]">
                <button
                  type="button"
                  onClick={() => setFacultyModal(false)}
                  className="px-4 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] font-semibold text-xs"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-semibold text-xs shadow-md transition"
                >
                  Create Appointment
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Add Course Modal */}
      {courseModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
          <div className="bg-white dark:bg-[#11162A] rounded-2xl max-w-md w-full border border-[#E5E8F0] dark:border-[#1F293D] shadow-2xl p-6">
            <div className="flex justify-between items-center pb-3 border-b border-[#E5E8F0] dark:border-[#1F293D]">
              <h3 className="font-bold text-base text-[#0B1020] dark:text-white">Add New Course</h3>
              <button onClick={() => setCourseModal(false)} className="text-slate-400 text-lg">✕</button>
            </div>
            <form onSubmit={handleCreateCourse} className="space-y-3 mt-4 text-xs">
              <div>
                <label className="block font-semibold mb-1">Course Code</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. CS105"
                  value={newCourse.code}
                  onChange={(e) => setNewCourse({ ...newCourse, code: e.target.value })}
                  className="w-full font-mono"
                />
              </div>
              <div>
                <label className="block font-semibold mb-1">Course Name</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Cloud Computing & Microservices"
                  value={newCourse.name}
                  onChange={(e) => setNewCourse({ ...newCourse, name: e.target.value })}
                  className="w-full"
                />
              </div>
              <div>
                <label className="block font-semibold mb-1">Credits</label>
                <input
                  type="number"
                  required
                  min={1}
                  max={6}
                  value={newCourse.credits}
                  onChange={(e) => setNewCourse({ ...newCourse, credits: Number(e.target.value) })}
                  className="w-full font-mono"
                />
              </div>
              <div className="flex justify-end gap-2 pt-4 border-t border-[#E5E8F0] dark:border-[#1F293D]">
                <button type="button" onClick={() => setCourseModal(false)} className="px-4 py-2 rounded-xl border font-semibold text-xs">
                  Cancel
                </button>
                <button type="submit" className="px-4 py-2 rounded-xl bg-violet-600 hover:bg-violet-700 text-white font-semibold text-xs shadow-md transition">
                  Save Course
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* New Announcement Modal */}
      {announcementModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
          <div className="bg-white dark:bg-[#11162A] rounded-2xl max-w-lg w-full border border-[#E5E8F0] dark:border-[#1F293D] shadow-2xl p-6">
            <div className="flex justify-between items-center pb-3 border-b border-[#E5E8F0] dark:border-[#1F293D]">
              <h3 className="font-bold text-base text-[#0B1020] dark:text-white">New Campus Announcement</h3>
              <button onClick={() => setAnnouncementModal(false)} className="text-slate-400 text-lg">✕</button>
            </div>
            <form onSubmit={handleCreateAnnouncement} className="space-y-3 mt-4 text-xs">
              <div>
                <label className="block font-semibold mb-1">Announcement Title</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Schedule for Mid-Term Assessments"
                  value={newAnn.title}
                  onChange={(e) => setNewAnn({ ...newAnn, title: e.target.value })}
                  className="w-full"
                />
              </div>
              <div>
                <label className="block font-semibold mb-1">Content</label>
                <textarea
                  rows={4}
                  required
                  placeholder="Detailed announcement notification..."
                  value={newAnn.content}
                  onChange={(e) => setNewAnn({ ...newAnn, content: e.target.value })}
                  className="w-full p-2.5 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent"
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold mb-1">Priority</label>
                  <select
                    value={newAnn.priority}
                    onChange={(e) => setNewAnn({ ...newAnn, priority: e.target.value })}
                    className="w-full p-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent"
                  >
                    <option value="NORMAL">NORMAL</option>
                    <option value="URGENT">URGENT</option>
                    <option value="EVENT">EVENT</option>
                  </select>
                </div>
                <div>
                  <label className="block font-semibold mb-1">Target Audience</label>
                  <select
                    value={newAnn.targetType}
                    onChange={(e) => setNewAnn({ ...newAnn, targetType: e.target.value })}
                    className="w-full p-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent"
                  >
                    <option value="ALL">ALL USERS</option>
                    <option value="ALL_STUDENTS">STUDENTS ONLY</option>
                    <option value="ALL_FACULTY">FACULTY ONLY</option>
                  </select>
                </div>
              </div>
              <div className="flex justify-end gap-2 pt-4 border-t border-[#E5E8F0] dark:border-[#1F293D]">
                <button type="button" onClick={() => setAnnouncementModal(false)} className="px-4 py-2 rounded-xl border font-semibold text-xs">
                  Cancel
                </button>
                <button type="submit" className="px-4 py-2 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-semibold text-xs shadow-md transition">
                  Broadcast Notice
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Student Profile Detail Modal */}
      {studentDetail && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
          <div className="bg-white dark:bg-[#11162A] rounded-2xl max-w-2xl w-full border border-[#E5E8F0] dark:border-[#1F293D] shadow-2xl p-6 overflow-y-auto max-h-[90vh]">
            <div className="flex justify-between items-start border-b border-[#E5E8F0] dark:border-[#1F293D] pb-4 mb-4">
              <div>
                <h3 className="text-xl font-bold text-[#0B1020] dark:text-white">{studentDetail.student?.full_name}</h3>
                <p className="text-xs text-[#64708A] font-mono">{studentDetail.student?.registration_number} • {studentDetail.student?.programme_name}</p>
              </div>
              <button onClick={() => setStudentDetail(null)} className="text-slate-400 hover:text-slate-600 text-lg">✕</button>
            </div>

            <div className="space-y-4 text-xs">
              <div className="grid grid-cols-2 gap-3 p-4 rounded-xl bg-[#F6F7FB] dark:bg-[#0B1020]">
                <div><span className="text-[#64708A] block">College Email:</span> <b className="font-mono">{studentDetail.student?.college_email}</b></div>
                <div><span className="text-[#64708A] block">Phone:</span> <b>{studentDetail.student?.phone}</b></div>
                <div><span className="text-[#64708A] block">Parent Phone:</span> <b>{studentDetail.student?.parent_phone}</b></div>
                <div><span className="text-[#64708A] block">ABC ID:</span> <b className="font-mono">{studentDetail.student?.abc_id || "Not registered"}</b></div>
                <div>
                  <span className="text-[#64708A] block">Aadhaar (DPDP Act 2023 Encrypted):</span>
                  <div className="flex items-center gap-2 mt-1">
                    <span className="font-mono font-bold">{studentDetail.student?.aadhaar_revealed || studentDetail.student?.aadhaar_masked}</span>
                    {!studentDetail.student?.aadhaar_revealed && (
                      <button
                        onClick={async () => {
                          const res = await api.admin.revealAadhaar(studentDetail.student.id);
                          setStudentDetail({
                            ...studentDetail,
                            student: { ...studentDetail.student, aadhaar_revealed: res.aadhaar }
                          });
                        }}
                        className="px-2 py-0.5 rounded bg-indigo-50 hover:bg-indigo-100 text-indigo-600 font-semibold text-[10px] transition"
                      >
                        Reveal & Log
                      </button>
                    )}
                  </div>
                </div>
              </div>

              <div>
                <h4 className="font-bold text-sm mb-2 text-[#0B1020] dark:text-white">Registered Courses</h4>
                <div className="space-y-1.5">
                  {(studentDetail.courses || []).map((c: any, i: number) => (
                    <div key={i} className="flex justify-between p-2 rounded-lg border border-[#E5E8F0] dark:border-[#1F293D]">
                      <span><b>{c.code}</b>: {c.name} ({c.credits} cr)</span>
                      <span className="text-[#64708A]">Faculty: {c.faculty_name}</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {toast && <Toast message={toast.msg} type={toast.type} onClose={() => setToast(null)} />}
    </div>
  );
}
