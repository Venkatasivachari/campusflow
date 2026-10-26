import React, { useState, useEffect } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import { BookOpen, Calendar, Clock, CheckCircle, Users, DollarSign, LogOut, Menu, X } from "lucide-react";
import { api, clearAuth } from "./api";
import { StatCard, Badge, Toast } from "./ui";

export function FacultyPortal() {
  const navigate = useNavigate();
  const location = useLocation();

  // Extract tab from URL (e.g. /faculty/courses -> "courses")
  const pathSegments = location.pathname.split("/").filter(Boolean);
  const tab = pathSegments[1] || "dashboard";

  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [toast, setToast] = useState<{ msg: string; type: "success" | "error" | "info" } | null>(null);
  const [mobileOpen, setMobileOpen] = useState(false);

  // Attendance modal state
  const [attendanceOffering, setAttendanceOffering] = useState<any>(null);
  const [studentList, setStudentList] = useState<any[]>([]);
  const [attendanceRecords, setAttendanceRecords] = useState<Record<number, boolean>>({});

  useEffect(() => {
    loadTab(tab);
  }, [tab]);

  async function loadTab(t: string) {
    setLoading(true);
    try {
      if (t === "dashboard") {
        const res = await api.faculty.getDashboard();
        setData(res);
      } else if (t === "courses") {
        const res = await api.faculty.getCourses();
        setData(res);
      } else if (t === "timetable") {
        const res = await api.faculty.getTimetable();
        setData(res);
      } else if (t === "payslips") {
        const res = await api.faculty.getPayslips();
        setData(res);
      }
    } catch (err: any) {
      setToast({ msg: err.message, type: "error" });
    } finally {
      setLoading(false);
    }
  }

  async function openAttendanceModal(offering: any) {
    try {
      const students = await api.faculty.getCourseStudents(offering.offering_id || offering.id);
      setStudentList(students);
      const initial: Record<number, boolean> = {};
      students.forEach((s: any) => { initial[s.id] = true; });
      setAttendanceRecords(initial);
      setAttendanceOffering(offering);
    } catch (err: any) {
      setToast({ msg: err.message, type: "error" });
    }
  }

  async function submitAttendance() {
    try {
      const records = studentList.map((s) => ({
        studentId: s.id,
        status: attendanceRecords[s.id] ? "PRESENT" : "ABSENT",
      }));
      await api.faculty.markAttendance({
        offeringId: attendanceOffering.offering_id || attendanceOffering.id,
        periodNumber: 1,
        topicCovered: "Curriculum Lecture Session",
        records,
      });
      setToast({ msg: "Attendance registered successfully in database.", type: "success" });
      setAttendanceOffering(null);
      loadTab("dashboard");
    } catch (err: any) {
      setToast({ msg: err.message || "Failed to submit attendance.", type: "error" });
    }
  }

  const navItems = [
    { id: "dashboard", label: "Overview", icon: Users },
    { id: "courses", label: "My Classes & Attendance", icon: BookOpen },
    { id: "timetable", label: "Teaching Timetable", icon: Calendar },
    { id: "payslips", label: "My Payslips", icon: DollarSign },
  ];

  return (
    <div className="flex h-screen bg-[#F6F7FB] dark:bg-[#0B1020] overflow-hidden">
      {/* Mobile Drawer Overlay */}
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
              <div className="w-9 h-9 rounded-xl bg-teal-600 flex items-center justify-center text-white font-bold shadow-md shadow-teal-500/20">
                FAC
              </div>
              <div>
                <span className="font-bold text-sm text-[#0B1020] dark:text-white font-heading">Faculty Portal</span>
                <span className="block text-[10px] text-teal-600 font-mono">ACADEMIC V2</span>
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
                    navigate(`/faculty/${item.id}`);
                    setMobileOpen(false);
                  }}
                  className={`w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-xs font-semibold transition ${
                    active
                      ? "bg-teal-600 text-white shadow-sm shadow-teal-600/30"
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
            onClick={() => { clearAuth(); window.location.href = "/faculty/login"; }}
            className="w-full flex items-center justify-center gap-2 py-2 px-3 rounded-xl text-xs font-semibold text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/40 border border-rose-200 dark:border-rose-900 transition"
          >
            <LogOut className="w-3.5 h-3.5" /> Sign Out
          </button>
        </div>
      </aside>

      {/* Main Content */}
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
            <h1 className="text-lg font-bold text-[#0B1020] dark:text-white capitalize">Faculty {tab}</h1>
          </div>
          <div className="flex items-center gap-3">
            <span className="text-xs px-2.5 py-1 rounded-full bg-teal-50 dark:bg-teal-950 text-teal-700 dark:text-teal-300 font-mono font-semibold">
              ROLE_FACULTY
            </span>
            <button
              onClick={() => { clearAuth(); window.location.href = "/faculty/login"; }}
              className="hidden md:flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/40 border border-rose-200 dark:border-rose-900 transition"
            >
              <LogOut className="w-3.5 h-3.5" /> Sign Out
            </button>
          </div>
        </header>

        <div className="p-4 md:p-8 max-w-6xl mx-auto space-y-6">
          {tab === "dashboard" && data && (
            <div className="space-y-6">
              <div className="p-6 rounded-2xl bg-gradient-to-r from-teal-700 via-teal-600 to-emerald-700 text-white shadow-xl flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                <div>
                  <span className="text-xs font-mono tracking-widest uppercase text-teal-200">Faculty Workspace</span>
                  <h2 className="text-2xl font-extrabold mt-0.5">{data.profile?.full_name}</h2>
                  <p className="text-xs text-white/80 mt-1 font-mono">
                    {data.profile?.employee_id} • {data.profile?.designation} • {data.profile?.department_name}
                  </p>
                </div>
                <div className="bg-white/10 backdrop-blur px-5 py-3 rounded-xl border border-white/20 text-center">
                  <span className="text-[11px] text-white/70 block uppercase font-mono">Assigned Courses</span>
                  <span className="text-2xl font-bold font-mono">{(data.courses || []).length}</span>
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {/* Today's Lectures */}
                <div className="card p-6">
                  <h3 className="text-sm font-bold text-[#0B1020] dark:text-white mb-4 flex items-center gap-2">
                    <Clock className="w-4 h-4 text-teal-600" /> Today's Scheduled Lectures
                  </h3>
                  {(data.todaySchedule || []).length === 0 ? (
                    <p className="text-xs text-[#64708A] py-6 text-center">No scheduled teaching sessions today.</p>
                  ) : (
                    <div className="space-y-2.5">
                      {data.todaySchedule.map((s: any, i: number) => (
                        <div key={i} className="flex items-center justify-between p-3 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] text-xs">
                          <div>
                            <span className="font-bold text-[#0B1020] dark:text-white block">{s.course_name} ({s.course_code})</span>
                            <span className="text-[#64708A]">{s.start_time} - {s.end_time} • Room {s.room_number}</span>
                          </div>
                          <span className="font-mono font-semibold text-teal-600">Period {s.period_number}</span>
                        </div>
                      ))}
                    </div>
                  )}
                </div>

                {/* Quick Attendance Launcher */}
                <div className="card p-6 flex flex-col justify-between">
                  <div>
                    <h3 className="text-sm font-bold text-[#0B1020] dark:text-white mb-4 flex items-center gap-2">
                      <CheckCircle className="w-4 h-4 text-emerald-600" /> 1-Tap Attendance Marking
                    </h3>
                    <p className="text-xs text-[#64708A] mb-4">
                      Select a course offering to immediately launch today's class roll call and update student percentages in MySQL.
                    </p>
                    <div className="space-y-2">
                      {(data.courses || []).map((c: any) => (
                        <button
                          key={c.offering_id || c.id}
                          onClick={() => openAttendanceModal(c)}
                          className="w-full flex justify-between items-center p-3 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] text-xs font-semibold hover:border-teal-500 hover:bg-teal-50/50 dark:hover:bg-teal-950/20 transition"
                        >
                          <span>{c.code}: {c.name}</span>
                          <span className="text-teal-600">Mark Attendance →</span>
                        </button>
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {tab === "courses" && data && (
            <div className="space-y-4">
              <h2 className="text-base font-bold text-[#0B1020] dark:text-white">Assigned Course Offerings</h2>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {(data || []).map((c: any) => (
                  <div key={c.offering_id || c.id} className="card p-5 flex flex-col justify-between">
                    <div>
                      <div className="flex justify-between items-start mb-2">
                        <span className="font-mono font-bold text-teal-600 dark:text-teal-400 text-sm">{c.code}</span>
                        <Badge label={`${c.credits} Credits`} variant="info" />
                      </div>
                      <h3 className="font-bold text-sm text-[#0B1020] dark:text-white">{c.name}</h3>
                      <p className="text-xs text-[#64708A] mt-1 font-mono">Academic Year {c.academic_year || "2026"} • Section A</p>
                    </div>
                    <div className="mt-4 pt-4 border-t border-[#E5E8F0] dark:border-[#1F293D] flex justify-between items-center">
                      <span className="text-xs text-[#64708A]">Total Enrolled: <b>{c.enrolled_count || 15}</b></span>
                      <button
                        onClick={() => openAttendanceModal(c)}
                        className="px-3 py-1.5 rounded-lg bg-teal-600 hover:bg-teal-700 text-white text-xs font-semibold shadow-sm transition"
                      >
                        Class Attendance
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {tab === "timetable" && data && (
            <div className="space-y-4">
              <h2 className="text-base font-bold text-[#0B1020] dark:text-white">Weekly Teaching Schedule</h2>
              <div className="table-container">
                <table>
                  <thead>
                    <tr>
                      <th>Day</th>
                      <th>Period</th>
                      <th>Time Window</th>
                      <th>Course Code</th>
                      <th>Course Name</th>
                      <th>Room</th>
                    </tr>
                  </thead>
                  <tbody>
                    {(data || []).map((t: any, i: number) => {
                      const days = ["", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
                      return (
                        <tr key={i}>
                          <td className="font-semibold text-[#0B1020] dark:text-white">{days[t.day_of_week] || `Day ${t.day_of_week}`}</td>
                          <td className="font-mono font-bold">Period {t.period_number}</td>
                          <td className="font-mono text-xs">{t.start_time} - {t.end_time}</td>
                          <td className="font-mono font-bold text-teal-600">{t.course_code}</td>
                          <td>{t.course_name}</td>
                          <td className="font-mono">{t.room_number}</td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {tab === "payslips" && data && (
            <div className="space-y-4">
              <h2 className="text-base font-bold text-[#0B1020] dark:text-white">Personal Monthly Payslips</h2>
              <div className="table-container">
                <table>
                  <thead>
                    <tr>
                      <th>Month / Year</th>
                      <th>Basic Pay</th>
                      <th>HRA</th>
                      <th>DA</th>
                      <th>Deductions</th>
                      <th>Net Disbursed</th>
                      <th>Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    {(data || []).map((p: any) => (
                      <tr key={p.id}>
                        <td className="font-bold text-[#0B1020] dark:text-white">{p.month_year}</td>
                        <td className="font-mono">INR {Number(p.basic).toLocaleString()}</td>
                        <td className="font-mono">INR {Number(p.hra).toLocaleString()}</td>
                        <td className="font-mono">INR {Number(p.da).toLocaleString()}</td>
                        <td className="font-mono">INR {Number(p.deductions).toLocaleString()}</td>
                        <td className="font-mono font-bold text-emerald-600">INR {Number(p.net_amount).toLocaleString()}</td>
                        <td><Badge label={p.payroll_status || "PAID"} variant="success" /></td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </div>
      </main>

      {/* Attendance Modal */}
      {attendanceOffering && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
          <div className="bg-white dark:bg-[#11162A] rounded-2xl max-w-xl w-full border border-[#E5E8F0] dark:border-[#1F293D] shadow-2xl p-6 max-h-[85vh] flex flex-col">
            <div className="flex justify-between items-center pb-3 border-b border-[#E5E8F0] dark:border-[#1F293D]">
              <div>
                <h3 className="text-base font-bold text-[#0B1020] dark:text-white">Mark Attendance</h3>
                <p className="text-xs text-[#64708A]">{attendanceOffering.course_name || attendanceOffering.name} • Today's Roll Call</p>
              </div>
              <button onClick={() => setAttendanceOffering(null)} className="text-slate-400 text-lg">✕</button>
            </div>

            <div className="overflow-y-auto flex-1 my-4 space-y-2 pr-1">
              {studentList.map((s) => (
                <div key={s.id} className="flex items-center justify-between p-3 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] text-xs">
                  <div>
                    <span className="font-bold text-[#0B1020] dark:text-white block">{s.full_name}</span>
                    <span className="font-mono text-[#64708A]">{s.registration_number} • Current: {s.attendance_percentage || 100}%</span>
                  </div>
                  <button
                    type="button"
                    onClick={() => setAttendanceRecords({ ...attendanceRecords, [s.id]: !attendanceRecords[s.id] })}
                    className={`px-3 py-1.5 rounded-lg font-bold text-xs transition ${
                      attendanceRecords[s.id]
                        ? "bg-emerald-600 text-white"
                        : "bg-rose-600 text-white"
                    }`}
                  >
                    {attendanceRecords[s.id] ? "PRESENT" : "ABSENT"}
                  </button>
                </div>
              ))}
            </div>

            <div className="pt-3 border-t border-[#E5E8F0] dark:border-[#1F293D] flex justify-end gap-2">
              <button
                type="button"
                onClick={() => setAttendanceOffering(null)}
                className="px-4 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] text-xs font-semibold"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={submitAttendance}
                className="px-4 py-2 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-semibold text-xs shadow-md transition"
              >
                Submit Attendance to Database
              </button>
            </div>
          </div>
        </div>
      )}

      {toast && <Toast message={toast.msg} type={toast.type} onClose={() => setToast(null)} />}
    </div>
  );
}
