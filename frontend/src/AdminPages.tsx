import React, { useState, useEffect } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import {
  LayoutDashboard, Users, UserCheck, BookOpen, Calendar, DollarSign,
  AlertTriangle, Bell, FileText, Settings, ShieldAlert, Plus, Eye,
  CheckCircle, ArrowUpRight, Search, Download, Lock, Unlock, ChevronRight,
  LogOut, Menu, X, Edit, Trash2, Key, Clock, BarChart2, Filter, ChevronLeft,
  RefreshCw, SlidersHorizontal, ArrowUpDown
} from "lucide-react";
import { ResponsiveContainer, BarChart, Bar, XAxis, YAxis, Tooltip } from "recharts";
import { api, clearAuth } from "./api";
import {
  StatCard, SkeletonCard, SkeletonTable, Badge, Toast,
  ThemeToggle, NotificationBell, GlobalSearchModal, PasswordChangeModal
} from "./ui";

export function AdminPortal() {
  const navigate = useNavigate();
  const location = useLocation();

  const pathSegments = location.pathname.split("/").filter(Boolean);
  const tab = pathSegments[1] || "dashboard";

  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [toast, setToast] = useState<{ msg: string; type: "success" | "error" | "info" } | null>(null);
  const [mobileOpen, setMobileOpen] = useState(false);
  const [searchModalOpen, setSearchModalOpen] = useState(false);
  const [pwdModalOpen, setPwdModalOpen] = useState(false);

  // Modals state
  const [studentModal, setStudentModal] = useState(false);
  const [editStudentModal, setEditStudentModal] = useState<any>(null);
  const [facultyModal, setFacultyModal] = useState(false);
  const [courseModal, setCourseModal] = useState(false);
  const [announcementModal, setAnnouncementModal] = useState(false);
  const [studentDetail, setStudentDetail] = useState<any>(null);
  const [feePaymentModal, setFeePaymentModal] = useState<any>(null);

  // Timetable tab state
  const [sectionsList, setSectionsList] = useState<any[]>([]);
  const [selectedSectionId, setSelectedSectionId] = useState<number>(1);
  const [addSlotModal, setAddSlotModal] = useState(false);
  const [newSlot, setNewSlot] = useState({
    dayOfWeek: 1,
    periodNumber: 1,
    offeringId: 1,
    roomId: 1,
    startTime: "09:00",
    endTime: "09:50",
  });

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

  // Search & Filter State for 9000 Students Directory
  const [studentSearch, setStudentSearch] = useState("");
  const [selectedYearOfStudy, setSelectedYearOfStudy] = useState<string>("ALL"); // "ALL", "1", "2", "3", "4", "GRADUATED"
  const [selectedGender, setSelectedGender] = useState<string>("ALL"); // "ALL", "MALE", "FEMALE"
  const [selectedDept, setSelectedDept] = useState<string>("ALL");
  const [selectedSem, setSelectedSem] = useState<string>("ALL");
  const [selectedCgpa, setSelectedCgpa] = useState<string>("ALL");
  const [selectedAtt, setSelectedAtt] = useState<string>("ALL");
  const [selectedStatus, setSelectedStatus] = useState<string>("ALL");
  const [studentPage, setStudentPage] = useState<number>(1);
  const [studentPageSize, setStudentPageSize] = useState<number>(20);
  const [studentSortBy, setStudentSortBy] = useState<string>("id");
  const [studentSortDir, setStudentSortDir] = useState<string>("desc");
  const [studentDepartments, setStudentDepartments] = useState<any[]>([]);

  useEffect(() => {
    loadTab(tab);
  }, [tab]);

  async function loadTab(t: string, overrides: any = {}) {
    setLoading(true);
    try {
      if (t === "dashboard") {
        const res = await api.admin.getDashboard();
        setData(res);
      } else if (t === "students") {
        if (studentDepartments.length === 0) {
          api.admin.getDepartments().then((depts: any) => {
            if (Array.isArray(depts)) setStudentDepartments(depts);
          }).catch(() => {});
        }

        const p = overrides.page !== undefined ? overrides.page : studentPage;
        const sz = overrides.size !== undefined ? overrides.size : studentPageSize;
        const sb = overrides.sortBy !== undefined ? overrides.sortBy : studentSortBy;
        const sd = overrides.sortDir !== undefined ? overrides.sortDir : studentSortDir;
        const s = overrides.search !== undefined ? overrides.search : studentSearch;
        const y = overrides.yearOfStudy !== undefined ? overrides.yearOfStudy : selectedYearOfStudy;
        const g = overrides.gender !== undefined ? overrides.gender : selectedGender;
        const d = overrides.dept !== undefined ? overrides.dept : selectedDept;
        const sem = overrides.sem !== undefined ? overrides.sem : selectedSem;
        const cg = overrides.cgpa !== undefined ? overrides.cgpa : selectedCgpa;
        const att = overrides.att !== undefined ? overrides.att : selectedAtt;
        const st = overrides.status !== undefined ? overrides.status : selectedStatus;

        const params: any = { page: p, size: sz, sortBy: sb, sortDir: sd };
        if (s && s.trim()) params.search = s.trim();
        if (y && y !== "ALL") {
          if (y === "GRADUATED") params.status = "GRADUATED";
          else params.yearOfStudy = Number(y);
        }
        if (g && g !== "ALL") params.gender = g;
        if (d && d !== "ALL") params.departmentId = Number(d);
        if (sem && sem !== "ALL") params.semester = Number(sem);
        if (st && st !== "ALL" && y !== "GRADUATED") params.status = st;
        if (att && att !== "ALL") params.attendanceFilter = att;

        if (cg === "TOP_9") params.minCgpa = 9.0;
        else if (cg === "FIRST_8") { params.minCgpa = 8.0; params.maxCgpa = 8.99; }
        else if (cg === "SECOND_7") { params.minCgpa = 7.0; params.maxCgpa = 7.99; }
        else if (cg === "BELOW_7") { params.maxCgpa = 6.99; }

        const res = await api.admin.getStudents(params);
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
      } else if (t === "timetable") {
        const sections = await api.admin.getSections();
        const secArr = Array.isArray(sections) ? sections : [];
        setSectionsList(secArr);
        const secId = selectedSectionId || (secArr[0]?.id ?? 1);
        setSelectedSectionId(secId);
        const tt = await api.admin.getTimetable(secId);
        setData({ sections: secArr, timetable: tt, sectionId: secId });
      } else if (t === "assignments") {
        const res = await api.admin.getAssignments();
        setData(res);
      } else if (t === "reports") {
        const res = await api.admin.getReportsSummary();
        setData(res);
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

  function handleFilterChange(updates: any) {
    if (updates.page === undefined) {
      updates.page = 1;
      setStudentPage(1);
    }
    if (updates.search !== undefined) setStudentSearch(updates.search);
    if (updates.yearOfStudy !== undefined) setSelectedYearOfStudy(updates.yearOfStudy);
    if (updates.gender !== undefined) setSelectedGender(updates.gender);
    if (updates.dept !== undefined) setSelectedDept(updates.dept);
    if (updates.sem !== undefined) setSelectedSem(updates.sem);
    if (updates.cgpa !== undefined) setSelectedCgpa(updates.cgpa);
    if (updates.att !== undefined) setSelectedAtt(updates.att);
    if (updates.status !== undefined) setSelectedStatus(updates.status);
    if (updates.size !== undefined) setStudentPageSize(updates.size);
    if (updates.sortBy !== undefined) setStudentSortBy(updates.sortBy);
    if (updates.sortDir !== undefined) setStudentSortDir(updates.sortDir);
    if (updates.page !== undefined) setStudentPage(updates.page);

    loadTab("students", updates);
  }

  function resetAllStudentFilters() {
    setStudentSearch("");
    setSelectedYearOfStudy("ALL");
    setSelectedGender("ALL");
    setSelectedDept("ALL");
    setSelectedSem("ALL");
    setSelectedCgpa("ALL");
    setSelectedAtt("ALL");
    setSelectedStatus("ALL");
    setStudentPage(1);
    setStudentSortBy("id");
    setStudentSortDir("desc");
    loadTab("students", {
      search: "",
      yearOfStudy: "ALL",
      gender: "ALL",
      dept: "ALL",
      sem: "ALL",
      cgpa: "ALL",
      att: "ALL",
      status: "ALL",
      page: 1,
      sortBy: "id",
      sortDir: "desc"
    });
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

  async function handleUpdateStudent(e: React.FormEvent) {
    e.preventDefault();
    if (!editStudentModal) return;
    try {
      await api.admin.updateStudent(editStudentModal.id, {
        fullName: editStudentModal.full_name,
        phone: editStudentModal.phone,
        personalEmail: editStudentModal.personal_email,
        address: editStudentModal.address,
        status: editStudentModal.status,
      });
      setToast({ msg: "Student profile updated successfully.", type: "success" });
      setEditStudentModal(null);
      loadTab("students");
    } catch (err: any) {
      setToast({ msg: err.message || "Failed to update student.", type: "error" });
    }
  }

  async function handleDeleteStudent(id: number, name: string) {
    if (!window.confirm(`Are you sure you want to deactivate student ${name}?`)) return;
    try {
      await api.admin.deleteStudent(id);
      setToast({ msg: "Student deactivated successfully.", type: "success" });
      loadTab("students");
    } catch (err: any) {
      setToast({ msg: err.message || "Failed to delete student.", type: "error" });
    }
  }

  async function handleRecordPayment(e: React.FormEvent) {
    e.preventDefault();
    if (!feePaymentModal) return;
    try {
      const res = await api.admin.recordFeePayment({
        studentFeeId: feePaymentModal.feeId,
        amount: Number(feePaymentModal.amount),
        paymentMode: feePaymentModal.mode || "ONLINE",
      });
      setToast({ msg: `Payment recorded! Receipt: ${res.receiptNumber}`, type: "success" });
      setFeePaymentModal(null);
      if (studentDetail) {
        const detail = await api.admin.getStudentDetail(studentDetail.student.id);
        setStudentDetail(detail);
      }
    } catch (err: any) {
      setToast({ msg: err.message || "Failed to record payment.", type: "error" });
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

  async function handleCreateSlot(e: React.FormEvent) {
    e.preventDefault();
    try {
      await api.admin.createTimetableSlot({
        versionId: 1,
        sectionId: selectedSectionId,
        dayOfWeek: Number(newSlot.dayOfWeek),
        periodNumber: Number(newSlot.periodNumber),
        offeringId: Number(newSlot.offeringId),
        roomId: Number(newSlot.roomId),
        startTime: newSlot.startTime,
        endTime: newSlot.endTime,
      });
      setToast({ msg: "Timetable slot assigned without conflicts.", type: "success" });
      setAddSlotModal(false);
      const tt = await api.admin.getTimetable(selectedSectionId);
      setData((prev: any) => ({ ...prev, timetable: tt }));
    } catch (err: any) {
      setToast({ msg: err.message || "Timetable conflict detected.", type: "error" });
    }
  }

  const navItems = [
    { id: "dashboard", label: "Dashboard", icon: LayoutDashboard },
    { id: "students", label: "Students", icon: Users },
    { id: "faculty", label: "Faculty", icon: UserCheck },
    { id: "payroll", label: "Payroll & Salary", icon: DollarSign },
    { id: "academics", label: "Academics", icon: BookOpen },
    { id: "timetable", label: "Timetable Grid", icon: Calendar },
    { id: "assignments", label: "Assignments", icon: FileText },
    { id: "reports", label: "Reports & Analytics", icon: BarChart2 },
    { id: "arrears", label: "Arrear Registry", icon: AlertTriangle },
    { id: "announcements", label: "Announcements", icon: Bell },
    { id: "logs", label: "Logs & Registers", icon: ShieldAlert },
  ];

  const daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];

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
          {/* Institution Header Brand */}
          <div className="p-5 border-b border-[#E5E8F0] dark:border-[#1F293D] flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-xl bg-indigo-600 flex items-center justify-center text-white font-bold shadow-md shadow-indigo-500/20">
                A
              </div>
              <div>
                <h2 className="text-sm font-bold text-[#0B1020] dark:text-white font-heading">CampusFlow</h2>
                <p className="text-[10px] text-indigo-600 dark:text-indigo-400 font-mono tracking-wider uppercase font-semibold">Admin Engine</p>
              </div>
            </div>
            <button onClick={() => setMobileOpen(false)} className="md:hidden text-slate-400">
              <X className="w-5 h-5" />
            </button>
          </div>

          {/* Nav List */}
          <nav className="p-3 space-y-1 overflow-y-auto max-h-[calc(100vh-170px)]">
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
                  className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold transition ${
                    active
                      ? "bg-indigo-50 dark:bg-indigo-950/40 text-indigo-700 dark:text-indigo-300 shadow-sm border border-indigo-100 dark:border-indigo-900"
                      : "text-[#64708A] hover:bg-slate-100 dark:hover:bg-slate-800/60 hover:text-[#0B1020] dark:hover:text-white"
                  }`}
                >
                  <Icon className={`w-4 h-4 ${active ? "text-indigo-600 dark:text-indigo-400" : ""}`} />
                  {item.label}
                </button>
              );
            })}
          </nav>
        </div>

        {/* Footer User Info */}
        <div className="p-4 border-t border-[#E5E8F0] dark:border-[#1F293D] space-y-2">
          <div className="flex items-center justify-between text-xs text-[#64708A]">
            <span className="font-mono text-[11px]">admin@college.local</span>
            <span className="px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700 dark:bg-emerald-950 dark:text-emerald-300 text-[10px] font-bold">
              ONLINE
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
          <div className="flex items-center gap-2.5">
            <button
              onClick={() => setSearchModalOpen(true)}
              className="hidden sm:flex items-center gap-2 px-3 py-1.5 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] text-xs text-[#64708A] hover:bg-slate-100 dark:hover:bg-slate-800 transition"
            >
              <Search className="w-3.5 h-3.5 text-indigo-500" />
              <span>Global Search...</span>
              <kbd className="px-1.5 py-0.5 rounded bg-slate-100 dark:bg-slate-800 text-[10px] font-mono">Ctrl K</kbd>
            </button>
            <ThemeToggle />
            <NotificationBell />
            <button
              onClick={() => setPwdModalOpen(true)}
              className="p-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] hover:bg-slate-100 dark:hover:bg-slate-800 text-[#64708A] dark:text-slate-300 transition"
              title="Change Password"
            >
              <Key className="w-4 h-4" />
            </button>
            <span className="hidden md:inline-block text-xs px-2.5 py-1 rounded-full bg-indigo-50 dark:bg-indigo-950 text-indigo-700 dark:text-indigo-300 font-mono font-semibold">
              SUPER_ADMIN
            </span>
            <button
              onClick={() => {
                clearAuth();
                window.location.href = "/admin/login";
              }}
              className="hidden md:flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/40 border border-rose-200 dark:border-rose-900 transition"
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

              {/* 5.2 STUDENTS TAB - ADVANCED SEARCH ENGINE & DIRECTORY */}
              {tab === "students" && data && (
                <div className="space-y-4">
                  {/* Top Bar with Metrics and Action Button */}
                  <div className="flex flex-col lg:flex-row justify-between items-start lg:items-center gap-4 bg-white dark:bg-[#11162A] p-5 rounded-2xl border border-[#E5E8F0] dark:border-[#1F293D] shadow-sm">
                    <div>
                      <div className="flex items-center gap-3">
                        <h2 className="text-lg font-bold text-[#0B1020] dark:text-white">
                          Enrolled Students ({Number(data.total || 0).toLocaleString()})
                        </h2>
                        <span className="px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-indigo-50 dark:bg-indigo-950 text-indigo-600 dark:text-indigo-400 border border-indigo-200 dark:border-indigo-800">
                          Live Database: 9,000 Enrolled
                        </span>
                      </div>
                      <p className="text-xs text-[#64708A] mt-0.5">
                        High-performance search & multi-dimensional filtering across all 4 study years (2015–2026)
                      </p>
                    </div>

                    <div className="flex flex-wrap items-center gap-2">
                      {(studentSearch || selectedYearOfStudy !== "ALL" || selectedGender !== "ALL" || selectedDept !== "ALL" || selectedSem !== "ALL" || selectedCgpa !== "ALL" || selectedAtt !== "ALL" || selectedStatus !== "ALL") && (
                        <button
                          onClick={resetAllStudentFilters}
                          className="px-3 py-2 rounded-xl border border-rose-200 dark:border-rose-900/50 bg-rose-50 dark:bg-rose-950/40 text-rose-600 dark:text-rose-400 font-semibold text-xs flex items-center gap-1.5 transition hover:bg-rose-100"
                        >
                          <RefreshCw className="w-3.5 h-3.5" /> Reset Filters
                        </button>
                      )}
                      <button
                        onClick={() => setStudentModal(true)}
                        className="px-4 py-2.5 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-semibold text-xs shadow-md shadow-indigo-600/20 flex items-center gap-2 transition"
                      >
                        <Plus className="w-4 h-4" /> Enroll New Student
                      </button>
                    </div>
                  </div>

                  {/* Search Engine Filter Console */}
                  <div className="card p-5 space-y-4">
                    {/* Row 1: Search Bar & Year Selector Tabs */}
                    <div className="flex flex-col lg:flex-row gap-3">
                      {/* Search Input */}
                      <div className="relative flex-1">
                        <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                        <input
                          type="text"
                          placeholder="Search engine: Type student name, registration number, roll no, or phone..."
                          value={studentSearch}
                          onChange={(e) => {
                            setStudentSearch(e.target.value);
                            handleFilterChange({ search: e.target.value, page: 1 });
                          }}
                          className="w-full pl-10 pr-10 py-2.5 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-white dark:bg-[#0B1020] text-xs font-medium focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition outline-none"
                        />
                        {studentSearch && (
                          <button
                            onClick={() => {
                              setStudentSearch("");
                              handleFilterChange({ search: "", page: 1 });
                            }}
                            className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 text-xs"
                          >
                            ✕
                          </button>
                        )}
                      </div>

                      {/* Year of Study Chips */}
                      <div className="flex flex-wrap items-center gap-1.5 p-1 rounded-xl bg-slate-100 dark:bg-slate-800/60 border border-slate-200 dark:border-slate-800">
                        {[
                          { id: "ALL", label: "All Years" },
                          { id: "1", label: "1st Year (2026)" },
                          { id: "2", label: "2nd Year (2025)" },
                          { id: "3", label: "3rd Year (2024)" },
                          { id: "4", label: "4th Year (2023)" },
                          { id: "GRADUATED", label: "Graduated" }
                        ].map((yr) => (
                          <button
                            key={yr.id}
                            onClick={() => {
                              setSelectedYearOfStudy(yr.id);
                              handleFilterChange({ yearOfStudy: yr.id, page: 1 });
                            }}
                            className={`px-3 py-1.5 rounded-lg text-xs font-bold transition ${
                              selectedYearOfStudy === yr.id
                                ? "bg-indigo-600 text-white shadow-sm"
                                : "text-slate-600 dark:text-slate-300 hover:text-indigo-600"
                            }`}
                          >
                            {yr.label}
                          </button>
                        ))}
                      </div>
                    </div>

                    {/* Row 2: Secondary Dropdown Filters */}
                    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-2.5 pt-1 border-t border-[#E5E8F0] dark:border-[#1F293D]/60">
                      {/* Gender Filter */}
                      <div>
                        <label className="block text-[10px] font-bold text-[#64708A] uppercase mb-1">Gender</label>
                        <select
                          value={selectedGender}
                          onChange={(e) => {
                            setSelectedGender(e.target.value);
                            handleFilterChange({ gender: e.target.value, page: 1 });
                          }}
                          className="w-full px-2.5 py-1.5 rounded-lg border border-[#E5E8F0] dark:border-[#1F293D] bg-white dark:bg-[#0B1020] text-xs font-semibold outline-none"
                        >
                          <option value="ALL">All Genders</option>
                          <option value="MALE">👨 Boys / Male</option>
                          <option value="FEMALE">👩 Girls / Female</option>
                        </select>
                      </div>

                      {/* Department Filter */}
                      <div>
                        <label className="block text-[10px] font-bold text-[#64708A] uppercase mb-1">Department</label>
                        <select
                          value={selectedDept}
                          onChange={(e) => {
                            setSelectedDept(e.target.value);
                            handleFilterChange({ dept: e.target.value, page: 1 });
                          }}
                          className="w-full px-2.5 py-1.5 rounded-lg border border-[#E5E8F0] dark:border-[#1F293D] bg-white dark:bg-[#0B1020] text-xs font-semibold outline-none"
                        >
                          <option value="ALL">All Departments</option>
                          {studentDepartments.map((d: any) => (
                            <option key={d.id} value={d.id}>{d.code || d.name}</option>
                          ))}
                        </select>
                      </div>

                      {/* Semester Filter */}
                      <div>
                        <label className="block text-[10px] font-bold text-[#64708A] uppercase mb-1">Semester</label>
                        <select
                          value={selectedSem}
                          onChange={(e) => {
                            setSelectedSem(e.target.value);
                            handleFilterChange({ sem: e.target.value, page: 1 });
                          }}
                          className="w-full px-2.5 py-1.5 rounded-lg border border-[#E5E8F0] dark:border-[#1F293D] bg-white dark:bg-[#0B1020] text-xs font-semibold outline-none"
                        >
                          <option value="ALL">All Semesters</option>
                          {[1, 2, 3, 4, 5, 6, 7, 8].map((s) => (
                            <option key={s} value={s}>Semester {s}</option>
                          ))}
                        </select>
                      </div>

                      {/* CGPA Range Filter */}
                      <div>
                        <label className="block text-[10px] font-bold text-[#64708A] uppercase mb-1">CGPA Range</label>
                        <select
                          value={selectedCgpa}
                          onChange={(e) => {
                            setSelectedCgpa(e.target.value);
                            handleFilterChange({ cgpa: e.target.value, page: 1 });
                          }}
                          className="w-full px-2.5 py-1.5 rounded-lg border border-[#E5E8F0] dark:border-[#1F293D] bg-white dark:bg-[#0B1020] text-xs font-semibold outline-none"
                        >
                          <option value="ALL">All CGPA</option>
                          <option value="TOP_9">≥ 9.0 (Outstanding)</option>
                          <option value="FIRST_8">8.0 – 8.99 (Distinction)</option>
                          <option value="SECOND_7">7.0 – 7.99 (First Class)</option>
                          <option value="BELOW_7">&lt; 7.0 (Needs Support)</option>
                        </select>
                      </div>

                      {/* Attendance Filter */}
                      <div>
                        <label className="block text-[10px] font-bold text-[#64708A] uppercase mb-1">Attendance</label>
                        <select
                          value={selectedAtt}
                          onChange={(e) => {
                            setSelectedAtt(e.target.value);
                            handleFilterChange({ att: e.target.value, page: 1 });
                          }}
                          className="w-full px-2.5 py-1.5 rounded-lg border border-[#E5E8F0] dark:border-[#1F293D] bg-white dark:bg-[#0B1020] text-xs font-semibold outline-none"
                        >
                          <option value="ALL">All Attendance</option>
                          <option value="GOOD">Eligible (≥ 75%)</option>
                          <option value="LOW">Shortage (&lt; 75%)</option>
                        </select>
                      </div>

                      {/* Sort By Filter */}
                      <div>
                        <label className="block text-[10px] font-bold text-[#64708A] uppercase mb-1">Sort By</label>
                        <select
                          value={`${studentSortBy}-${studentSortDir}`}
                          onChange={(e) => {
                            const [sb, sd] = e.target.value.split("-");
                            setStudentSortBy(sb);
                            setStudentSortDir(sd);
                            handleFilterChange({ sortBy: sb, sortDir: sd, page: 1 });
                          }}
                          className="w-full px-2.5 py-1.5 rounded-lg border border-[#E5E8F0] dark:border-[#1F293D] bg-white dark:bg-[#0B1020] text-xs font-semibold outline-none"
                        >
                          <option value="id-desc">Latest Registered</option>
                          <option value="name-asc">Name (A → Z)</option>
                          <option value="cgpa-desc">Highest CGPA</option>
                          <option value="cgpa-asc">Lowest CGPA</option>
                          <option value="attendance-desc">Highest Attendance</option>
                          <option value="attendance-asc">Lowest Attendance</option>
                          <option value="regno-asc">Registration No</option>
                        </select>
                      </div>
                    </div>

                    {/* Quick Stats Pill Strip */}
                    <div className="flex flex-wrap items-center justify-between gap-2 pt-2 border-t border-[#E5E8F0] dark:border-[#1F293D]/60 text-xs">
                      <div className="flex flex-wrap items-center gap-3">
                        <span className="font-semibold text-slate-700 dark:text-slate-300">
                          Matching: <b className="font-mono text-indigo-600 dark:text-indigo-400">{Number(data.total || 0).toLocaleString()}</b>
                        </span>
                        <span className="text-slate-300 dark:text-slate-700">|</span>
                        <span className="text-slate-600 dark:text-slate-400">
                          👨 Boys: <b className="font-mono text-blue-600 dark:text-blue-400">{Number(data.maleCount || 0).toLocaleString()}</b>
                        </span>
                        <span className="text-slate-300 dark:text-slate-700">|</span>
                        <span className="text-slate-600 dark:text-slate-400">
                          👩 Girls: <b className="font-mono text-pink-600 dark:text-pink-400">{Number(data.femaleCount || 0).toLocaleString()}</b>
                        </span>
                        <span className="text-slate-300 dark:text-slate-700">|</span>
                        <span className="text-slate-600 dark:text-slate-400">
                          Avg CGPA: <b className="font-mono text-emerald-600 dark:text-emerald-400">{data.avgCgpa || "0.00"}</b>
                        </span>
                      </div>

                      <div className="flex items-center gap-2 text-[11px] text-[#64708A]">
                        <span>Rows per page:</span>
                        <select
                          value={studentPageSize}
                          onChange={(e) => {
                            const newSz = Number(e.target.value);
                            setStudentPageSize(newSz);
                            handleFilterChange({ size: newSz, page: 1 });
                          }}
                          className="px-2 py-1 rounded border border-[#E5E8F0] dark:border-[#1F293D] bg-white dark:bg-[#0B1020] font-mono font-bold"
                        >
                          <option value={15}>15</option>
                          <option value={20}>20</option>
                          <option value={50}>50</option>
                          <option value={100}>100</option>
                        </select>
                      </div>
                    </div>
                  </div>

                  {/* Student Records Table */}
                  <div className="table-container shadow-sm">
                    <table>
                      <thead>
                        <tr>
                          <th>Registration No</th>
                          <th>Full Name & Gender</th>
                          <th>Year & Semester</th>
                          <th>Department</th>
                          <th>Phone</th>
                          <th>CGPA</th>
                          <th>Attendance</th>
                          <th>Status</th>
                          <th>Actions</th>
                        </tr>
                      </thead>
                      <tbody>
                        {(data.items || []).length === 0 ? (
                          <tr>
                            <td colSpan={9} className="text-center py-10 text-xs text-[#64708A]">
                              No students match the selected search & filter criteria.
                            </td>
                          </tr>
                        ) : (
                          (data.items || []).map((s: any) => {
                            const isMale = String(s.gender).toUpperCase() === "MALE";
                            const cgpaNum = Number(s.current_cgpa || 0);
                            const attNum = Number(s.attendance_percentage || 0);
                            const yLabel = s.current_year_of_study === 1 ? "1st Year"
                              : s.current_year_of_study === 2 ? "2nd Year"
                              : s.current_year_of_study === 3 ? "3rd Year"
                              : s.current_year_of_study === 4 ? "4th Year"
                              : `${s.admission_year} Batch`;

                            return (
                              <tr key={s.id} className="hover:bg-slate-50 dark:hover:bg-slate-800/40 transition">
                                <td className="font-mono font-bold text-indigo-600 dark:text-indigo-400">
                                  <div>{s.registration_number}</div>
                                  <div className="text-[10px] text-[#64708A] font-normal">{s.roll_number}</div>
                                </td>
                                <td>
                                  <div className="font-semibold text-[#0B1020] dark:text-white flex items-center gap-1.5">
                                    <span>{s.full_name}</span>
                                    <span
                                      className={`px-1.5 py-0.5 rounded text-[10px] font-bold ${
                                        isMale
                                          ? "bg-blue-50 text-blue-700 dark:bg-blue-950/60 dark:text-blue-300"
                                          : "bg-pink-50 text-pink-700 dark:bg-pink-950/60 dark:text-pink-300"
                                      }`}
                                    >
                                      {isMale ? "👨 Boy" : "👩 Girl"}
                                    </span>
                                  </div>
                                  <div className="text-[11px] text-[#64708A] font-mono">{s.college_email}</div>
                                </td>
                                <td>
                                  <span className="font-medium text-[#0B1020] dark:text-white text-xs">{yLabel}</span>
                                  <div className="text-[10px] text-[#64708A]">Sem {s.current_semester}</div>
                                </td>
                                <td>
                                  <span className="px-2 py-0.5 rounded font-mono font-bold text-[11px] bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300">
                                    {s.department_code || "CSE"}
                                  </span>
                                </td>
                                <td className="font-mono text-xs">{s.phone}</td>
                                <td>
                                  <span
                                    className={`font-mono font-bold px-2 py-0.5 rounded text-xs ${
                                      cgpaNum >= 9.0
                                        ? "bg-emerald-50 text-emerald-700 dark:bg-emerald-950/60 dark:text-emerald-300"
                                        : cgpaNum >= 8.0
                                        ? "bg-indigo-50 text-indigo-700 dark:bg-indigo-950/60 dark:text-indigo-300"
                                        : cgpaNum >= 7.0
                                        ? "bg-amber-50 text-amber-700 dark:bg-amber-950/60 dark:text-amber-300"
                                        : "bg-rose-50 text-rose-700 dark:bg-rose-950/60 dark:text-rose-300"
                                    }`}
                                  >
                                    {s.current_cgpa || "0.00"}
                                  </span>
                                </td>
                                <td>
                                  <Badge
                                    label={`${s.attendance_percentage || 100}%`}
                                    variant={attNum < 75 ? "danger" : "success"}
                                  />
                                </td>
                                <td>
                                  <Badge
                                    label={s.status}
                                    variant={s.status === "ACTIVE" ? "success" : s.status === "GRADUATED" ? "info" : "default"}
                                  />
                                </td>
                                <td>
                                  <div className="flex items-center gap-1.5">
                                    <button
                                      onClick={async () => {
                                        const detail = await api.admin.getStudentDetail(s.id);
                                        setStudentDetail(detail);
                                      }}
                                      className="px-2.5 py-1 rounded-lg border border-[#E5E8F0] dark:border-[#1F293D] text-[11px] font-semibold hover:bg-indigo-50 dark:hover:bg-indigo-950/40 hover:text-indigo-600 transition"
                                    >
                                      View
                                    </button>
                                    <button
                                      onClick={() => setEditStudentModal(s)}
                                      className="p-1 rounded-lg border border-[#E5E8F0] dark:border-[#1F293D] text-slate-500 hover:text-indigo-600"
                                      title="Edit student"
                                    >
                                      <Edit className="w-3.5 h-3.5" />
                                    </button>
                                    <button
                                      onClick={() => handleDeleteStudent(s.id, s.full_name)}
                                      className="p-1 rounded-lg border border-[#E5E8F0] dark:border-[#1F293D] text-slate-500 hover:text-rose-600"
                                      title="Deactivate student"
                                    >
                                      <Trash2 className="w-3.5 h-3.5" />
                                    </button>
                                  </div>
                                </td>
                              </tr>
                            );
                          })
                        )}
                      </tbody>
                    </table>
                  </div>

                  {/* Pagination Bar */}
                  {data.total > 0 && (
                    <div className="flex flex-col sm:flex-row justify-between items-center gap-3 p-4 bg-white dark:bg-[#11162A] rounded-2xl border border-[#E5E8F0] dark:border-[#1F293D] text-xs">
                      <div className="text-[#64708A]">
                        Showing <b className="text-[#0B1020] dark:text-white font-mono">{((studentPage - 1) * studentPageSize) + 1}</b> to <b className="text-[#0B1020] dark:text-white font-mono">{Math.min(studentPage * studentPageSize, data.total)}</b> of <b className="text-[#0B1020] dark:text-white font-mono">{Number(data.total).toLocaleString()}</b> students
                      </div>

                      <div className="flex items-center gap-2">
                        <button
                          disabled={studentPage <= 1}
                          onClick={() => handleFilterChange({ page: studentPage - 1 })}
                          className="px-3 py-1.5 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] font-semibold flex items-center gap-1 hover:bg-slate-50 dark:hover:bg-slate-800 disabled:opacity-40 disabled:cursor-not-allowed transition"
                        >
                          <ChevronLeft className="w-3.5 h-3.5" /> Previous
                        </button>

                        <span className="font-mono font-bold px-3 py-1.5 rounded-xl bg-slate-100 dark:bg-slate-800">
                          Page {studentPage} of {Math.max(1, Math.ceil((data.total || 0) / studentPageSize))}
                        </span>

                        <button
                          disabled={studentPage >= Math.ceil((data.total || 0) / studentPageSize)}
                          onClick={() => handleFilterChange({ page: studentPage + 1 })}
                          className="px-3 py-1.5 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] font-semibold flex items-center gap-1 hover:bg-slate-50 dark:hover:bg-slate-800 disabled:opacity-40 disabled:cursor-not-allowed transition"
                        >
                          Next <ChevronRight className="w-3.5 h-3.5" />
                        </button>
                      </div>
                    </div>
                  )}
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
                        {(Array.isArray(data) ? data : (data?.faculty || data?.items || [])).map((f: any) => (
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
                        {(Array.isArray(data) ? data : (data?.runs || data?.items || [])).map((r: any) => (
                          <tr key={r.id}>
                            <td className="font-mono font-bold text-indigo-600 dark:text-indigo-400">{r.month_year}</td>
                            <td className="font-mono">{r.faculty_count}</td>
                            <td className="font-mono">INR {Number(r.total_gross).toLocaleString()}</td>
                            <td className="font-mono font-bold text-emerald-600">INR {Number(r.total_net).toLocaleString()}</td>
                            <td><Badge label={r.status} variant={r.status === "PAID" ? "success" : "warning"} /></td>
                            <td className="text-xs text-[#64708A]">{r.generated_at}</td>
                            <td>
                              {r.status === "DRAFT" ? (
                                <button
                                  onClick={async () => {
                                    try {
                                      await api.admin.markPayrollPaid(r.id);
                                      setToast({ msg: "Payroll disbursed and marked PAID.", type: "success" });
                                      loadTab("payroll");
                                    } catch (e: any) {
                                      setToast({ msg: e.message || "Failed to disburse.", type: "error" });
                                    }
                                  }}
                                  className="px-3 py-1 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white font-semibold text-xs transition"
                                >
                                  Disburse & Pay
                                </button>
                              ) : (
                                <span className="text-xs text-emerald-600 font-semibold flex items-center gap-1">
                                  <CheckCircle className="w-3.5 h-3.5" /> Disbursed
                                </span>
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
                      <h2 className="text-base font-bold text-[#0B1020] dark:text-white">Active Curriculum Courses</h2>
                      <p className="text-xs text-[#64708A]">Course master catalog across programmes and departments</p>
                    </div>
                    <button
                      onClick={() => setCourseModal(true)}
                      className="px-4 py-2.5 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-semibold text-xs shadow-md shadow-indigo-600/20 flex items-center gap-2 transition"
                    >
                      <Plus className="w-4 h-4" /> Add New Course
                    </button>
                  </div>

                  <div className="table-container">
                    <table>
                      <thead>
                        <tr>
                          <th>Code</th>
                          <th>Course Name</th>
                          <th>Credits</th>
                          <th>Department</th>
                          <th>Type</th>
                        </tr>
                      </thead>
                      <tbody>
                        {(data.courses || []).map((c: any) => (
                          <tr key={c.id}>
                            <td className="font-mono font-bold text-indigo-600 dark:text-indigo-400">{c.code}</td>
                            <td className="font-semibold text-[#0B1020] dark:text-white">{c.name}</td>
                            <td className="font-mono">{c.credits}</td>
                            <td>{c.department_name}</td>
                            <td><Badge label={c.course_type} /></td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}

              {/* 5.6 TIMETABLE MANAGEMENT TAB */}
              {tab === "timetable" && data && (
                <div className="space-y-4">
                  <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
                    <div>
                      <h2 className="text-base font-bold text-[#0B1020] dark:text-white">Timetable Schedule & Conflicts</h2>
                      <p className="text-xs text-[#64708A]">Manage lecture allocations with automatic room and faculty double-booking detection.</p>
                    </div>
                    <div className="flex items-center gap-2">
                      <select
                        value={selectedSectionId}
                        onChange={(e) => {
                          const sid = Number(e.target.value);
                          setSelectedSectionId(sid);
                          api.admin.getTimetable(sid).then((tt) => setData((prev: any) => ({ ...prev, timetable: tt, sectionId: sid })));
                        }}
                        className="px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-white dark:bg-[#11162A] text-xs font-semibold"
                      >
                        {sectionsList.map((sec) => (
                          <option key={sec.id} value={sec.id}>
                            Section {sec.name} ({sec.programme_name || "B.Tech"} - Sem {sec.semester_number})
                          </option>
                        ))}
                      </select>
                      <button
                        onClick={() => setAddSlotModal(true)}
                        className="px-3.5 py-2 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-semibold text-xs flex items-center gap-1.5 transition"
                      >
                        <Plus className="w-4 h-4" /> Add Slot
                      </button>
                    </div>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    {daysOfWeek.map((dayName, idx) => {
                      const dayNum = idx + 1;
                      const slots = Array.isArray(data?.timetable) ? data.timetable : (data?.timetable?.slots || []);
                      const daySlots = slots.filter((s: any) => s.day_of_week === dayNum);
                      return (
                        <div key={dayName} className="card p-4 space-y-3">
                          <div className="flex justify-between items-center border-b border-[#E5E8F0] dark:border-[#1F293D] pb-2">
                            <span className="text-xs font-bold text-indigo-600 uppercase tracking-wider">{dayName}</span>
                            <span className="text-[10px] text-[#64708A] font-mono">{daySlots.length} periods</span>
                          </div>
                          {daySlots.length === 0 ? (
                            <p className="text-[11px] text-[#64708A] italic py-2">No periods allocated</p>
                          ) : (
                            <div className="space-y-2">
                              {daySlots.map((slot: any, sIdx: number) => (
                                <div key={sIdx} className="p-2.5 rounded-xl bg-slate-50 dark:bg-slate-800/50 border border-slate-100 dark:border-slate-800 text-xs">
                                  <div className="flex justify-between">
                                    <span className="font-mono font-bold text-indigo-600">{slot.course_code}</span>
                                    <span className="text-[10px] font-mono text-[#64708A]">{slot.start_time} - {slot.end_time}</span>
                                  </div>
                                  <p className="font-medium text-[#0B1020] dark:text-white mt-0.5 line-clamp-1">{slot.course_name}</p>
                                  <div className="flex justify-between text-[10px] text-[#64708A] mt-1">
                                    <span>{slot.faculty_name}</span>
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
                </div>
              )}

              {/* 5.7 ASSIGNMENTS OVERVIEW TAB */}
              {tab === "assignments" && data && (
                <div className="space-y-4">
                  <div>
                    <h2 className="text-base font-bold text-[#0B1020] dark:text-white">Assignments Overview</h2>
                    <p className="text-xs text-[#64708A]">All active course assignments created across departments and sections.</p>
                  </div>

                  <div className="table-container">
                    <table>
                      <thead>
                        <tr>
                          <th>Course</th>
                          <th>Section</th>
                          <th>Faculty</th>
                          <th>Title</th>
                          <th>Due Date</th>
                          <th>Submissions</th>
                        </tr>
                      </thead>
                      <tbody>
                        {(Array.isArray(data) ? data : (data?.assignments || data?.items || [])).map((a: any) => (
                          <tr key={a.id}>
                            <td className="font-mono font-bold text-indigo-600">{a.course_code}</td>
                            <td>Section {a.section_name}</td>
                            <td className="font-semibold">{a.faculty_name}</td>
                            <td>{a.title}</td>
                            <td className="font-mono text-xs">{new Date(a.due_date).toLocaleDateString()}</td>
                            <td><Badge label={`${a.submission_count} submitted`} variant="info" /></td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}

              {/* 5.8 REPORTS & ANALYTICS TAB */}
              {tab === "reports" && data && (
                <div className="space-y-6">
                  <div>
                    <h2 className="text-base font-bold text-[#0B1020] dark:text-white">Institutional Reports & Analytics</h2>
                    <p className="text-xs text-[#64708A]">Comprehensive metrics across student enrollment, departmental strength, and fee reconciliation.</p>
                  </div>

                  {/* Fee Summary Cards */}
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <StatCard title="Total Billed" value={`INR ${Number(data.fees?.total_billed || 0).toLocaleString()}`} icon={DollarSign} color="indigo" />
                    <StatCard title="Total Collected" value={`INR ${Number(data.fees?.total_collected || 0).toLocaleString()}`} icon={CheckCircle} color="emerald" />
                    <StatCard title="Pending Outstanding" value={`INR ${Number(data.fees?.total_pending || 0).toLocaleString()}`} icon={AlertTriangle} color="rose" />
                  </div>

                  {/* Department Strengths */}
                  <div className="card p-6 space-y-4">
                    <h3 className="text-sm font-bold text-[#0B1020] dark:text-white">Department Summary</h3>
                    <div className="table-container">
                      <table>
                        <thead>
                          <tr>
                            <th>Department</th>
                            <th>Total Students</th>
                            <th>Total Faculty</th>
                            <th>Courses Offered</th>
                          </tr>
                        </thead>
                        <tbody>
                          {(data.departments || []).map((d: any, idx: number) => (
                            <tr key={idx}>
                              <td className="font-semibold">{d.department_name}</td>
                              <td className="font-mono font-bold">{d.total_students}</td>
                              <td className="font-mono">{d.total_faculty}</td>
                              <td className="font-mono">{d.total_courses}</td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </div>
                </div>
              )}

              {/* 5.9 ARREAR REGISTRY TAB */}
              {tab === "arrears" && data && (
                <div className="space-y-4">
                  <div>
                    <h2 className="text-base font-bold text-[#0B1020] dark:text-white">Arrear Registry & Examination Records</h2>
                    <p className="text-xs text-[#64708A]">Registry of failed subjects and students eligible for re-examinations</p>
                  </div>

                  <div className="table-container">
                    <table>
                      <thead>
                        <tr>
                          <th>Student Name</th>
                          <th>Reg No</th>
                          <th>Course</th>
                          <th>Semester</th>
                          <th>Attempts</th>
                          <th>Status</th>
                        </tr>
                      </thead>
                      <tbody>
                        {(Array.isArray(data) ? data : (data?.arrears || data?.items || [])).map((a: any) => (
                          <tr key={a.id}>
                            <td className="font-semibold text-[#0B1020] dark:text-white">{a.full_name}</td>
                            <td className="font-mono font-bold text-rose-600 dark:text-rose-400">{a.registration_number}</td>
                            <td>{a.course_code} - {a.course_name}</td>
                            <td>Sem {a.semester_number}</td>
                            <td className="font-mono">{a.attempts_count}</td>
                            <td><Badge label={a.status} variant={a.status === "REGISTERED_FOR_REEXAM" ? "warning" : "danger"} /></td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}

              {/* 5.10 ANNOUNCEMENTS TAB */}
              {tab === "announcements" && data && (
                <div className="space-y-4">
                  <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
                    <div>
                      <h2 className="text-base font-bold text-[#0B1020] dark:text-white">Announcements & Notices</h2>
                      <p className="text-xs text-[#64708A]">Disseminate notifications to students, faculty, or campus-wide</p>
                    </div>
                    <button
                      onClick={() => setAnnouncementModal(true)}
                      className="px-4 py-2.5 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-semibold text-xs shadow-md shadow-indigo-600/20 flex items-center gap-2 transition"
                    >
                      <Plus className="w-4 h-4" /> New Announcement
                    </button>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {(Array.isArray(data) ? data : (data?.announcements || data?.items || [])).map((a: any) => (
                      <div key={a.id} className="card p-5 space-y-3">
                        <div className="flex justify-between items-start">
                          <Badge label={a.priority} variant={a.priority === "URGENT" ? "danger" : "info"} />
                          <span className="text-[11px] font-mono text-[#64708A]">{a.created_at}</span>
                        </div>
                        <h3 className="font-bold text-sm text-[#0B1020] dark:text-white">{a.title}</h3>
                        <p className="text-xs text-[#64708A] line-clamp-3">{a.content}</p>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* 5.11 LOGS & REGISTERS TAB */}
              {tab === "logs" && data && (
                <div className="space-y-4">
                  <div className="flex gap-2 border-b border-[#E5E8F0] dark:border-[#1F293D] pb-3 text-xs font-semibold">
                    {[
                      { id: "audit", label: "Audit Trail" },
                      { id: "login", label: "Authentication Logs" },
                      { id: "blocked", label: "Blocked Accounts" },
                      { id: "comms", label: "Email Outbox" },
                    ].map((st) => (
                      <button
                        key={st.id}
                        onClick={() => setData({ ...data, subtab: st.id })}
                        className={`px-3 py-1.5 rounded-lg transition ${
                          data.subtab === st.id
                            ? "bg-indigo-600 text-white"
                            : "text-[#64708A] hover:bg-slate-100 dark:hover:bg-slate-800"
                        }`}
                      >
                        {st.label}
                      </button>
                    ))}
                  </div>

                  {data.subtab === "audit" && (
                    <div className="table-container">
                      <table>
                        <thead>
                          <tr>
                            <th>Action</th>
                            <th>Entity</th>
                            <th>ID</th>
                            <th>User</th>
                            <th>IP Address</th>
                            <th>Timestamp</th>
                          </tr>
                        </thead>
                        <tbody>
                          {(data.audit || []).map((a: any) => (
                            <tr key={a.id}>
                              <td><Badge label={a.action} variant="info" /></td>
                              <td className="font-semibold">{a.entity_name}</td>
                              <td className="font-mono text-xs">{a.entity_id || "N/A"}</td>
                              <td className="text-xs">{a.user_email || "System"}</td>
                              <td className="font-mono text-xs">{a.ip_address}</td>
                              <td className="text-xs text-[#64708A]">{a.created_at}</td>
                            </tr>
                          ))}
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
                            <th>Logged At</th>
                          </tr>
                        </thead>
                        <tbody>
                          {(data.login || []).map((l: any) => (
                            <tr key={l.id}>
                              <td className="font-mono font-bold text-xs">{l.identifier}</td>
                              <td><Badge label={l.role || "USER"} /></td>
                              <td><Badge label={l.status} variant={l.status === "SUCCESS" ? "success" : "danger"} /></td>
                              <td className="font-mono text-xs">{l.ip_address}</td>
                              <td className="text-xs text-[#64708A] font-mono">{l.logged_at}</td>
                            </tr>
                          ))}
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
                          {(data.blocked || []).map((b: any) => (
                            <tr key={b.id}>
                              <td className="font-semibold">{b.account_email}</td>
                              <td><Badge label={b.account_role || "USER"} /></td>
                              <td><Badge label={b.action} variant="danger" /></td>
                              <td className="text-xs text-[#64708A]">{b.reason}</td>
                              <td className="font-mono text-xs">{b.ip_address}</td>
                              <td className="text-xs text-[#64708A]">{b.created_at}</td>
                            </tr>
                          ))}
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
                            <th>Status</th>
                            <th>Sent At</th>
                          </tr>
                        </thead>
                        <tbody>
                          {(data.comms || []).map((c: any) => (
                            <tr key={c.id}>
                              <td className="font-mono text-xs font-semibold">{c.recipient_email}</td>
                              <td>{c.subject}</td>
                              <td><Badge label={c.status} variant={c.status === "SENT" ? "success" : "info"} /></td>
                              <td className="text-xs text-[#64708A]">{c.sent_at || c.created_at}</td>
                            </tr>
                          ))}
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

      {/* Global Search Modal */}
      <GlobalSearchModal isOpen={searchModalOpen} onClose={() => setSearchModalOpen(false)} />

      {/* Password Change Modal */}
      <PasswordChangeModal
        isOpen={pwdModalOpen}
        onClose={() => setPwdModalOpen(false)}
        onDone={() => setToast({ msg: "Admin password updated successfully.", type: "success" })}
      />

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
                  className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent"
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
                    className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent"
                  />
                </div>
                <div>
                  <label className="block font-semibold mb-1">Phone Number</label>
                  <input
                    type="tel"
                    required
                    placeholder="+91 9876543210"
                    value={newStudent.phone}
                    onChange={(e) => setNewStudent({ ...newStudent, phone: e.target.value })}
                    className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent"
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold mb-1">Date of Birth</label>
                  <input
                    type="date"
                    required
                    value={newStudent.dob}
                    onChange={(e) => setNewStudent({ ...newStudent, dob: e.target.value })}
                    className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent"
                  />
                </div>
                <div>
                  <label className="block font-semibold mb-1">Gender</label>
                  <select
                    value={newStudent.gender}
                    onChange={(e) => setNewStudent({ ...newStudent, gender: e.target.value })}
                    className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-white dark:bg-[#11162A]"
                  >
                    <option value="MALE">MALE</option>
                    <option value="FEMALE">FEMALE</option>
                    <option value="OTHER">OTHER</option>
                  </select>
                </div>
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold mb-1">Aadhaar Number (Optional)</label>
                  <input
                    type="text"
                    placeholder="12 digits"
                    value={newStudent.aadhaar}
                    onChange={(e) => setNewStudent({ ...newStudent, aadhaar: e.target.value })}
                    className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent"
                  />
                </div>
                <div>
                  <label className="block font-semibold mb-1">ABC ID (Optional)</label>
                  <input
                    type="text"
                    placeholder="12 digits"
                    value={newStudent.abcId}
                    onChange={(e) => setNewStudent({ ...newStudent, abcId: e.target.value })}
                    className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent"
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold mb-1">Father's Name</label>
                  <input
                    type="text"
                    placeholder="Father Name"
                    value={newStudent.fatherName}
                    onChange={(e) => setNewStudent({ ...newStudent, fatherName: e.target.value })}
                    className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent"
                  />
                </div>
                <div>
                  <label className="block font-semibold mb-1">Parent Phone</label>
                  <input
                    type="tel"
                    placeholder="+91..."
                    value={newStudent.parentPhone}
                    onChange={(e) => setNewStudent({ ...newStudent, parentPhone: e.target.value })}
                    className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent"
                  />
                </div>
              </div>
              <div className="flex justify-end gap-2 pt-4 border-t border-[#E5E8F0] dark:border-[#1F293D]">
                <button type="button" onClick={() => setStudentModal(false)} className="px-4 py-2 rounded-xl border font-semibold text-xs">
                  Cancel
                </button>
                <button type="submit" className="px-4 py-2 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-semibold text-xs shadow-md transition">
                  Enroll & Generate ID
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Edit Student Modal */}
      {editStudentModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
          <div className="bg-white dark:bg-[#11162A] rounded-2xl max-w-md w-full border border-[#E5E8F0] dark:border-[#1F293D] shadow-2xl p-6 space-y-4">
            <div className="flex justify-between items-center pb-3 border-b border-[#E5E8F0] dark:border-[#1F293D]">
              <h3 className="font-bold text-sm text-[#0B1020] dark:text-white">Edit Student Profile</h3>
              <button onClick={() => setEditStudentModal(null)} className="p-1 text-slate-400">✕</button>
            </div>
            <form onSubmit={handleUpdateStudent} className="space-y-3 text-xs">
              <div>
                <label className="block text-[#64708A] mb-1">Full Name</label>
                <input
                  type="text"
                  required
                  value={editStudentModal.full_name}
                  onChange={(e) => setEditStudentModal({ ...editStudentModal, full_name: e.target.value })}
                  className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent"
                />
              </div>
              <div>
                <label className="block text-[#64708A] mb-1">Phone</label>
                <input
                  type="text"
                  required
                  value={editStudentModal.phone}
                  onChange={(e) => setEditStudentModal({ ...editStudentModal, phone: e.target.value })}
                  className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent"
                />
              </div>
              <div>
                <label className="block text-[#64708A] mb-1">Status</label>
                <select
                  value={editStudentModal.status}
                  onChange={(e) => setEditStudentModal({ ...editStudentModal, status: e.target.value })}
                  className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-white dark:bg-[#11162A]"
                >
                  <option value="ACTIVE">ACTIVE</option>
                  <option value="ON_LEAVE">ON_LEAVE</option>
                  <option value="GRADUATED">GRADUATED</option>
                  <option value="DISCONTINUED">DISCONTINUED</option>
                </select>
              </div>
              <div className="pt-2 flex justify-end gap-2">
                <button type="button" onClick={() => setEditStudentModal(null)} className="px-4 py-2 rounded-xl border text-xs">
                  Cancel
                </button>
                <button type="submit" className="px-4 py-2 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-semibold text-xs">
                  Save Changes
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
              <button onClick={() => setFacultyModal(false)} className="text-slate-400 text-lg">✕</button>
            </div>
            <form onSubmit={handleCreateFaculty} className="space-y-3 mt-4 text-xs">
              <div>
                <label className="block font-semibold mb-1">Full Name</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Dr. Aris Thorne"
                  value={newFaculty.fullName}
                  onChange={(e) => setNewFaculty({ ...newFaculty, fullName: e.target.value })}
                  className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent"
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold mb-1">Institutional / Login Email</label>
                  <input
                    type="email"
                    required
                    placeholder="prof@college.local"
                    value={newFaculty.email}
                    onChange={(e) => setNewFaculty({ ...newFaculty, email: e.target.value })}
                    className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent"
                  />
                </div>
                <div>
                  <label className="block font-semibold mb-1">Phone</label>
                  <input
                    type="tel"
                    required
                    placeholder="+91..."
                    value={newFaculty.phone}
                    onChange={(e) => setNewFaculty({ ...newFaculty, phone: e.target.value })}
                    className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent"
                  />
                </div>
              </div>
              <div>
                <label className="block font-semibold mb-1">Highest Qualification</label>
                <input
                  type="text"
                  required
                  value={newFaculty.qualification}
                  onChange={(e) => setNewFaculty({ ...newFaculty, qualification: e.target.value })}
                  className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent"
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold mb-1">Experience (Years)</label>
                  <input
                    type="number"
                    min={0}
                    value={newFaculty.experienceYears}
                    onChange={(e) => setNewFaculty({ ...newFaculty, experienceYears: Number(e.target.value) })}
                    className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent"
                  />
                </div>
                <div>
                  <label className="block font-semibold mb-1">Basic Monthly Pay (INR)</label>
                  <input
                    type="number"
                    value={newFaculty.basicPay}
                    onChange={(e) => setNewFaculty({ ...newFaculty, basicPay: Number(e.target.value) })}
                    className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent"
                  />
                </div>
              </div>
              <div className="flex justify-end gap-2 pt-4 border-t border-[#E5E8F0] dark:border-[#1F293D]">
                <button type="button" onClick={() => setFacultyModal(false)} className="px-4 py-2 rounded-xl border font-semibold text-xs">
                  Cancel
                </button>
                <button type="submit" className="px-4 py-2 rounded-xl bg-teal-600 hover:bg-teal-700 text-white font-semibold text-xs shadow-md transition">
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
                  className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent font-mono"
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
                  className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent"
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
                  className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent font-mono"
                />
              </div>
              <div className="flex justify-end gap-2 pt-4 border-t border-[#E5E8F0] dark:border-[#1F293D]">
                <button type="button" onClick={() => setCourseModal(false)} className="px-4 py-2 rounded-xl border font-semibold text-xs">
                  Cancel
                </button>
                <button type="submit" className="px-4 py-2 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-semibold text-xs shadow-md transition">
                  Save Course
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Add Timetable Slot Modal */}
      {addSlotModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
          <div className="bg-white dark:bg-[#11162A] rounded-2xl max-w-md w-full border border-[#E5E8F0] dark:border-[#1F293D] shadow-2xl p-6 space-y-4">
            <div className="flex justify-between items-center pb-3 border-b border-[#E5E8F0] dark:border-[#1F293D]">
              <h3 className="font-bold text-sm text-[#0B1020] dark:text-white">Add Timetable Lecture Slot</h3>
              <button onClick={() => setAddSlotModal(false)} className="text-slate-400">✕</button>
            </div>
            <form onSubmit={handleCreateSlot} className="space-y-3 text-xs">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-[#64708A] mb-1">Day of Week</label>
                  <select
                    value={newSlot.dayOfWeek}
                    onChange={(e) => setNewSlot({ ...newSlot, dayOfWeek: Number(e.target.value) })}
                    className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-white dark:bg-[#11162A]"
                  >
                    {daysOfWeek.map((d, i) => (
                      <option key={d} value={i + 1}>{d}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-[#64708A] mb-1">Period Number</label>
                  <input
                    type="number"
                    min={1}
                    max={8}
                    value={newSlot.periodNumber}
                    onChange={(e) => setNewSlot({ ...newSlot, periodNumber: Number(e.target.value) })}
                    className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent"
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-[#64708A] mb-1">Start Time</label>
                  <input
                    type="time"
                    value={newSlot.startTime}
                    onChange={(e) => setNewSlot({ ...newSlot, startTime: e.target.value })}
                    className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent"
                  />
                </div>
                <div>
                  <label className="block text-[#64708A] mb-1">End Time</label>
                  <input
                    type="time"
                    value={newSlot.endTime}
                    onChange={(e) => setNewSlot({ ...newSlot, endTime: e.target.value })}
                    className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent"
                  />
                </div>
              </div>
              <div className="flex justify-end gap-2 pt-3">
                <button type="button" onClick={() => setAddSlotModal(false)} className="px-4 py-2 rounded-xl border text-xs">
                  Cancel
                </button>
                <button type="submit" className="px-4 py-2 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-semibold text-xs">
                  Check & Save Slot
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
                  className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent"
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

              {/* Fees in detail modal */}
              {Array.isArray(studentDetail.fees) && studentDetail.fees.length > 0 && (
                <div>
                  <div className="flex justify-between items-center mb-2">
                    <h4 className="font-bold text-sm text-[#0B1020] dark:text-white">Fee Statements</h4>
                  </div>
                  <div className="space-y-2">
                    {(Array.isArray(studentDetail.fees) ? studentDetail.fees : []).map((fee: any) => (
                      <div key={fee.id} className="p-3 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] flex justify-between items-center text-xs">
                        <div>
                          <p className="font-semibold text-[#0B1020] dark:text-white">{fee.structure_name || "Tuition & Academics"}</p>
                          <p className="text-[#64708A]">Due: INR {fee.balance_due != null ? fee.balance_due : (fee.amount_due != null ? fee.amount_due : fee.total_payable)} | Paid: INR {fee.total_paid != null ? fee.total_paid : (fee.paid_amount || 0)}</p>
                        </div>
                        <div className="flex items-center gap-2">
                          <Badge label={fee.status} variant={fee.status === "PAID" ? "success" : "warning"} />
                          {fee.status !== "PAID" && (
                            <button
                              onClick={() => setFeePaymentModal({ feeId: fee.id, amount: Number(fee.balance_due != null ? fee.balance_due : (fee.amount_due || fee.total_payable || 0)) })}
                              className="px-2.5 py-1 rounded-lg bg-emerald-600 text-white font-semibold text-[11px]"
                            >
                              Record Payment
                            </button>
                          )}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

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

      {/* Record Fee Payment Modal */}
      {feePaymentModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
          <div className="bg-white dark:bg-[#11162A] rounded-2xl max-w-sm w-full border border-[#E5E8F0] dark:border-[#1F293D] shadow-2xl p-6 space-y-4">
            <div className="flex justify-between items-center pb-3 border-b border-[#E5E8F0] dark:border-[#1F293D]">
              <h3 className="font-bold text-sm text-[#0B1020] dark:text-white">Record Fee Payment</h3>
              <button onClick={() => setFeePaymentModal(null)} className="p-1 text-slate-400">✕</button>
            </div>
            <form onSubmit={handleRecordPayment} className="space-y-3 text-xs">
              <div>
                <label className="block text-[#64708A] mb-1">Amount to Collect (INR)</label>
                <input
                  type="number"
                  required
                  min={1}
                  value={feePaymentModal.amount}
                  onChange={(e) => setFeePaymentModal({ ...feePaymentModal, amount: Number(e.target.value) })}
                  className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent font-mono"
                />
              </div>
              <div>
                <label className="block text-[#64708A] mb-1">Payment Mode</label>
                <select
                  value={feePaymentModal.mode || "ONLINE"}
                  onChange={(e) => setFeePaymentModal({ ...feePaymentModal, mode: e.target.value })}
                  className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-white dark:bg-[#11162A]"
                >
                  <option value="ONLINE">ONLINE / UPI</option>
                  <option value="BANK_TRANSFER">NEFT / RTGS</option>
                  <option value="CHEQUE">CHEQUE</option>
                  <option value="CASH">CASH COUNTER</option>
                </select>
              </div>
              <div className="pt-2 flex justify-end gap-2">
                <button type="button" onClick={() => setFeePaymentModal(null)} className="px-4 py-2 rounded-xl border text-xs">
                  Cancel
                </button>
                <button type="submit" className="px-4 py-2 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-semibold text-xs">
                  Issue Receipt
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {toast && <Toast message={toast.msg} type={toast.type} onClose={() => setToast(null)} />}
    </div>
  );
}
