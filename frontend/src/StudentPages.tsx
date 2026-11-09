import React, { useState, useEffect } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import {
  GraduationCap, Calendar, Clock, BookOpen, AlertTriangle, CheckCircle,
  DollarSign, FileText, Download, ShieldCheck, LogOut, ArrowRight, Bell, Menu, X, Key, Upload, User
} from "lucide-react";
import { api, clearAuth, downloadBlob } from "./api";
import { StatCard, Badge, Toast, ThemeToggle, NotificationBell, PasswordChangeModal } from "./ui";

export function StudentPortal() {
  const navigate = useNavigate();
  const location = useLocation();

  const pathSegments = location.pathname.split("/").filter(Boolean);
  const tab = pathSegments[1] || "dashboard";

  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [toast, setToast] = useState<{ msg: string; type: "success" | "error" | "info" } | null>(null);
  const [mobileOpen, setMobileOpen] = useState(false);
  const [downloadingPdf, setDownloadingPdf] = useState(false);
  const [pwdModalOpen, setPwdModalOpen] = useState(false);

  // Assignment submission modal state
  const [submitModalAssign, setSubmitModalAssign] = useState<any>(null);
  const [subText, setSubText] = useState("");
  const [subFileUrl, setSubFileUrl] = useState("");
  const [submitting, setSubmitting] = useState(false);

  // Profile update state
  const [editPhone, setEditPhone] = useState("");
  const [editAddress, setEditAddress] = useState("");

  useEffect(() => {
    loadTab(tab);
  }, [tab]);

  async function loadTab(t: string) {
    setLoading(true);
    try {
      if (t === "dashboard") {
        const res = await api.student.getDashboard();
        setData(res);
      } else if (t === "attendance") {
        const res = await api.student.getAttendance();
        setData(res);
      } else if (t === "results") {
        const res = await api.student.getResults();
        setData(res);
      } else if (t === "arrears") {
        const res = await api.student.getArrears();
        setData(res);
      } else if (t === "fees") {
        const res = await api.student.getFees();
        setData(res);
      } else if (t === "timetable") {
        const res = await api.student.getTimetable();
        setData(res);
      } else if (t === "assignments") {
        const res = await api.student.getAssignments();
        setData(res);
      } else if (t === "profile") {
        const res = await api.getMe();
        setData(res);
        if (res.profile) {
          setEditPhone(res.profile.phone || "");
          setEditAddress(res.profile.address || "");
        }
      }
    } catch (err: any) {
      setToast({ msg: err.message, type: "error" });
    } finally {
      setLoading(false);
    }
  }

  async function handleRegisterReExam(arrearId: number) {
    try {
      await api.student.registerReExam(arrearId);
      setToast({ msg: "Successfully registered for Arrear Re-Exam.", type: "success" });
      loadTab("arrears");
    } catch (err: any) {
      setToast({ msg: err.message, type: "error" });
    }
  }

  async function handleDownloadResultPdf() {
    setDownloadingPdf(true);
    try {
      const regNo = data?.profile?.registration_number || "Student";
      await downloadBlob("/student/results/download-pdf", `Result_Sheet_${regNo}.pdf`);
      setToast({ msg: "Result Sheet PDF downloaded successfully.", type: "success" });
    } catch (e: any) {
      setToast({ msg: e.message || "Failed to download Result Sheet PDF.", type: "error" });
    } finally {
      setDownloadingPdf(false);
    }
  }

  async function handleDownloadReceipt(paymentId: number, receiptNum: string) {
    try {
      await downloadBlob(`/student/fees/receipt/${paymentId}/download-pdf`, `Receipt_${receiptNum}.pdf`);
      setToast({ msg: "Receipt downloaded successfully.", type: "success" });
    } catch (e: any) {
      setToast({ msg: e.message || "Failed to download receipt.", type: "error" });
    }
  }

  async function handleSubmitAssignment(e: React.FormEvent) {
    e.preventDefault();
    if (!submitModalAssign) return;
    setSubmitting(true);
    try {
      await api.student.submitAssignment(submitModalAssign.id, {
        submissionText: subText,
        fileUrl: subFileUrl || "https://drive.google.com/submission",
      });
      setToast({ msg: "Assignment submitted successfully!", type: "success" });
      setSubmitModalAssign(null);
      setSubText("");
      setSubFileUrl("");
      loadTab("assignments");
    } catch (err: any) {
      setToast({ msg: err.message || "Failed to submit assignment.", type: "error" });
    } finally {
      setSubmitting(false);
    }
  }

  async function handleSaveProfile(e: React.FormEvent) {
    e.preventDefault();
    try {
      await api.student.updateProfile({ phone: editPhone, address: editAddress });
      setToast({ msg: "Profile updated successfully.", type: "success" });
      loadTab("profile");
    } catch (err: any) {
      setToast({ msg: err.message || "Failed to update profile.", type: "error" });
    }
  }

  const navItems = [
    { id: "dashboard", label: "My Dashboard", icon: GraduationCap },
    { id: "timetable", label: "Weekly Schedule", icon: Clock },
    { id: "assignments", label: "Assignments", icon: BookOpen },
    { id: "attendance", label: "Attendance & Heatmap", icon: Calendar },
    { id: "results", label: "Grades & Results", icon: FileText },
    { id: "arrears", label: "Arrears & Re-Exams", icon: AlertTriangle },
    { id: "fees", label: "Fee Statements", icon: DollarSign },
    { id: "profile", label: "Profile & Security", icon: User },
  ];

  const daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];

  return (
    <div className="flex h-screen bg-[#F6F7FB] dark:bg-[#0B1020] overflow-hidden">
      {/* Mobile Sidebar Overlay */}
      {mobileOpen && (
        <div onClick={() => setMobileOpen(false)} className="fixed inset-0 z-40 bg-black/50 md:hidden backdrop-blur-sm" />
      )}

      {/* Sidebar Navigation */}
      <aside className={`
        fixed md:static inset-y-0 left-0 z-50 w-64 bg-white dark:bg-[#11162A] border-r border-[#E5E8F0] dark:border-[#1F293D] flex flex-col justify-between shrink-0 transition-transform duration-300
        ${mobileOpen ? "translate-x-0 shadow-2xl" : "-translate-x-full md:translate-x-0"}
      `}>
        <div>
          <div className="p-5 border-b border-[#E5E8F0] dark:border-[#1F293D] flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-xl bg-violet-600 flex items-center justify-center text-white font-bold shadow-md shadow-violet-500/20">
                <GraduationCap className="w-5 h-5" />
              </div>
              <div>
                <h2 className="text-sm font-bold text-[#0B1020] dark:text-white font-heading">CampusFlow</h2>
                <p className="text-[10px] text-violet-600 dark:text-violet-400 font-mono tracking-wider uppercase font-semibold">Student Portal</p>
              </div>
            </div>
            <button onClick={() => setMobileOpen(false)} className="md:hidden text-slate-400">
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
                    navigate(`/student/${item.id}`);
                    setMobileOpen(false);
                  }}
                  className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold transition ${
                    active
                      ? "bg-violet-50 dark:bg-violet-950/40 text-violet-700 dark:text-violet-300 shadow-sm border border-violet-100 dark:border-violet-900"
                      : "text-[#64708A] hover:bg-slate-100 dark:hover:bg-slate-800/60 hover:text-[#0B1020] dark:hover:text-white"
                  }`}
                >
                  <Icon className={`w-4 h-4 ${active ? "text-violet-600 dark:text-violet-400" : ""}`} />
                  {item.label}
                </button>
              );
            })}
          </nav>
        </div>

        <div className="p-4 border-t border-[#E5E8F0] dark:border-[#1F293D] space-y-2">
          <button
            onClick={() => setPwdModalOpen(true)}
            className="w-full flex items-center justify-center gap-2 py-2 px-3 rounded-xl text-xs font-medium text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition"
          >
            <Key className="w-3.5 h-3.5" /> Change Password
          </button>
          <button
            onClick={() => {
              clearAuth();
              window.location.href = "/student/login";
            }}
            className="w-full flex items-center justify-center gap-2 py-2 px-3 rounded-xl text-xs font-semibold text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/40 border border-rose-200 dark:border-rose-900 transition"
          >
            <LogOut className="w-3.5 h-3.5" /> Sign Out
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <main className="flex-1 overflow-y-auto">
        {/* Sticky Header */}
        <header className="sticky top-0 z-20 bg-white/80 dark:bg-[#11162A]/80 backdrop-blur border-b border-[#E5E8F0] dark:border-[#1F293D] px-4 md:px-8 py-3.5 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <button
              onClick={() => setMobileOpen(true)}
              className="md:hidden p-2 rounded-lg border border-[#E5E8F0] dark:border-[#1F293D] text-[#0B1020] dark:text-white"
            >
              <Menu className="w-5 h-5" />
            </button>
            <h1 className="text-base font-bold text-[#0B1020] dark:text-white capitalize font-heading">
              {tab.replace("-", " ")}
            </h1>
          </div>
          <div className="flex items-center gap-2.5">
            <ThemeToggle />
            <NotificationBell />
            <button
              onClick={() => {
                clearAuth();
                window.location.href = "/student/login";
              }}
              className="hidden md:flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/40 border border-rose-200 dark:border-rose-900 transition"
            >
              <LogOut className="w-3.5 h-3.5" /> Exit
            </button>
          </div>
        </header>

        {/* Viewport Content */}
        <div className="p-4 md:p-8 max-w-6xl mx-auto space-y-6">
          {loading ? (
            <div className="p-12 text-center text-xs text-[#64708A]">Loading academic records...</div>
          ) : (
            <>
              {/* TAB 1: DASHBOARD */}
              {tab === "dashboard" && data && (
                <div className="space-y-6">
                  {/* Banner Profile */}
                  <div className="card p-6 bg-gradient-to-r from-violet-600 to-indigo-700 text-white shadow-xl shadow-violet-500/10">
                    <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                      <div>
                        <span className="px-2.5 py-0.5 rounded-full bg-white/20 text-white font-mono text-xs font-semibold">
                          {data.profile?.registration_number}
                        </span>
                        <h2 className="text-2xl font-bold font-heading mt-2">{data.profile?.full_name}</h2>
                        <p className="text-violet-100 text-xs mt-1">
                          {data.profile?.programme_name} • Semester {data.profile?.current_semester} • Section {data.profile?.section_name || "A"}
                        </p>
                      </div>
                      <div className="flex gap-4">
                        <div className="bg-white/10 backdrop-blur rounded-2xl p-4 text-center min-w-[90px]">
                          <p className="text-[10px] text-violet-200 uppercase tracking-widest font-semibold">CGPA</p>
                          <p className="text-2xl font-bold font-mono-numbers mt-0.5">{data.profile?.current_cgpa || "0.00"}</p>
                        </div>
                        <div className="bg-white/10 backdrop-blur rounded-2xl p-4 text-center min-w-[90px]">
                          <p className="text-[10px] text-violet-200 uppercase tracking-widest font-semibold">Attendance</p>
                          <p className="text-2xl font-bold font-mono-numbers mt-0.5">{data.profile?.attendance_percentage || 0}%</p>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Arrear Alert if any */}
                  {((Array.isArray(data.activeArrears) ? data.activeArrears.length : Number(data.activeArrears) || 0) > 0) && (
                    <div className="p-4 rounded-2xl bg-amber-50 dark:bg-amber-950/30 border border-amber-200 dark:border-amber-900 flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <AlertTriangle className="w-5 h-5 text-amber-600 dark:text-amber-400" />
                        <div>
                          <p className="text-xs font-bold text-amber-900 dark:text-amber-200">Arrear Alert: {Array.isArray(data.activeArrears) ? data.activeArrears.length : data.activeArrears} Course(s) Pending</p>
                          <p className="text-[11px] text-amber-700 dark:text-amber-400">Register for scheduled re-examinations to maintain credit progression.</p>
                        </div>
                      </div>
                      <button
                        onClick={() => navigate("/student/arrears")}
                        className="px-3 py-1.5 rounded-xl bg-amber-600 text-white text-xs font-semibold hover:bg-amber-700"
                      >
                        View Arrears
                      </button>
                    </div>
                  )}

                  {/* Quick Cards */}
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <StatCard title="Upcoming Assignments" value={(data.upcomingAssignments || data.assignments || []).length} subtitle="Pending deadlines" icon={BookOpen} color="violet" />
                    <StatCard title="Today's Classes" value={(data.todayClasses || []).length} subtitle="Scheduled periods" icon={Clock} color="indigo" />
                    <StatCard title="Fee Balance Due" value={`INR ${Number(data.feeSummary?.balance_due ?? data.fees?.pending ?? 0).toLocaleString()}`} subtitle="Current academic cycle" icon={DollarSign} color={Number(data.feeSummary?.balance_due ?? data.fees?.pending ?? 0) > 0 ? "rose" : "emerald"} />
                  </div>

                  {/* Today's Classes */}
                  <div className="card p-6">
                    <h3 className="text-sm font-bold text-[#0B1020] dark:text-white mb-4">Today's Class Schedule</h3>
                    {(data.todayClasses || []).length === 0 ? (
                      <p className="text-xs text-[#64708A] text-center py-4">No classes scheduled for today.</p>
                    ) : (
                      <div className="space-y-2">
                        {data.todayClasses.map((c: any, i: number) => (
                          <div key={i} className="p-3 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] flex items-center justify-between text-xs">
                            <div className="flex items-center gap-3">
                              <span className="w-7 h-7 rounded-lg bg-violet-50 dark:bg-violet-950/40 text-violet-600 dark:text-violet-400 flex items-center justify-center font-bold font-mono">
                                P{c.period_number}
                              </span>
                              <div>
                                <p className="font-semibold text-[#0B1020] dark:text-white">{c.course_name} ({c.course_code})</p>
                                <p className="text-[#64708A]">{c.faculty_name} • Room {c.room_number}</p>
                              </div>
                            </div>
                            <span className="font-mono text-slate-500">{c.start_time} - {c.end_time}</span>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                </div>
              )}

              {/* TAB 2: TIMETABLE */}
              {tab === "timetable" && (
                <div className="space-y-4">
                  <div>
                    <h3 className="text-base font-bold text-[#0B1020] dark:text-white">Weekly Class Timetable</h3>
                    <p className="text-xs text-[#64708A]">Official section timetable with assigned faculty and room allocations.</p>
                  </div>

                  {(!data || !Array.isArray(data) || data.length === 0) ? (
                    <div className="card p-8 text-center text-xs text-[#64708A]">
                      No timetable slots allocated for your current section.
                    </div>
                  ) : (
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                      {daysOfWeek.map((dayName, idx) => {
                        const dayNum = idx + 1;
                        const slots = Array.isArray(data) ? data : ((data as any)?.slots || []);
                        const daySlots = slots.filter((s: any) => s.day_of_week === dayNum);
                        return (
                          <div key={dayName} className="card p-4 space-y-3">
                            <div className="flex items-center justify-between border-b border-[#E5E8F0] dark:border-[#1F293D] pb-2">
                              <span className="text-xs font-bold text-violet-600 dark:text-violet-400 uppercase tracking-wider">{dayName}</span>
                              <span className="text-[10px] text-[#64708A] font-mono">{daySlots.length} periods</span>
                            </div>
                            {daySlots.length === 0 ? (
                              <p className="text-[11px] text-[#64708A] italic py-2">No lectures scheduled</p>
                            ) : (
                              <div className="space-y-2">
                                {daySlots.map((slot: any, sIdx: number) => (
                                  <div key={sIdx} className="p-2.5 rounded-xl bg-slate-50 dark:bg-slate-800/50 border border-slate-100 dark:border-slate-800 text-xs">
                                    <div className="flex justify-between items-start">
                                      <span className="font-mono font-bold text-violet-600 dark:text-violet-400">{slot.course_code}</span>
                                      <span className="text-[10px] font-mono text-[#64708A]">{slot.start_time}</span>
                                    </div>
                                    <p className="font-medium text-[#0B1020] dark:text-white mt-0.5 line-clamp-1">{slot.course_name}</p>
                                    <div className="flex justify-between text-[10px] text-[#64708A] mt-1.5">
                                      <span>{slot.faculty_name}</span>
                                      <span className="font-mono">Rm {slot.room_number}</span>
                                    </div>
                                  </div>
                                ))}
                              </div>
                            )}
                          </div>
                        );
                      })}
                    </div>
                  )}
                </div>
              )}

              {/* TAB 3: ASSIGNMENTS */}
              {tab === "assignments" && (
                <div className="space-y-4">
                  <div>
                    <h3 className="text-base font-bold text-[#0B1020] dark:text-white">Assignments & Submissions</h3>
                    <p className="text-xs text-[#64708A]">Coursework instructions, submission upload, and faculty marks feedback.</p>
                  </div>

                  {(!data || !Array.isArray(data) || data.length === 0) ? (
                    <div className="card p-8 text-center text-xs text-[#64708A]">
                      No assignments currently posted for your registered courses.
                    </div>
                  ) : (
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      {(Array.isArray(data) ? data : []).map((a: any) => (
                        <div key={a.id} className="card p-5 space-y-3 flex flex-col justify-between">
                          <div>
                            <div className="flex items-start justify-between gap-2">
                              <span className="text-[10px] font-mono font-bold text-violet-600 bg-violet-50 dark:bg-violet-950 px-2 py-0.5 rounded">
                                {a.course_code}
                              </span>
                              <Badge
                                label={a.status}
                                variant={a.status === "SUBMITTED" ? "success" : a.status === "OVERDUE" ? "danger" : "warning"}
                              />
                            </div>
                            <h4 className="font-bold text-sm text-[#0B1020] dark:text-white mt-2">{a.title}</h4>
                            <p className="text-xs text-[#64708A] mt-1 line-clamp-2">{a.instructions}</p>
                          </div>

                          <div className="border-t border-[#E5E8F0] dark:border-[#1F293D] pt-3 text-xs space-y-2">
                            <div className="flex justify-between text-[11px] text-[#64708A]">
                              <span>Due Date: {new Date(a.due_date).toLocaleDateString()}</span>
                              <span>Max Marks: {a.max_marks}</span>
                            </div>

                            {a.submission_id && (
                              <div className="p-2.5 rounded-xl bg-slate-50 dark:bg-slate-800/50 text-[11px]">
                                <div className="flex justify-between font-medium">
                                  <span>Submitted: {new Date(a.submitted_at).toLocaleDateString()}</span>
                                  <span className="font-bold text-emerald-600">
                                    {a.marks_obtained != null ? `${a.marks_obtained} / ${a.max_marks}` : "Awaiting grading"}
                                  </span>
                                </div>
                                {a.feedback && <p className="text-[#64708A] mt-1 italic">Feedback: "{a.feedback}"</p>}
                              </div>
                            )}

                            <button
                              onClick={() => {
                                setSubmitModalAssign(a);
                                setSubText(a.submission_text || "");
                                setSubFileUrl(a.file_url || "");
                              }}
                              className="w-full py-2 rounded-xl bg-violet-600 hover:bg-violet-700 text-white font-semibold text-xs flex items-center justify-center gap-1.5 transition"
                            >
                              <Upload className="w-3.5 h-3.5" /> {a.submission_id ? "Update Submission" : "Submit Work"}
                            </button>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              )}

              {/* TAB 4: ATTENDANCE */}
              {tab === "attendance" && data && (
                <div className="space-y-6">
                  <div>
                    <h3 className="text-base font-bold text-[#0B1020] dark:text-white">Attendance Summary & Heatmap</h3>
                    <p className="text-xs text-[#64708A]">Statutory 75% attendance threshold tracking across all registered lecture courses.</p>
                  </div>

                  <div className="table-container">
                    <table>
                      <thead>
                        <tr>
                          <th>Course Code</th>
                          <th>Course Title</th>
                          <th>Attended</th>
                          <th>Total Classes</th>
                          <th>Attendance %</th>
                          <th>Status</th>
                        </tr>
                      </thead>
                      <tbody>
                        {(data.subjectWise || []).map((s: any, idx: number) => {
                          const pct = Number(s.percentage || 0);
                          const eligible = pct >= 75.0;
                          return (
                            <tr key={idx}>
                              <td className="font-mono font-bold text-violet-600 dark:text-violet-400">{s.code}</td>
                              <td className="font-semibold">{s.name}</td>
                              <td className="font-mono">{s.attended_classes}</td>
                              <td className="font-mono">{s.total_classes}</td>
                              <td className="font-mono font-bold">{pct}%</td>
                              <td><Badge label={eligible ? "ELIGIBLE" : "SHORTAGE"} variant={eligible ? "success" : "danger"} /></td>
                            </tr>
                          );
                        })}
                      </tbody>
                    </table>
                  </div>

                  {/* 60-Day Heatmap */}
                  <div className="card p-6">
                    <h4 className="text-xs font-bold text-[#0B1020] dark:text-white uppercase tracking-wider mb-4">60-Day Session Heatmap</h4>
                    {(!data?.heatmap || !Array.isArray(data.heatmap) || data.heatmap.length === 0) ? (
                      <p className="text-xs text-[#64708A] text-center py-4">No recent attendance session logs found.</p>
                    ) : (
                      <div className="grid grid-cols-5 md:grid-cols-10 gap-2">
                        {(Array.isArray(data.heatmap) ? data.heatmap : []).map((h: any, i: number) => (
                          <div
                            key={i}
                            title={`${h.session_date} - ${h.course_code}: ${h.status}`}
                            className={`p-2 rounded-xl text-center text-[10px] font-mono font-bold ${
                              h.status === "PRESENT"
                                ? "bg-emerald-100 text-emerald-800 dark:bg-emerald-950/60 dark:text-emerald-300"
                                : "bg-rose-100 text-rose-800 dark:bg-rose-950/60 dark:text-rose-300"
                            }`}
                          >
                            <p className="text-[9px] opacity-75">{h.session_date.slice(5)}</p>
                            <p>{h.course_code}</p>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                </div>
              )}

              {/* TAB 5: RESULTS */}
              {tab === "results" && data && (
                <div className="space-y-4">
                  <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                    <div>
                      <h3 className="text-base font-bold text-[#0B1020] dark:text-white">Semester Grade Sheet</h3>
                      <p className="text-xs text-[#64708A]">Official UGC 10-point scale grade reports and credit-weighted SGPA/CGPA.</p>
                    </div>
                    <button
                      onClick={handleDownloadResultPdf}
                      disabled={downloadingPdf}
                      className="px-4 py-2 rounded-xl bg-violet-600 hover:bg-violet-700 text-white font-semibold text-xs shadow-md shadow-violet-600/20 flex items-center gap-2 transition disabled:opacity-50"
                    >
                      <Download className="w-4 h-4" /> {downloadingPdf ? "Generating PDF..." : "Download Official PDF"}
                    </button>
                  </div>

                  <div className="table-container">
                    <table>
                      <thead>
                        <tr>
                          <th>Course Code</th>
                          <th>Course Name</th>
                          <th>Credits</th>
                          <th>Grade</th>
                          <th>Grade Point</th>
                          <th>Result</th>
                        </tr>
                      </thead>
                      <tbody>
                        {(data.marks || []).map((m: any) => (
                          <tr key={m.id}>
                            <td className="font-mono font-bold text-violet-600 dark:text-violet-400">{m.course_code}</td>
                            <td className="font-semibold">{m.course_name}</td>
                            <td className="font-mono">{m.credits}</td>
                            <td className="font-mono font-bold">{m.grade}</td>
                            <td className="font-mono">{m.grade_point}</td>
                            <td><Badge label={m.is_pass ? "PASSED" : "ARREAR"} variant={m.is_pass ? "success" : "danger"} /></td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}

              {/* TAB 6: ARREARS */}
              {tab === "arrears" && data && (
                <div className="space-y-4">
                  <div>
                    <h3 className="text-base font-bold text-[#0B1020] dark:text-white">Arrear Registry & Re-Examinations</h3>
                    <p className="text-xs text-[#64708A]">Courses with grade F or absent. Register directly for upcoming scheduled re-exams.</p>
                  </div>

                  {(!data || !Array.isArray(data) || data.length === 0) ? (
                    <div className="card p-8 text-center text-xs text-[#64708A]">
                      <CheckCircle className="w-8 h-8 text-emerald-500 mx-auto mb-2" />
                      <p className="font-bold text-emerald-600 text-sm">No Pending Arrears</p>
                      <p>All enrolled courses have been successfully cleared.</p>
                    </div>
                  ) : (
                    <div className="table-container">
                      <table>
                        <thead>
                          <tr>
                            <th>Course Code</th>
                            <th>Course Name</th>
                            <th>Credits</th>
                            <th>Attempt Count</th>
                            <th>Status</th>
                            <th>Action</th>
                          </tr>
                        </thead>
                        <tbody>
                          {(Array.isArray(data) ? data : []).map((a: any) => (
                            <tr key={a.id}>
                              <td className="font-mono font-bold text-rose-600">{a.course_code}</td>
                              <td className="font-semibold">{a.course_name}</td>
                              <td className="font-mono">{a.credits}</td>
                              <td className="font-mono">{a.attempts_count}</td>
                              <td><Badge label={a.status} variant={a.status === "REGISTERED_FOR_REEXAM" ? "warning" : "danger"} /></td>
                              <td>
                                {a.status === "PENDING" && (
                                  <button
                                    onClick={() => handleRegisterReExam(a.id)}
                                    className="px-3 py-1 rounded bg-violet-600 hover:bg-violet-700 text-white font-semibold text-xs shadow-sm transition"
                                  >
                                    Register Re-Exam
                                  </button>
                                )}
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  )}
                </div>
              )}

              {/* TAB 7: FEES */}
              {tab === "fees" && data && (
                <div className="space-y-6">
                  <div>
                    <h3 className="text-base font-bold text-[#0B1020] dark:text-white">Fee Statements & Payment History</h3>
                    <p className="text-xs text-[#64708A]">Institutional fee ledgers, payment schedules, and verified digital receipts.</p>
                  </div>

                  <div className="table-container">
                    <table>
                      <thead>
                        <tr>
                          <th>Receipt No</th>
                          <th>Payment Date</th>
                          <th>Amount Paid</th>
                          <th>Payment Method</th>
                          <th>Transaction Ref</th>
                          <th>Receipt</th>
                        </tr>
                      </thead>
                      <tbody>
                        {(data.payments || []).map((p: any) => (
                          <tr key={p.id}>
                            <td className="font-mono font-bold text-violet-600 dark:text-violet-400">{p.receipt_number}</td>
                            <td className="text-xs text-[#64708A]">{p.payment_date}</td>
                            <td className="font-mono font-bold text-emerald-600">INR {Number(p.amount_paid).toLocaleString()}</td>
                            <td className="font-mono text-xs">{p.payment_mode}</td>
                            <td className="font-mono text-xs">{p.transaction_reference}</td>
                            <td>
                              <button
                                onClick={() => handleDownloadReceipt(p.id, p.receipt_number)}
                                className="p-1.5 rounded-lg bg-violet-50 dark:bg-violet-950 text-violet-600 hover:bg-violet-100 dark:hover:bg-violet-900 transition flex items-center gap-1 text-[11px]"
                              >
                                <Download className="w-3.5 h-3.5" /> PDF
                              </button>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}

              {/* TAB 8: PROFILE */}
              {tab === "profile" && data && (
                <div className="max-w-2xl space-y-6">
                  <div>
                    <h3 className="text-base font-bold text-[#0B1020] dark:text-white">Profile & Credentials</h3>
                    <p className="text-xs text-[#64708A]">Review registered academic identifiers and update personal contact details.</p>
                  </div>

                  <div className="card p-6 space-y-4">
                    <div className="grid grid-cols-2 gap-4 text-xs">
                      <div>
                        <span className="text-[#64708A] block">Full Name</span>
                        <span className="font-bold text-[#0B1020] dark:text-white text-sm">{data.profile?.full_name}</span>
                      </div>
                      <div>
                        <span className="text-[#64708A] block">Registration Number</span>
                        <span className="font-mono font-bold text-violet-600">{data.profile?.registration_number}</span>
                      </div>
                      <div>
                        <span className="text-[#64708A] block">College Email</span>
                        <span className="font-mono text-[#0B1020] dark:text-white">{data.user?.email}</span>
                      </div>
                      <div>
                        <span className="text-[#64708A] block">Programme / Dept</span>
                        <span className="text-[#0B1020] dark:text-white">{data.profile?.programme_name} ({data.profile?.department_name})</span>
                      </div>
                      <div>
                        <span className="text-[#64708A] block">Academic Bank of Credits (ABC ID)</span>
                        <span className="font-mono text-slate-700 dark:text-slate-300">{data.profile?.abc_id || "Not Provided"}</span>
                      </div>
                      <div>
                        <span className="text-[#64708A] block">Aadhaar (DPDP Masked)</span>
                        <span className="font-mono text-slate-700 dark:text-slate-300">XXXX-XXXX-1234</span>
                      </div>
                    </div>

                    <form onSubmit={handleSaveProfile} className="border-t border-[#E5E8F0] dark:border-[#1F293D] pt-4 space-y-3 text-xs">
                      <h4 className="font-bold text-xs uppercase tracking-wider text-[#0B1020] dark:text-white">Update Contact Details</h4>
                      <div>
                        <label className="block text-[#64708A] mb-1">Phone Number</label>
                        <input
                          type="text"
                          value={editPhone}
                          onChange={(e) => setEditPhone(e.target.value)}
                          className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent text-[#0B1020] dark:text-white"
                        />
                      </div>
                      <div>
                        <label className="block text-[#64708A] mb-1">Residential Address</label>
                        <textarea
                          rows={3}
                          value={editAddress}
                          onChange={(e) => setEditAddress(e.target.value)}
                          className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent text-[#0B1020] dark:text-white"
                        />
                      </div>
                      <button
                        type="submit"
                        className="px-4 py-2 rounded-xl bg-violet-600 hover:bg-violet-700 text-white font-semibold text-xs transition"
                      >
                        Save Contact Details
                      </button>
                    </form>
                  </div>
                </div>
              )}
            </>
          )}
        </div>
      </main>

      {/* Assignment Submit Modal */}
      {submitModalAssign && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
          <div className="bg-white dark:bg-[#11162A] w-full max-w-lg rounded-2xl border border-[#E5E8F0] dark:border-[#1F293D] shadow-2xl p-6 space-y-4">
            <div className="flex items-center justify-between border-b border-[#E5E8F0] dark:border-[#1F293D] pb-3">
              <div>
                <h3 className="font-bold text-sm text-[#0B1020] dark:text-white">Submit Assignment</h3>
                <p className="text-xs text-[#64708A]">{submitModalAssign.title}</p>
              </div>
              <button onClick={() => setSubmitModalAssign(null)} className="p-1 text-slate-400">
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleSubmitAssignment} className="space-y-3 text-xs">
              <div>
                <label className="block text-[#64708A] mb-1">Submission Notes / Written Response</label>
                <textarea
                  rows={4}
                  required
                  value={subText}
                  onChange={(e) => setSubText(e.target.value)}
                  placeholder="Enter your answers or submission overview here..."
                  className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent text-[#0B1020] dark:text-white"
                />
              </div>
              <div>
                <label className="block text-[#64708A] mb-1">Attachment URL / Drive Link (Optional)</label>
                <input
                  type="url"
                  value={subFileUrl}
                  onChange={(e) => setSubFileUrl(e.target.value)}
                  placeholder="https://drive.google.com/your-submission.pdf"
                  className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent text-[#0B1020] dark:text-white"
                />
              </div>
              <div className="pt-2 flex justify-end gap-2">
                <button
                  type="button"
                  onClick={() => setSubmitModalAssign(null)}
                  className="px-4 py-2 rounded-xl border border-slate-200 dark:border-slate-800 text-slate-600 dark:text-slate-300"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={submitting}
                  className="px-4 py-2 rounded-xl bg-violet-600 hover:bg-violet-700 text-white font-semibold disabled:opacity-50"
                >
                  {submitting ? "Uploading..." : "Confirm & Submit"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Password Change Modal */}
      <PasswordChangeModal
        isOpen={pwdModalOpen}
        onClose={() => setPwdModalOpen(false)}
        onDone={() => setToast({ msg: "Password changed successfully.", type: "success" })}
      />

      {toast && <Toast message={toast.msg} type={toast.type} onClose={() => setToast(null)} />}
    </div>
  );
}
