import React, { useState, useEffect } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import {
  GraduationCap, Calendar, Clock, BookOpen, AlertTriangle, CheckCircle,
  DollarSign, FileText, Download, ShieldCheck, LogOut, ArrowRight, Bell, Menu, X
} from "lucide-react";
import { api, clearAuth, downloadBlob } from "./api";
import { StatCard, Badge, Toast } from "./ui";

export function StudentPortal() {
  const navigate = useNavigate();
  const location = useLocation();

  // Extract active tab from URL path (e.g. /student/results -> "results")
  const pathSegments = location.pathname.split("/").filter(Boolean);
  const tab = pathSegments[1] || "dashboard";

  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [toast, setToast] = useState<{ msg: string; type: "success" | "error" | "info" } | null>(null);
  const [mobileOpen, setMobileOpen] = useState(false);
  const [downloadingPdf, setDownloadingPdf] = useState(false);

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

  const navItems = [
    { id: "dashboard", label: "My Dashboard", icon: GraduationCap },
    { id: "attendance", label: "Attendance & Heatmap", icon: Calendar },
    { id: "results", label: "Grades & Results", icon: FileText },
    { id: "arrears", label: "Arrears & Re-Exams", icon: AlertTriangle },
    { id: "fees", label: "Fee Statements", icon: DollarSign },
  ];

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
                STU
              </div>
              <div>
                <span className="font-bold text-sm text-[#0B1020] dark:text-white font-heading">Campus Student</span>
                <span className="block text-[10px] text-violet-600 font-mono">PORTAL V2</span>
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
                    navigate(`/student/${item.id}`);
                    setMobileOpen(false);
                  }}
                  className={`w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-xs font-semibold transition ${
                    active
                      ? "bg-violet-600 text-white shadow-sm shadow-violet-600/30"
                      : "text-[#64708A] hover:bg-slate-100 dark:hover:bg-slate-800 hover:text-[#0B1020] dark:hover:text-white"
                  }`}
                >
                  <Icon className="w-4 h-4" />
                  <span>{item.label}</span>
                </button>
              );
            })}
          </nav>
        </div>

        <div className="p-4 border-t border-[#E5E8F0] dark:border-[#1F293D]">
          <button
            onClick={() => { clearAuth(); window.location.href = "/student/login"; }}
            className="w-full flex items-center justify-center gap-2 py-2 px-3 rounded-xl text-xs font-semibold text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/30 border border-rose-200 dark:border-rose-900 transition"
          >
            <LogOut className="w-4 h-4" /> Sign Out
          </button>
        </div>
      </aside>

      {/* Main View */}
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
            <div>
              <h1 className="text-lg font-bold text-[#0B1020] dark:text-white">Student Academic Center</h1>
              <p className="text-[11px] text-[#64708A]">Imperial Institute of Technology • UGC Autonomous</p>
            </div>
          </div>
          <div className="flex items-center gap-3">
            <span className="text-xs px-2.5 py-1 rounded-full bg-violet-50 dark:bg-violet-950 text-violet-700 dark:text-violet-300 font-mono font-semibold">
              ROLE_STUDENT
            </span>
            <button
              onClick={() => { clearAuth(); window.location.href = "/student/login"; }}
              className="hidden md:flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/30 border border-rose-200 dark:border-rose-900 transition"
            >
              <LogOut className="w-3.5 h-3.5" /> Sign Out
            </button>
          </div>
        </header>

        <div className="p-4 md:p-8 max-w-6xl mx-auto space-y-6">
          {tab === "dashboard" && data && (
            <div className="space-y-6">
              {/* Greeting & Academic Summary */}
              <div className="p-6 rounded-2xl bg-gradient-to-r from-violet-600 via-indigo-600 to-purple-700 text-white shadow-xl flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                <div>
                  <span className="text-xs font-mono tracking-widest uppercase text-violet-200">Welcome Back</span>
                  <h2 className="text-2xl font-extrabold mt-0.5">{data.profile?.full_name || "Student"}</h2>
                  <p className="text-xs text-white/80 mt-1 font-mono">
                    {data.profile?.registration_number} • {data.profile?.programme_name} (Sem {data.profile?.current_semester})
                  </p>
                </div>
                <div className="flex gap-4">
                  <div className="bg-white/10 backdrop-blur px-4 py-2.5 rounded-xl border border-white/20 text-center">
                    <span className="text-[11px] text-white/70 block uppercase font-mono">Cumulative CGPA</span>
                    <span className="text-xl font-bold font-mono">{data.profile?.current_cgpa || "0.00"}</span>
                  </div>
                  <div className="bg-white/10 backdrop-blur px-4 py-2.5 rounded-xl border border-white/20 text-center">
                    <span className="text-[11px] text-white/70 block uppercase font-mono">Attendance</span>
                    <span className="text-xl font-bold font-mono">{data.profile?.attendance_percentage || "100"}%</span>
                  </div>
                </div>
              </div>

              {/* Arrear Warning Notice (if any) */}
              {(data.activeArrears || []).length > 0 && (
                <div className="p-4 rounded-xl bg-amber-50 dark:bg-amber-950/40 border border-amber-200 dark:border-amber-900 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
                  <div className="flex items-center gap-3">
                    <AlertTriangle className="w-5 h-5 text-amber-600 shrink-0" />
                    <div>
                      <h4 className="text-xs font-bold text-amber-900 dark:text-amber-200">Pending Arrear Course Notice</h4>
                      <p className="text-xs text-amber-700 dark:text-amber-300">
                        You have {data.activeArrears.length} pending course arrear(s). Re-examination registration is currently open.
                      </p>
                    </div>
                  </div>
                  <button
                    onClick={() => navigate("/student/arrears")}
                    className="px-3 py-1.5 rounded-lg bg-amber-600 hover:bg-amber-700 text-white font-semibold text-xs shadow-sm transition"
                  >
                    View Arrears
                  </button>
                </div>
              )}

              {/* Cards Grid */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {/* Today's Timetable */}
                <div className="card p-6">
                  <h3 className="text-sm font-bold text-[#0B1020] dark:text-white mb-4 flex items-center gap-2">
                    <Clock className="w-4 h-4 text-violet-600" /> Today's Classes
                  </h3>
                  {(data.todayClasses || []).length === 0 ? (
                    <p className="text-xs text-[#64708A] py-6 text-center">No scheduled lectures today.</p>
                  ) : (
                    <div className="space-y-2.5">
                      {data.todayClasses.map((c: any, i: number) => (
                        <div key={i} className="flex items-center justify-between p-3 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] text-xs">
                          <div>
                            <span className="font-bold text-[#0B1020] dark:text-white block">{c.course_name} ({c.course_code})</span>
                            <span className="text-[#64708A]">{c.start_time} - {c.end_time} • Room {c.room_number}</span>
                          </div>
                          <span className="font-mono font-semibold text-violet-600">Period {c.period_number}</span>
                        </div>
                      ))}
                    </div>
                  )}
                </div>

                {/* Fee Summary */}
                <div className="card p-6 flex flex-col justify-between">
                  <div>
                    <h3 className="text-sm font-bold text-[#0B1020] dark:text-white mb-4 flex items-center gap-2">
                      <DollarSign className="w-4 h-4 text-emerald-600" /> Tuition Fee Status
                    </h3>
                    <div className="space-y-3">
                      <div className="flex justify-between text-xs">
                        <span className="text-[#64708A]">Total Semester Fee:</span>
                        <span className="font-mono font-bold">INR {Number(data.feeSummary?.total_payable || 0).toLocaleString()}</span>
                      </div>
                      <div className="flex justify-between text-xs">
                        <span className="text-[#64708A]">Paid to Date:</span>
                        <span className="font-mono font-bold text-emerald-600">INR {Number(data.feeSummary?.total_paid || 0).toLocaleString()}</span>
                      </div>
                      <div className="flex justify-between text-xs pt-2 border-t border-[#E5E8F0] dark:border-[#1F293D]">
                        <span className="font-bold text-[#0B1020] dark:text-white">Outstanding Balance:</span>
                        <span className="font-mono font-bold text-rose-600 text-sm">
                          INR {Number(data.feeSummary?.balance_due || 0).toLocaleString()}
                        </span>
                      </div>
                    </div>
                  </div>
                  <div className="mt-4 pt-4 border-t border-[#E5E8F0] dark:border-[#1F293D] flex justify-end">
                    <button onClick={() => navigate("/student/fees")} className="text-xs font-semibold text-violet-600 hover:underline flex items-center gap-1">
                      View Payment History & Receipts <ArrowRight className="w-3.5 h-3.5" />
                    </button>
                  </div>
                </div>
              </div>

              {/* Latest Announcements */}
              <div className="card p-6">
                <h3 className="text-sm font-bold text-[#0B1020] dark:text-white mb-3 flex items-center gap-2">
                  <Bell className="w-4 h-4 text-indigo-600" /> Campus Notices & Announcements
                </h3>
                <div className="space-y-2.5">
                  {(data.announcements || []).map((a: any) => (
                    <div key={a.id} className="p-3.5 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D]">
                      <div className="flex items-center justify-between mb-1">
                        <span className="font-bold text-xs text-[#0B1020] dark:text-white">{a.title}</span>
                        <Badge label={a.priority} variant={a.priority === "URGENT" ? "danger" : "info"} />
                      </div>
                      <p className="text-xs text-[#64708A]">{a.content}</p>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {tab === "attendance" && data && (
            <div className="space-y-6">
              <div>
                <h3 className="text-base font-bold text-[#0B1020] dark:text-white">Course-wise Attendance Breakdown</h3>
                <p className="text-xs text-[#64708A]">Statutory UGC requirement: minimum 75% attendance for examination eligibility.</p>
              </div>

              <div className="table-container">
                <table>
                  <thead>
                    <tr>
                      <th>Course Code</th>
                      <th>Course Name</th>
                      <th>Total Lectures</th>
                      <th>Attended</th>
                      <th>Percentage</th>
                      <th>Requirement Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    {(data.subjectWise || []).map((s: any, i: number) => {
                      const pct = Number(s.percentage || 100);
                      return (
                        <tr key={i}>
                          <td className="font-mono font-bold text-violet-600 dark:text-violet-400">{s.code}</td>
                          <td className="font-semibold text-[#0B1020] dark:text-white">{s.name}</td>
                          <td className="font-mono">{s.total_classes}</td>
                          <td className="font-mono">{s.attended_classes}</td>
                          <td className="font-mono font-bold">{pct}%</td>
                          <td>
                            <Badge
                              label={pct >= 75 ? "ELIGIBLE" : "SHORTAGE (<75%)"}
                              variant={pct >= 75 ? "success" : "danger"}
                            />
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {tab === "results" && data && (
            <div className="space-y-6">
              <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
                <div>
                  <h3 className="text-base font-bold text-[#0B1020] dark:text-white">Semester Grade Sheet</h3>
                  <p className="text-xs text-[#64708A]">Official UGC 10-point credit weighted scale</p>
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

          {tab === "arrears" && data && (
            <div className="space-y-4">
              <div>
                <h3 className="text-base font-bold text-[#0B1020] dark:text-white">Arrear Registry & Re-Examinations</h3>
                <p className="text-xs text-[#64708A]">Courses with grade F or absent. Register directly for upcoming scheduled re-exams.</p>
              </div>

              {data.length === 0 ? (
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
                      {data.map((a: any) => (
                        <tr key={a.id}>
                          <td className="font-mono font-bold text-rose-600">{a.course_code}</td>
                          <td className="font-semibold">{a.course_name}</td>
                          <td className="font-mono">{a.credits}</td>
                          <td className="font-mono">{a.attempt_count}</td>
                          <td><Badge label={a.status} variant={a.status === "REGISTERED" ? "warning" : "danger"} /></td>
                          <td>
                            {a.status === "FAILED" && (
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
                      <th>Status</th>
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
                        <td><Badge label="VERIFIED" variant="success" /></td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </div>
      </main>

      {toast && <Toast message={toast.msg} type={toast.type} onClose={() => setToast(null)} />}
    </div>
  );
}
