import React, { useState, useEffect } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import {
  BookOpen, Calendar, Clock, CheckCircle, Users, DollarSign, LogOut, Menu, X,
  FileCheck, Download, Plus, Award, User, Key, Check
} from "lucide-react";
import { api, clearAuth, downloadBlob } from "./api";
import { StatCard, Badge, Toast, ThemeToggle, NotificationBell, PasswordChangeModal } from "./ui";

export function FacultyPortal() {
  const navigate = useNavigate();
  const location = useLocation();

  const pathSegments = location.pathname.split("/").filter(Boolean);
  const tab = pathSegments[1] || "dashboard";

  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [toast, setToast] = useState<{ msg: string; type: "success" | "error" | "info" } | null>(null);
  const [mobileOpen, setMobileOpen] = useState(false);
  const [pwdModalOpen, setPwdModalOpen] = useState(false);

  // Attendance modal state
  const [attendanceOffering, setAttendanceOffering] = useState<any>(null);
  const [studentList, setStudentList] = useState<any[]>([]);
  const [attendanceRecords, setAttendanceRecords] = useState<Record<number, boolean>>({});

  // Assignment modal states
  const [createAssignModal, setCreateAssignModal] = useState(false);
  const [myOfferings, setMyOfferings] = useState<any[]>([]);
  const [newAssign, setNewAssign] = useState({
    offeringId: "",
    title: "",
    instructions: "",
    dueDate: "",
    maxMarks: 100,
  });
  const [submissionsModalAssign, setSubmissionsModalAssign] = useState<any>(null);
  const [submissionList, setSubmissionList] = useState<any[]>([]);
  const [gradingState, setGradingState] = useState<Record<number, { marks: number; feedback: string }>>({});

  // Marks Entry state
  const [selectedOfferingId, setSelectedOfferingId] = useState<number | null>(null);
  const [marksData, setMarksData] = useState<any>(null);
  const [editingMarks, setEditingMarks] = useState<Record<number, { internal: number; external: number }>>({});
  const [savingMarks, setSavingMarks] = useState(false);

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
      } else if (t === "assignments") {
        const [assigns, courses] = await Promise.all([
          api.faculty.getAssignments(),
          api.faculty.getCourses(),
        ]);
        setData(assigns);
        setMyOfferings(courses);
        if (courses.length > 0 && !newAssign.offeringId) {
          setNewAssign((prev) => ({ ...prev, offeringId: String(courses[0].offering_id) }));
        }
      } else if (t === "marks") {
        const courses = await api.faculty.getCourses();
        setMyOfferings(courses);
        if (courses.length > 0) {
          const offId = selectedOfferingId || courses[0].offering_id;
          setSelectedOfferingId(offId);
          await loadMarksForOffering(offId);
        }
      } else if (t === "profile") {
        const res = await api.getMe();
        setData(res);
      }
    } catch (err: any) {
      setToast({ msg: err.message, type: "error" });
    } finally {
      setLoading(false);
    }
  }

  async function loadMarksForOffering(offeringId: number) {
    try {
      const res = await api.faculty.getCourseMarks(offeringId);
      setMarksData(res);
      const initialMarks: Record<number, { internal: number; external: number }> = {};
      (res.students || []).forEach((st: any) => {
        initialMarks[st.student_id] = {
          internal: Number(st.internal_marks || 0),
          external: Number(st.external_marks || 0),
        };
      });
      setEditingMarks(initialMarks);
    } catch (err: any) {
      setToast({ msg: err.message || "Failed to load marks", type: "error" });
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
      setToast({ msg: "Attendance registered successfully.", type: "success" });
      setAttendanceOffering(null);
      loadTab("dashboard");
    } catch (err: any) {
      setToast({ msg: err.message || "Failed to submit attendance.", type: "error" });
    }
  }

  async function handleCreateAssignment(e: React.FormEvent) {
    e.preventDefault();
    try {
      await api.faculty.createAssignment({
        offeringId: Number(newAssign.offeringId),
        title: newAssign.title,
        instructions: newAssign.instructions,
        dueDate: newAssign.dueDate,
        maxMarks: Number(newAssign.maxMarks),
      });
      setToast({ msg: "Assignment published and students notified.", type: "success" });
      setCreateAssignModal(false);
      setNewAssign({ offeringId: String(myOfferings[0]?.offering_id || ""), title: "", instructions: "", dueDate: "", maxMarks: 100 });
      loadTab("assignments");
    } catch (err: any) {
      setToast({ msg: err.message || "Failed to create assignment.", type: "error" });
    }
  }

  async function openSubmissionsModal(assign: any) {
    try {
      const subs = await api.faculty.getSubmissions(assign.id);
      setSubmissionList(subs);
      setSubmissionsModalAssign(assign);
      const grades: Record<number, { marks: number; feedback: string }> = {};
      subs.forEach((s: any) => {
        grades[s.id] = {
          marks: Number(s.marks_obtained || assign.max_marks),
          feedback: s.feedback || "Satisfactory work.",
        };
      });
      setGradingState(grades);
    } catch (err: any) {
      setToast({ msg: err.message || "Failed to fetch submissions.", type: "error" });
    }
  }

  async function handleGradeSubmission(subId: number) {
    const item = gradingState[subId];
    if (!item) return;
    try {
      await api.faculty.gradeSubmission(subId, {
        marksObtained: item.marks,
        feedback: item.feedback,
      });
      setToast({ msg: "Grade recorded and student notified.", type: "success" });
      const updated = await api.faculty.getSubmissions(submissionsModalAssign.id);
      setSubmissionList(updated);
    } catch (err: any) {
      setToast({ msg: err.message || "Failed to save grade.", type: "error" });
    }
  }

  async function handleSaveMarks() {
    if (!selectedOfferingId) return;
    setSavingMarks(true);
    try {
      const marksPayload = Object.entries(editingMarks).map(([studentId, val]) => ({
        studentId: Number(studentId),
        internalMarks: val.internal,
        externalMarks: val.external,
      }));
      await api.faculty.saveCourseMarks(selectedOfferingId, {
        examId: 1,
        marks: marksPayload,
      });
      setToast({ msg: "Course marks saved successfully.", type: "success" });
      await loadMarksForOffering(selectedOfferingId);
    } catch (err: any) {
      setToast({ msg: err.message || "Failed to save marks.", type: "error" });
    } finally {
      setSavingMarks(false);
    }
  }

  const navItems = [
    { id: "dashboard", label: "Overview", icon: Users },
    { id: "courses", label: "Classes & Attendance", icon: BookOpen },
    { id: "assignments", label: "Assignments & Grading", icon: FileCheck },
    { id: "marks", label: "Marks & Grades Entry", icon: Award },
    { id: "timetable", label: "Teaching Timetable", icon: Calendar },
    { id: "payslips", label: "My Payslips", icon: DollarSign },
    { id: "profile", label: "Profile & Settings", icon: User },
  ];

  const daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];

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
                <BookOpen className="w-5 h-5" />
              </div>
              <div>
                <h2 className="text-sm font-bold text-[#0B1020] dark:text-white font-heading">CampusFlow</h2>
                <p className="text-[10px] text-teal-600 dark:text-teal-400 font-mono tracking-wider uppercase font-semibold">Faculty Portal</p>
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
                    navigate(`/faculty/${item.id}`);
                    setMobileOpen(false);
                  }}
                  className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold transition ${
                    active
                      ? "bg-teal-50 dark:bg-teal-950/40 text-teal-700 dark:text-teal-300 shadow-sm border border-teal-100 dark:border-teal-900"
                      : "text-[#64708A] hover:bg-slate-100 dark:hover:bg-slate-800/60 hover:text-[#0B1020] dark:hover:text-white"
                  }`}
                >
                  <Icon className={`w-4 h-4 ${active ? "text-teal-600 dark:text-teal-400" : ""}`} />
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
              window.location.href = "/faculty/login";
            }}
            className="w-full flex items-center justify-center gap-2 py-2 px-3 rounded-xl text-xs font-semibold text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/40 border border-rose-200 dark:border-rose-900 transition"
          >
            <LogOut className="w-3.5 h-3.5" /> Sign Out
          </button>
        </div>
      </aside>

      {/* Main View Area */}
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
                window.location.href = "/faculty/login";
              }}
              className="hidden md:flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/40 border border-rose-200 dark:border-rose-900 transition"
            >
              <LogOut className="w-3.5 h-3.5" /> Exit
            </button>
          </div>
        </header>

        <div className="p-4 md:p-8 max-w-6xl mx-auto space-y-6">
          {loading ? (
            <div className="p-12 text-center text-xs text-[#64708A]">Loading faculty curriculum data...</div>
          ) : (
            <>
              {/* TAB 1: DASHBOARD */}
              {tab === "dashboard" && data && (
                <div className="space-y-6">
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <StatCard title="Courses Assigned" value={data.stats?.coursesTaught || 0} subtitle="Current active semester" icon={BookOpen} color="teal" />
                    <StatCard title="Total Students" value={data.stats?.totalStudents || 0} subtitle="Under instruction" icon={Users} color="indigo" />
                    <StatCard title="Pending Grading" value={data.stats?.pendingGrading || 0} subtitle="Ungraded submissions" icon={CheckCircle} color={data.stats?.pendingGrading > 0 ? "amber" : "emerald"} />
                  </div>

                  {/* Today's Classes */}
                  <div className="card p-6">
                    <h3 className="text-sm font-bold text-[#0B1020] dark:text-white mb-4">Today's Teaching Schedule</h3>
                    {(data.todayClasses || []).length === 0 ? (
                      <p className="text-xs text-[#64708A] text-center py-4">No lecture periods scheduled for today.</p>
                    ) : (
                      <div className="space-y-3">
                        {data.todayClasses.map((c: any, i: number) => (
                          <div key={i} className="p-4 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] flex items-center justify-between text-xs">
                            <div className="flex items-center gap-3">
                              <span className="w-8 h-8 rounded-lg bg-teal-50 dark:bg-teal-950/40 text-teal-600 dark:text-teal-400 flex items-center justify-center font-bold font-mono">
                                P{c.period_number}
                              </span>
                              <div>
                                <p className="font-semibold text-[#0B1020] dark:text-white">{c.course_name} ({c.course_code})</p>
                                <p className="text-[#64708A]">Section {c.section_name} • Room {c.room_number}</p>
                              </div>
                            </div>
                            <div className="flex items-center gap-3">
                              <span className="font-mono text-slate-500">{c.start_time} - {c.end_time}</span>
                              <button
                                onClick={() => openAttendanceModal(c)}
                                className="px-3 py-1.5 rounded-lg bg-teal-600 text-white font-semibold text-xs hover:bg-teal-700 transition"
                              >
                                Mark Attendance
                              </button>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                </div>
              )}

              {/* TAB 2: COURSES & ATTENDANCE */}
              {tab === "courses" && data && (
                <div className="space-y-4">
                  <div className="flex justify-between items-center">
                    <div>
                      <h3 className="text-base font-bold text-[#0B1020] dark:text-white">Assigned Classes & Attendance</h3>
                      <p className="text-xs text-[#64708A]">Launch one-tap bulk attendance rosters for each course section.</p>
                    </div>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {data.map((c: any) => (
                      <div key={c.offering_id} className="card p-5 space-y-3 flex flex-col justify-between">
                        <div>
                          <div className="flex justify-between items-start">
                            <span className="font-mono text-xs font-bold text-teal-600 dark:text-teal-400 bg-teal-50 dark:bg-teal-950 px-2 py-0.5 rounded">
                              {c.code}
                            </span>
                            <span className="text-xs text-[#64708A]">Sec {c.section_name} • Sem {c.semester_number}</span>
                          </div>
                          <h4 className="font-bold text-sm text-[#0B1020] dark:text-white mt-2">{c.name}</h4>
                          <p className="text-xs text-[#64708A]">{c.credits} Credits • {c.course_type}</p>
                        </div>

                        <div className="border-t border-[#E5E8F0] dark:border-[#1F293D] pt-3 flex items-center justify-between text-xs">
                          <span className="font-mono text-slate-600 dark:text-slate-400">{c.student_count} Students Enrolled</span>
                          <button
                            onClick={() => openAttendanceModal(c)}
                            className="px-3.5 py-1.5 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-semibold text-xs transition"
                          >
                            Mark Attendance
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* TAB 3: ASSIGNMENTS & GRADING */}
              {tab === "assignments" && (
                <div className="space-y-4">
                  <div className="flex justify-between items-center">
                    <div>
                      <h3 className="text-base font-bold text-[#0B1020] dark:text-white">Course Assignments & Submissions</h3>
                      <p className="text-xs text-[#64708A]">Post homework, review student uploads, and grade with personalized feedback.</p>
                    </div>
                    <button
                      onClick={() => setCreateAssignModal(true)}
                      className="px-3.5 py-2 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-semibold text-xs flex items-center gap-1.5 shadow-md shadow-teal-600/20 transition"
                    >
                      <Plus className="w-4 h-4" /> Create Assignment
                    </button>
                  </div>

                  {(!data || data.length === 0) ? (
                    <div className="card p-8 text-center text-xs text-[#64708A]">
                      No assignments posted yet. Click "Create Assignment" to assign coursework.
                    </div>
                  ) : (
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      {data.map((a: any) => (
                        <div key={a.id} className="card p-5 space-y-3 flex flex-col justify-between">
                          <div>
                            <div className="flex justify-between items-start">
                              <span className="font-mono text-[10px] font-bold text-teal-600 bg-teal-50 dark:bg-teal-950 px-2 py-0.5 rounded">
                                {a.course_code} - Sec {a.section_name}
                              </span>
                              <span className="text-[11px] text-[#64708A]">Due: {new Date(a.due_date).toLocaleDateString()}</span>
                            </div>
                            <h4 className="font-bold text-sm text-[#0B1020] dark:text-white mt-2">{a.title}</h4>
                            <p className="text-xs text-[#64708A] mt-1 line-clamp-2">{a.instructions}</p>
                          </div>

                          <div className="border-t border-[#E5E8F0] dark:border-[#1F293D] pt-3 flex items-center justify-between text-xs">
                            <span className="font-mono text-slate-500">
                              {a.submission_count} / {a.total_students} Submitted
                            </span>
                            <button
                              onClick={() => openSubmissionsModal(a)}
                              className="px-3 py-1.5 rounded-xl border border-teal-600 text-teal-600 dark:text-teal-400 hover:bg-teal-50 dark:hover:bg-teal-950 font-semibold text-xs transition"
                            >
                              Review & Grade
                            </button>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              )}

              {/* TAB 4: MARKS & GRADES ENTRY */}
              {tab === "marks" && (
                <div className="space-y-4">
                  <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                    <div>
                      <h3 className="text-base font-bold text-[#0B1020] dark:text-white">Curriculum Marks & Grades Entry</h3>
                      <p className="text-xs text-[#64708A]">Enter internal and external exam marks. Letter grades and GPAs compute automatically.</p>
                    </div>
                    {myOfferings.length > 0 && (
                      <select
                        value={selectedOfferingId || ""}
                        onChange={(e) => {
                          const id = Number(e.target.value);
                          setSelectedOfferingId(id);
                          loadMarksForOffering(id);
                        }}
                        className="px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-white dark:bg-[#11162A] text-xs font-semibold text-[#0B1020] dark:text-white"
                      >
                        {myOfferings.map((off) => (
                          <option key={off.offering_id} value={off.offering_id}>
                            {off.code} - {off.name} (Sec {off.section_name})
                          </option>
                        ))}
                      </select>
                    )}
                  </div>

                  {marksData && (
                    <div className="card p-4 space-y-4">
                      <div className="table-container">
                        <table>
                          <thead>
                            <tr>
                              <th>Reg No</th>
                              <th>Student Name</th>
                              <th>Internal (Max 40)</th>
                              <th>External (Max 60)</th>
                              <th>Total (100)</th>
                              <th>Grade</th>
                              <th>Result</th>
                            </tr>
                          </thead>
                          <tbody>
                            {(marksData.students || []).map((st: any) => {
                              const cur = editingMarks[st.student_id] || { internal: 0, external: 0 };
                              const total = cur.internal + cur.external;
                              const grade = total >= 90 ? "O" : total >= 80 ? "A+" : total >= 70 ? "A" : total >= 60 ? "B+" : total >= 50 ? "B" : total >= 40 ? "C" : "F";
                              const isPass = grade !== "F";

                              return (
                                <tr key={st.student_id}>
                                  <td className="font-mono font-bold text-teal-600 dark:text-teal-400">{st.registration_number}</td>
                                  <td className="font-semibold">{st.full_name}</td>
                                  <td>
                                    <input
                                      type="number"
                                      min={0}
                                      max={40}
                                      value={cur.internal}
                                      onChange={(e) => {
                                        const v = Math.min(40, Math.max(0, Number(e.target.value)));
                                        setEditingMarks((prev) => ({
                                          ...prev,
                                          [st.student_id]: { ...prev[st.student_id], internal: v },
                                        }));
                                      }}
                                      className="w-20 px-2 py-1 rounded border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent text-center font-mono"
                                    />
                                  </td>
                                  <td>
                                    <input
                                      type="number"
                                      min={0}
                                      max={60}
                                      value={cur.external}
                                      onChange={(e) => {
                                        const v = Math.min(60, Math.max(0, Number(e.target.value)));
                                        setEditingMarks((prev) => ({
                                          ...prev,
                                          [st.student_id]: { ...prev[st.student_id], external: v },
                                        }));
                                      }}
                                      className="w-20 px-2 py-1 rounded border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent text-center font-mono"
                                    />
                                  </td>
                                  <td className="font-mono font-bold text-indigo-600">{total}</td>
                                  <td className="font-mono font-bold">{grade}</td>
                                  <td><Badge label={isPass ? "PASS" : "FAIL"} variant={isPass ? "success" : "danger"} /></td>
                                </tr>
                              );
                            })}
                          </tbody>
                        </table>
                      </div>

                      <div className="flex justify-end pt-2">
                        <button
                          onClick={handleSaveMarks}
                          disabled={savingMarks}
                          className="px-5 py-2.5 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-semibold text-xs shadow-md shadow-teal-600/20 disabled:opacity-50 transition"
                        >
                          {savingMarks ? "Saving Marks..." : "Save & Register Marks"}
                        </button>
                      </div>
                    </div>
                  )}
                </div>
              )}

              {/* TAB 5: TIMETABLE */}
              {tab === "timetable" && (
                <div className="space-y-4">
                  <div>
                    <h3 className="text-base font-bold text-[#0B1020] dark:text-white">Teaching Schedule</h3>
                    <p className="text-xs text-[#64708A]">Allocated teaching load by period and lecture hall.</p>
                  </div>

                  {(!data || data.length === 0) ? (
                    <div className="card p-8 text-center text-xs text-[#64708A]">No timetable slots assigned.</div>
                  ) : (
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                      {daysOfWeek.map((dayName, idx) => {
                        const dayNum = idx + 1;
                        const daySlots = data.filter((s: any) => s.day_of_week === dayNum);
                        return (
                          <div key={dayName} className="card p-4 space-y-3">
                            <div className="flex justify-between items-center border-b border-[#E5E8F0] dark:border-[#1F293D] pb-2">
                              <span className="text-xs font-bold text-teal-600 uppercase tracking-wider">{dayName}</span>
                              <span className="text-[10px] text-[#64708A] font-mono">{daySlots.length} classes</span>
                            </div>
                            {daySlots.length === 0 ? (
                              <p className="text-[11px] text-[#64708A] italic py-2">No periods allocated</p>
                            ) : (
                              <div className="space-y-2">
                                {daySlots.map((slot: any, sIdx: number) => (
                                  <div key={sIdx} className="p-2.5 rounded-xl bg-slate-50 dark:bg-slate-800/50 border border-slate-100 dark:border-slate-800 text-xs">
                                    <div className="flex justify-between">
                                      <span className="font-mono font-bold text-teal-600">{slot.course_code}</span>
                                      <span className="text-[10px] font-mono text-[#64708A]">{slot.start_time} - {slot.end_time}</span>
                                    </div>
                                    <p className="font-medium text-[#0B1020] dark:text-white mt-0.5 line-clamp-1">{slot.course_name}</p>
                                    <div className="flex justify-between text-[10px] text-[#64708A] mt-1">
                                      <span>Section {slot.section_name}</span>
                                      <span className="font-mono">Room {slot.room_number}</span>
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

              {/* TAB 6: PAYSLIPS */}
              {tab === "payslips" && data && (
                <div className="space-y-4">
                  <div>
                    <h3 className="text-base font-bold text-[#0B1020] dark:text-white">Monthly Payslips</h3>
                    <p className="text-xs text-[#64708A]">Official institutional salary disbursements and PDF downloads.</p>
                  </div>

                  <div className="table-container">
                    <table>
                      <thead>
                        <tr>
                          <th>Month/Year</th>
                          <th>Basic Pay</th>
                          <th>HRA</th>
                          <th>DA</th>
                          <th>Allowances</th>
                          <th>Deductions</th>
                          <th>Net Salary</th>
                          <th>Payslip PDF</th>
                        </tr>
                      </thead>
                      <tbody>
                        {data.map((p: any) => (
                          <tr key={p.id}>
                            <td className="font-mono font-bold text-teal-600 dark:text-teal-400">{p.month_year}</td>
                            <td className="font-mono">INR {Number(p.basic).toLocaleString()}</td>
                            <td className="font-mono">INR {Number(p.hra).toLocaleString()}</td>
                            <td className="font-mono">INR {Number(p.da).toLocaleString()}</td>
                            <td className="font-mono">INR {Number(p.allowances).toLocaleString()}</td>
                            <td className="font-mono text-rose-600">INR {Number(p.deductions).toLocaleString()}</td>
                            <td className="font-mono font-bold text-emerald-600">INR {Number(p.net_amount).toLocaleString()}</td>
                            <td>
                              <button
                                onClick={() => downloadBlob(`/faculty/payslips/${p.id}/download-pdf`, `Payslip_${p.month_year}.pdf`)}
                                className="p-1.5 rounded-lg bg-teal-50 dark:bg-teal-950 text-teal-600 hover:bg-teal-100 dark:hover:bg-teal-900 transition flex items-center gap-1 text-[11px]"
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

              {/* TAB 7: PROFILE */}
              {tab === "profile" && data && (
                <div className="max-w-xl space-y-4">
                  <div>
                    <h3 className="text-base font-bold text-[#0B1020] dark:text-white">Faculty Profile</h3>
                    <p className="text-xs text-[#64708A]">Institutional designation and academic employee credentials.</p>
                  </div>

                  <div className="card p-6 space-y-4">
                    <div className="grid grid-cols-2 gap-4 text-xs">
                      <div>
                        <span className="text-[#64708A] block">Full Name</span>
                        <span className="font-bold text-sm text-[#0B1020] dark:text-white">{data.profile?.full_name}</span>
                      </div>
                      <div>
                        <span className="text-[#64708A] block">Employee ID</span>
                        <span className="font-mono font-bold text-teal-600">{data.profile?.employee_id}</span>
                      </div>
                      <div>
                        <span className="text-[#64708A] block">Email</span>
                        <span className="font-mono text-[#0B1020] dark:text-white">{data.user?.email}</span>
                      </div>
                      <div>
                        <span className="text-[#64708A] block">Designation</span>
                        <span className="text-[#0B1020] dark:text-white">{data.profile?.designation}</span>
                      </div>
                      <div>
                        <span className="text-[#64708A] block">Department</span>
                        <span className="text-[#0B1020] dark:text-white">{data.profile?.department_name}</span>
                      </div>
                      <div>
                        <span className="text-[#64708A] block">Qualification</span>
                        <span className="text-[#0B1020] dark:text-white">{data.profile?.qualification}</span>
                      </div>
                    </div>
                  </div>
                </div>
              )}
            </>
          )}
        </div>
      </main>

      {/* Attendance Modal */}
      {attendanceOffering && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
          <div className="bg-white dark:bg-[#11162A] w-full max-w-xl rounded-2xl border border-[#E5E8F0] dark:border-[#1F293D] shadow-2xl p-6 space-y-4">
            <div className="flex items-center justify-between border-b border-[#E5E8F0] dark:border-[#1F293D] pb-3">
              <div>
                <h3 className="font-bold text-sm text-[#0B1020] dark:text-white">Mark Class Attendance</h3>
                <p className="text-xs text-[#64708A]">{attendanceOffering.name || attendanceOffering.course_name} (Section {attendanceOffering.section_name})</p>
              </div>
              <button onClick={() => setAttendanceOffering(null)} className="p-1 text-slate-400">
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="max-h-80 overflow-y-auto divide-y divide-slate-100 dark:divide-slate-800">
              {studentList.map((st) => {
                const isPresent = !!attendanceRecords[st.id];
                return (
                  <div key={st.id} className="py-2.5 flex items-center justify-between text-xs">
                    <div>
                      <p className="font-semibold text-[#0B1020] dark:text-white">{st.full_name}</p>
                      <p className="font-mono text-[#64708A] text-[11px]">{st.registration_number}</p>
                    </div>
                    <button
                      type="button"
                      onClick={() => setAttendanceRecords((prev) => ({ ...prev, [st.id]: !prev[st.id] }))}
                      className={`px-3 py-1 rounded-lg font-semibold text-xs transition ${
                        isPresent
                          ? "bg-emerald-50 text-emerald-700 dark:bg-emerald-950 dark:text-emerald-300"
                          : "bg-rose-50 text-rose-700 dark:bg-rose-950 dark:text-rose-300"
                      }`}
                    >
                      {isPresent ? "PRESENT" : "ABSENT"}
                    </button>
                  </div>
                );
              })}
            </div>

            <div className="pt-2 flex justify-end gap-2 border-t border-[#E5E8F0] dark:border-[#1F293D]">
              <button
                type="button"
                onClick={() => setAttendanceOffering(null)}
                className="px-4 py-2 rounded-xl border border-slate-200 dark:border-slate-800 text-slate-600 dark:text-slate-300 text-xs"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={submitAttendance}
                className="px-4 py-2 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-semibold text-xs"
              >
                Submit Attendance
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Create Assignment Modal */}
      {createAssignModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
          <div className="bg-white dark:bg-[#11162A] w-full max-w-lg rounded-2xl border border-[#E5E8F0] dark:border-[#1F293D] shadow-2xl p-6 space-y-4">
            <div className="flex items-center justify-between border-b border-[#E5E8F0] dark:border-[#1F293D] pb-3">
              <h3 className="font-bold text-sm text-[#0B1020] dark:text-white">Create New Course Assignment</h3>
              <button onClick={() => setCreateAssignModal(false)} className="p-1 text-slate-400">
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleCreateAssignment} className="space-y-3 text-xs">
              <div>
                <label className="block text-[#64708A] mb-1">Course Offering / Section</label>
                <select
                  required
                  value={newAssign.offeringId}
                  onChange={(e) => setNewAssign({ ...newAssign, offeringId: e.target.value })}
                  className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-white dark:bg-[#11162A] text-[#0B1020] dark:text-white"
                >
                  {myOfferings.map((off) => (
                    <option key={off.offering_id} value={off.offering_id}>
                      {off.code} - {off.name} (Sec {off.section_name})
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <label className="block text-[#64708A] mb-1">Assignment Title</label>
                <input
                  type="text"
                  required
                  value={newAssign.title}
                  onChange={(e) => setNewAssign({ ...newAssign, title: e.target.value })}
                  placeholder="e.g. Unit 3 Programming Project"
                  className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent text-[#0B1020] dark:text-white"
                />
              </div>
              <div>
                <label className="block text-[#64708A] mb-1">Instructions & Problem Statement</label>
                <textarea
                  rows={3}
                  required
                  value={newAssign.instructions}
                  onChange={(e) => setNewAssign({ ...newAssign, instructions: e.target.value })}
                  placeholder="Enter problem specifications and guidelines..."
                  className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent text-[#0B1020] dark:text-white"
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-[#64708A] mb-1">Submission Deadline</label>
                  <input
                    type="date"
                    required
                    value={newAssign.dueDate}
                    onChange={(e) => setNewAssign({ ...newAssign, dueDate: e.target.value })}
                    className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent text-[#0B1020] dark:text-white"
                  />
                </div>
                <div>
                  <label className="block text-[#64708A] mb-1">Maximum Marks</label>
                  <input
                    type="number"
                    min={1}
                    max={100}
                    value={newAssign.maxMarks}
                    onChange={(e) => setNewAssign({ ...newAssign, maxMarks: Number(e.target.value) })}
                    className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent text-[#0B1020] dark:text-white"
                  />
                </div>
              </div>
              <div className="pt-2 flex justify-end gap-2">
                <button
                  type="button"
                  onClick={() => setCreateAssignModal(false)}
                  className="px-4 py-2 rounded-xl border border-slate-200 dark:border-slate-800 text-slate-600 dark:text-slate-300"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-semibold"
                >
                  Publish Assignment
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Review Submissions Modal */}
      {submissionsModalAssign && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
          <div className="bg-white dark:bg-[#11162A] w-full max-w-2xl rounded-2xl border border-[#E5E8F0] dark:border-[#1F293D] shadow-2xl p-6 space-y-4">
            <div className="flex items-center justify-between border-b border-[#E5E8F0] dark:border-[#1F293D] pb-3">
              <div>
                <h3 className="font-bold text-sm text-[#0B1020] dark:text-white">Student Submissions</h3>
                <p className="text-xs text-[#64708A]">{submissionsModalAssign.title} (Max Marks: {submissionsModalAssign.max_marks})</p>
              </div>
              <button onClick={() => setSubmissionsModalAssign(null)} className="p-1 text-slate-400">
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="max-h-96 overflow-y-auto space-y-3">
              {submissionList.length === 0 ? (
                <p className="text-xs text-[#64708A] text-center py-6">No students have submitted work yet.</p>
              ) : (
                submissionList.map((sub) => {
                  const state = gradingState[sub.id] || { marks: 0, feedback: "" };
                  return (
                    <div key={sub.id} className="p-4 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] text-xs space-y-2">
                      <div className="flex justify-between items-start">
                        <div>
                          <p className="font-bold text-[#0B1020] dark:text-white">{sub.student_name}</p>
                          <p className="font-mono text-[#64708A] text-[11px]">{sub.registration_number}</p>
                        </div>
                        <span className="text-[10px] text-slate-400 font-mono">
                          Submitted: {new Date(sub.submitted_at).toLocaleDateString()}
                        </span>
                      </div>

                      {sub.submission_text && (
                        <div className="p-2.5 rounded-lg bg-slate-50 dark:bg-slate-800/50 text-[11px] text-[#0B1020] dark:text-slate-300">
                          {sub.submission_text}
                        </div>
                      )}

                      {sub.file_url && (
                        <a
                          href={sub.file_url}
                          target="_blank"
                          rel="noreferrer"
                          className="text-[11px] text-teal-600 hover:underline inline-block font-mono"
                        >
                          Attachment Link: {sub.file_url}
                        </a>
                      )}

                      <div className="pt-2 flex items-center gap-3">
                        <div className="flex items-center gap-1.5">
                          <label className="text-[#64708A]">Marks:</label>
                          <input
                            type="number"
                            min={0}
                            max={submissionsModalAssign.max_marks}
                            value={state.marks}
                            onChange={(e) => {
                              const val = Number(e.target.value);
                              setGradingState((prev) => ({
                                ...prev,
                                [sub.id]: { ...prev[sub.id], marks: val },
                              }));
                            }}
                            className="w-16 px-2 py-1 rounded border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent text-center font-mono"
                          />
                        </div>
                        <input
                          type="text"
                          placeholder="Feedback comments..."
                          value={state.feedback}
                          onChange={(e) => {
                            const val = e.target.value;
                            setGradingState((prev) => ({
                              ...prev,
                              [sub.id]: { ...prev[sub.id], feedback: val },
                            }));
                          }}
                          className="flex-1 px-3 py-1 rounded border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent text-[11px]"
                        />
                        <button
                          type="button"
                          onClick={() => handleGradeSubmission(sub.id)}
                          className="px-3 py-1 rounded bg-teal-600 hover:bg-teal-700 text-white font-semibold text-[11px]"
                        >
                          Save Grade
                        </button>
                      </div>
                    </div>
                  );
                })
              )}
            </div>
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
