import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import {
  Crown, Users, GraduationCap, Building2, TrendingUp, DollarSign,
  ShieldAlert, BookOpen, Layers, CheckCircle2, AlertCircle, Plus,
  LogOut, RefreshCw, BarChart3, Search, Calendar, UserCheck, Shield
} from "lucide-react";
import { api, getStoredAuth, clearAuth } from "./api";
import { ThemeToggle, NotificationBell, PasswordChangeModal, Badge } from "./ui";

export function OwnerPortal() {
  const navigate = useNavigate();
  const auth = getStoredAuth();
  const [tab, setTab] = useState<"overview" | "historical" | "departments" | "admins" | "finance" | "audit">("overview");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Data states
  const [overview, setOverview] = useState<any>(null);
  const [historical, setHistorical] = useState<any>(null);
  const [departments, setDepartments] = useState<any[]>([]);
  const [admins, setAdmins] = useState<any[]>([]);
  const [finance, setFinance] = useState<any>(null);
  const [auditLogs, setAuditLogs] = useState<any[]>([]);

  // Modals & Filters
  const [showPwdModal, setShowPwdModal] = useState(false);
  const [showAddAdminModal, setShowAddAdminModal] = useState(false);
  const [newAdmin, setNewAdmin] = useState({ email: "", password: "", role: "PRINCIPAL", fullName: "", phone: "" });
  const [selectedHistYear, setSelectedHistYear] = useState<number | "ALL">("ALL");

  useEffect(() => {
    loadData();
  }, [tab, selectedHistYear]);

  async function loadData() {
    setLoading(true);
    setError(null);
    try {
      if (tab === "overview") {
        const data = await api.owner.getOverview();
        setOverview(data);
      } else if (tab === "historical") {
        const data = await api.owner.getHistoricalAnalytics(selectedHistYear === "ALL" ? undefined : selectedHistYear);
        setHistorical(data);
      } else if (tab === "departments") {
        const data = await api.owner.getDepartments();
        setDepartments(data);
      } else if (tab === "admins") {
        const data = await api.owner.getAdmins();
        setAdmins(data);
      } else if (tab === "finance") {
        const data = await api.owner.getFinancialSummary();
        setFinance(data);
      } else if (tab === "audit") {
        const data = await api.owner.getAuditLogs(100);
        setAuditLogs(data);
      }
    } catch (err: any) {
      setError(err.message || "Failed to load executive portal data");
    } finally {
      setLoading(false);
    }
  }

  async function handleCreateAdmin(e: React.FormEvent) {
    e.preventDefault();
    try {
      await api.owner.createAdmin(newAdmin);
      setShowAddAdminModal(false);
      setNewAdmin({ email: "", password: "", role: "PRINCIPAL", fullName: "", phone: "" });
      loadData();
    } catch (err: any) {
      alert("Failed to create administrator: " + err.message);
    }
  }

  function handleLogout() {
    clearAuth();
    navigate("/owner/login");
  }

  return (
    <div className="min-h-screen bg-[#F6F7FB] dark:bg-[#070B19] text-[#0B1020] dark:text-[#E2E8F0] flex flex-col font-sans transition-colors duration-200">
      {/* Top Executive Header */}
      <header className="sticky top-0 z-40 bg-white/90 dark:bg-[#0C1226]/90 backdrop-blur border-b border-[#E5E8F0] dark:border-[#1A233D] px-6 py-3.5 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-indigo-700 to-indigo-950 flex items-center justify-center text-amber-400 shadow-md">
            <Crown className="w-5 h-5" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <span className="font-extrabold text-base tracking-tight text-[#0B1020] dark:text-white">Imperial Institute</span>
              <span className="px-2 py-0.5 rounded-full bg-amber-500/10 border border-amber-500/30 text-[10px] font-bold text-amber-600 dark:text-amber-400 uppercase tracking-widest">
                Root Owner
              </span>
            </div>
            <p className="text-[11px] text-[#64708A] dark:text-[#8E9BB5] font-mono">Institutional Command Center • Autonomous 2026</p>
          </div>
        </div>

        {/* Global actions */}
        <div className="flex items-center gap-3">
          <ThemeToggle />
          <NotificationBell />
          <div className="h-6 w-px bg-[#E5E8F0] dark:bg-[#1F293D]" />
          <div className="flex items-center gap-2.5">
            <div className="text-right hidden sm:block">
              <p className="text-xs font-bold text-[#0B1020] dark:text-white leading-tight">{auth?.name || "Dr. Rajeshwar Rao"}</p>
              <p className="text-[10px] text-indigo-600 dark:text-indigo-400 font-mono font-medium">{auth?.code || "OWN0001"}</p>
            </div>
            <button
              onClick={() => setShowPwdModal(true)}
              className="p-2 rounded-xl bg-slate-100 dark:bg-[#1A233D] text-[#64708A] hover:text-[#0B1020] dark:hover:text-white transition"
              title="Security Settings"
            >
              <Shield className="w-4 h-4" />
            </button>
            <button
              onClick={handleLogout}
              className="p-2 rounded-xl bg-rose-50 dark:bg-rose-950/40 text-rose-600 dark:text-rose-400 hover:bg-rose-100 transition"
              title="Sign Out"
            >
              <LogOut className="w-4 h-4" />
            </button>
          </div>
        </div>
      </header>

      {/* Main Navigation Bar */}
      <nav className="bg-white dark:bg-[#0C1226] border-b border-[#E5E8F0] dark:border-[#1A233D] px-6 py-2 flex items-center justify-between overflow-x-auto gap-4">
        <div className="flex items-center gap-1.5 text-xs font-semibold">
          {[
            { id: "overview", label: "Executive Overview", icon: TrendingUp },
            { id: "historical", label: "Historical Cohorts (2015-2026)", icon: Calendar },
            { id: "departments", label: "Departments & Ratios", icon: Building2 },
            { id: "admins", label: "Administration (Principal & Deans)", icon: Users },
            { id: "finance", label: "Financial Governance", icon: DollarSign },
            { id: "audit", label: "Security & Audit Logs", icon: ShieldAlert },
          ].map((item) => {
            const Icon = item.icon;
            const active = tab === item.id;
            return (
              <button
                key={item.id}
                onClick={() => setTab(item.id as any)}
                className={`px-3 py-2 rounded-xl flex items-center gap-2 transition whitespace-nowrap ${
                  active
                    ? "bg-indigo-600 text-white shadow-sm"
                    : "text-[#64708A] dark:text-[#8E9BB5] hover:bg-slate-100 dark:hover:bg-[#172038] hover:text-[#0B1020] dark:hover:text-white"
                }`}
              >
                <Icon className="w-4 h-4" />
                <span>{item.label}</span>
              </button>
            );
          })}
        </div>

        <button
          onClick={loadData}
          disabled={loading}
          className="p-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] text-[#64708A] hover:text-indigo-600 dark:hover:text-indigo-400 transition"
          title="Refresh Data"
        >
          <RefreshCw className={`w-4 h-4 ${loading ? "animate-spin" : ""}`} />
        </button>
      </nav>

      {/* Main Content Area */}
      <main className="flex-1 p-6 max-w-7xl w-full mx-auto space-y-6">
        {error && (
          <div className="p-4 rounded-2xl bg-rose-50 dark:bg-rose-950/40 border border-rose-200 dark:border-rose-900 text-rose-700 dark:text-rose-300 flex items-center gap-3 text-xs">
            <AlertCircle className="w-5 h-5 shrink-0" />
            <span>{error}</span>
          </div>
        )}

        {/* TAB 1: EXECUTIVE OVERVIEW */}
        {tab === "overview" && overview && (
          <div className="space-y-6">
            {/* Top KPIs Banner */}
            <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-4">
              <div className="card p-4">
                <p className="text-[11px] text-[#64708A] font-medium">Active Students</p>
                <p className="text-2xl font-bold font-mono-numbers mt-1 text-indigo-600 dark:text-indigo-400">
                  {Number(overview.kpis.activeStudents).toLocaleString()}
                </p>
                <p className="text-[10px] text-emerald-600 mt-1">● Years 1 to 4</p>
              </div>
              <div className="card p-4">
                <p className="text-[11px] text-[#64708A] font-medium">Graduated Alumni</p>
                <p className="text-2xl font-bold font-mono-numbers mt-1 text-violet-600 dark:text-violet-400">
                  {Number(overview.kpis.alumniGraduated).toLocaleString()}
                </p>
                <p className="text-[10px] text-[#64708A] mt-1">2015 - 2025 cohorts</p>
              </div>
              <div className="card p-4">
                <p className="text-[11px] text-[#64708A] font-medium">Faculty Strength</p>
                <p className="text-2xl font-bold font-mono-numbers mt-1 text-teal-600 dark:text-teal-400">
                  {overview.kpis.totalFaculty}
                </p>
                <p className="text-[10px] text-teal-600 mt-1">Professors & HODs</p>
              </div>
              <div className="card p-4">
                <p className="text-[11px] text-[#64708A] font-medium">Departments</p>
                <p className="text-2xl font-bold font-mono-numbers mt-1 text-[#0B1020] dark:text-white">
                  {overview.kpis.departmentsCount}
                </p>
                <p className="text-[10px] text-[#64708A] mt-1">CSE, ECE, EEE, etc.</p>
              </div>
              <div className="card p-4">
                <p className="text-[11px] text-[#64708A] font-medium">Tuition Collected</p>
                <p className="text-2xl font-bold font-mono-numbers mt-1 text-emerald-600 dark:text-emerald-400">
                  INR {Math.round(Number(overview.kpis.feesCollected) / 100000)}L
                </p>
                <p className="text-[10px] text-emerald-600 mt-1">Audited income</p>
              </div>
              <div className="card p-4">
                <p className="text-[11px] text-[#64708A] font-medium">Avg Attendance</p>
                <p className="text-2xl font-bold font-mono-numbers mt-1 text-amber-600 dark:text-amber-400">
                  {overview.kpis.avgAttendance}%
                </p>
                <p className="text-[10px] text-amber-600 mt-1">Campus aggregate</p>
              </div>
            </div>

            {/* Year-wise Student Strength & Gender Distribution */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              {/* Year Strength */}
              <div className="card p-6">
                <h3 className="text-sm font-bold text-[#0B1020] dark:text-white mb-4 flex items-center justify-between">
                  <span>Current Year-wise Student Strength</span>
                  <span className="text-xs font-normal text-[#64708A]">Academic Cycle 2025-2026</span>
                </h3>
                <div className="space-y-4">
                  {(overview.yearStrength || []).map((y: any) => {
                    const yearLabels = ["", "1st Year (Freshers)", "2nd Year (Sophomores)", "3rd Year (Juniors)", "4th Year (Seniors)"];
                    const label = yearLabels[y.year_of_study] || `Year ${y.year_of_study}`;
                    const count = Number(y.count);
                    const pct = Math.min(100, Math.round((count / Math.max(overview.kpis.activeStudents, 1)) * 100));
                    return (
                      <div key={y.year_of_study} className="space-y-1.5">
                        <div className="flex justify-between text-xs font-semibold">
                          <span>{label}</span>
                          <span className="font-mono text-indigo-600 dark:text-indigo-400">{count} Students ({pct}%)</span>
                        </div>
                        <div className="h-2.5 w-full bg-slate-100 dark:bg-[#1F293D] rounded-full overflow-hidden">
                          <div className="h-full bg-indigo-600 rounded-full transition-all duration-500" style={{ width: `${pct}%` }} />
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* Gender Ratio Card */}
              <div className="card p-6">
                <h3 className="text-sm font-bold text-[#0B1020] dark:text-white mb-4">Campus Gender Diversity</h3>
                <div className="grid grid-cols-2 gap-4 my-6">
                  <div className="p-4 rounded-2xl bg-blue-50 dark:bg-blue-950/30 border border-blue-200 dark:border-blue-900 text-center">
                    <p className="text-xs font-semibold text-blue-700 dark:text-blue-400">Boys (Male)</p>
                    <p className="text-3xl font-extrabold font-mono-numbers mt-1 text-blue-900 dark:text-blue-200">{overview.gender?.male || 0}</p>
                    <p className="text-[11px] text-[#64708A] mt-1">
                      {Math.round(((overview.gender?.male || 1) / Math.max(overview.kpis.activeStudents, 1)) * 100)}% of student body
                    </p>
                  </div>
                  <div className="p-4 rounded-2xl bg-pink-50 dark:bg-pink-950/30 border border-pink-200 dark:border-pink-900 text-center">
                    <p className="text-xs font-semibold text-pink-700 dark:text-pink-400">Girls (Female)</p>
                    <p className="text-3xl font-extrabold font-mono-numbers mt-1 text-pink-900 dark:text-pink-200">{overview.gender?.female || 0}</p>
                    <p className="text-[11px] text-[#64708A] mt-1">
                      {Math.round(((overview.gender?.female || 1) / Math.max(overview.kpis.activeStudents, 1)) * 100)}% of student body
                    </p>
                  </div>
                </div>
                <p className="text-xs text-[#64708A] text-center">
                  Accreditation guideline compliance: Equal opportunity admissions maintained across all 6 engineering departments.
                </p>
              </div>
            </div>
          </div>
        )}

        {/* TAB 2: HISTORICAL COHORTS (2015-2026) */}
        {tab === "historical" && (
          <div className="card p-6 space-y-6">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
              <div>
                <h3 className="text-base font-bold text-[#0B1020] dark:text-white">Historical Academic Records (2015 - 2026)</h3>
                <p className="text-xs text-[#64708A]">Continuous 12-year longitudinal analysis of admission batches, progression, and graduation.</p>
              </div>

              <div className="flex items-center gap-2">
                <span className="text-xs font-semibold text-[#64708A]">Batch:</span>
                <select
                  value={selectedHistYear}
                  onChange={(e) => setSelectedHistYear(e.target.value === "ALL" ? "ALL" : Number(e.target.value))}
                  className="text-xs py-1.5 px-3 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-white dark:bg-[#11162A]"
                >
                  <option value="ALL">All Batches (2015-2026)</option>
                  {[2026, 2025, 2024, 2023, 2022, 2021, 2020, 2019, 2018, 2017, 2016, 2015].map((y) => (
                    <option key={y} value={y}>{y} Admission Batch</option>
                  ))}
                </select>
              </div>
            </div>

            <div className="table-container">
              <table>
                <thead>
                  <tr>
                    <th>Admission Year</th>
                    <th>Total Admissions</th>
                    <th>Boys (Male)</th>
                    <th>Girls (Female)</th>
                    <th>Active Students</th>
                    <th>1st Year</th>
                    <th>2nd Year</th>
                    <th>3rd Year</th>
                    <th>4th Year</th>
                    <th>Graduated Alumni</th>
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  {(historical?.cohorts || []).map((c: any) => (
                    <tr key={c.admission_year}>
                      <td className="font-mono font-bold text-indigo-600 dark:text-indigo-400">{c.admission_year}</td>
                      <td className="font-mono font-semibold">{c.total_admissions}</td>
                      <td className="font-mono text-blue-600">{c.male_count}</td>
                      <td className="font-mono text-pink-600">{c.female_count}</td>
                      <td className="font-mono font-semibold text-emerald-600">{c.active_count}</td>
                      <td className="font-mono text-xs">{c.year_1_count}</td>
                      <td className="font-mono text-xs">{c.year_2_count}</td>
                      <td className="font-mono text-xs">{c.year_3_count}</td>
                      <td className="font-mono text-xs">{c.year_4_count}</td>
                      <td className="font-mono font-semibold text-violet-600">{c.graduated_count}</td>
                      <td>
                        <Badge
                          label={c.admission_year <= 2021 ? "GRADUATED" : "STUDYING"}
                          variant={c.admission_year <= 2021 ? "purple" : "success"}
                        />
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Department-wise Historical Cohort Matrix */}
            <div className="mt-8 pt-6 border-t border-[#E5E8F0] dark:border-[#1F293D]">
              <h4 className="text-sm font-bold text-[#0B1020] dark:text-white mb-3">Department-wise Historical Matrix</h4>
              <div className="table-container max-h-96">
                <table>
                  <thead>
                    <tr>
                      <th>Year</th>
                      <th>Dept Code</th>
                      <th>Department Name</th>
                      <th>Total Enrolled</th>
                      <th>Boys</th>
                      <th>Girls</th>
                      <th>Gender Balance</th>
                    </tr>
                  </thead>
                  <tbody>
                    {(historical?.departmentBreakdown || []).map((d: any, idx: number) => {
                      const total = Number(d.student_count);
                      const girls = Number(d.female_count);
                      const girlPct = Math.round((girls / Math.max(total, 1)) * 100);
                      return (
                        <tr key={idx}>
                          <td className="font-mono">{d.admission_year}</td>
                          <td className="font-mono font-bold text-indigo-600">{d.department_code}</td>
                          <td>{d.department_name}</td>
                          <td className="font-mono font-bold">{total}</td>
                          <td className="font-mono text-blue-600">{d.male_count}</td>
                          <td className="font-mono text-pink-600">{d.female_count}</td>
                          <td>
                            <div className="flex items-center gap-2">
                              <div className="w-16 h-2 bg-slate-100 dark:bg-[#1F293D] rounded-full overflow-hidden">
                                <div className="h-full bg-pink-500 rounded-full" style={{ width: `${girlPct}%` }} />
                              </div>
                              <span className="text-[11px] font-mono text-[#64708A]">{girlPct}% Girls</span>
                            </div>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        )}

        {/* TAB 3: DEPARTMENTS & RATIOS */}
        {tab === "departments" && (
          <div className="card p-6 space-y-4">
            <h3 className="text-base font-bold text-[#0B1020] dark:text-white">Department Faculty-to-Student Ratios</h3>
            <p className="text-xs text-[#64708A]">Accreditation & UGC standard: Target faculty-to-student ratio is 1:15 or 1:20.</p>
            <div className="table-container">
              <table>
                <thead>
                  <tr>
                    <th>Department</th>
                    <th>Code</th>
                    <th>Head of Department (HOD)</th>
                    <th>Total Faculty</th>
                    <th>Active Students</th>
                    <th>Faculty-Student Ratio</th>
                    <th>Accreditation Status</th>
                  </tr>
                </thead>
                <tbody>
                  {departments.map((d: any) => {
                    const ratio = Number(d.student_faculty_ratio);
                    return (
                      <tr key={d.id}>
                        <td className="font-semibold text-[#0B1020] dark:text-white">{d.name}</td>
                        <td className="font-mono font-bold text-indigo-600">{d.code}</td>
                        <td className="text-xs text-teal-600 dark:text-teal-400 font-medium">{d.hod_name || "Assigned"}</td>
                        <td className="font-mono">{d.faculty_count} Professors</td>
                        <td className="font-mono">{d.active_students} Students</td>
                        <td className="font-mono font-bold text-indigo-600">1 : {ratio}</td>
                        <td>
                          <Badge
                            label={ratio <= 20 ? "OPTIMAL (1:15-20)" : "ATTENTION"}
                            variant={ratio <= 20 ? "success" : "warning"}
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

        {/* TAB 4: ADMINISTRATORS MANAGEMENT */}
        {tab === "admins" && (
          <div className="card p-6 space-y-4">
            <div className="flex justify-between items-center">
              <div>
                <h3 className="text-base font-bold text-[#0B1020] dark:text-white">Administrative Leadership Directory</h3>
                <p className="text-xs text-[#64708A]">Principal, Academic Deans, Administrative Officers, and Examination Controllers.</p>
              </div>
              <button
                onClick={() => setShowAddAdminModal(true)}
                className="px-3.5 py-2 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-semibold text-xs flex items-center gap-1.5 transition"
              >
                <Plus className="w-4 h-4" /> Provision Administrator
              </button>
            </div>

            <div className="table-container">
              <table>
                <thead>
                  <tr>
                    <th>Official Email</th>
                    <th>Designated Role</th>
                    <th>Account Status</th>
                    <th>Last Active</th>
                    <th>Created On</th>
                  </tr>
                </thead>
                <tbody>
                  {admins.map((a: any) => (
                    <tr key={a.id}>
                      <td className="font-mono font-semibold">{a.email}</td>
                      <td>
                        <Badge label={a.role} variant="purple" />
                      </td>
                      <td>
                        <Badge label={a.is_blocked ? "BLOCKED" : "ACTIVE"} variant={a.is_blocked ? "danger" : "success"} />
                      </td>
                      <td className="text-xs text-[#64708A]">{a.last_login_at ? new Date(a.last_login_at).toLocaleString() : "Never"}</td>
                      <td className="text-xs text-[#64708A]">{new Date(a.created_at).toLocaleDateString()}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* TAB 5: FINANCIAL GOVERNANCE */}
        {tab === "finance" && finance && (
          <div className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="card p-6">
                <p className="text-xs font-semibold text-[#64708A]">Total Tuition Receivable</p>
                <p className="text-3xl font-extrabold font-mono-numbers mt-2 text-indigo-600 dark:text-indigo-400">
                  INR {Number(finance.studentFees?.total_receivable || 0).toLocaleString()}
                </p>
                <p className="text-[11px] text-[#64708A] mt-1">Institutional academic fee billing</p>
              </div>
              <div className="card p-6">
                <p className="text-xs font-semibold text-[#64708A]">Total Tuition Collected</p>
                <p className="text-3xl font-extrabold font-mono-numbers mt-2 text-emerald-600 dark:text-emerald-400">
                  INR {Number(finance.studentFees?.total_collected || 0).toLocaleString()}
                </p>
                <p className="text-[11px] text-emerald-600 mt-1">Verified bank receipts</p>
              </div>
              <div className="card p-6">
                <p className="text-xs font-semibold text-[#64708A]">Outstanding Dues</p>
                <p className="text-3xl font-extrabold font-mono-numbers mt-2 text-rose-600 dark:text-rose-400">
                  INR {Number(finance.studentFees?.total_outstanding || 0).toLocaleString()}
                </p>
                <p className="text-[11px] text-rose-600 mt-1">Pending student clearance</p>
              </div>
            </div>

            <div className="card p-6">
              <h3 className="text-sm font-bold text-[#0B1020] dark:text-white mb-2">Faculty & Staff Payroll Obligations</h3>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mt-4">
                <div className="p-4 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D]">
                  <p className="text-xs text-[#64708A]">Monthly Salary Commitment</p>
                  <p className="text-2xl font-bold font-mono-numbers mt-1 text-teal-600 dark:text-teal-400">
                    INR {Number(finance.monthlyFacultyPayroll).toLocaleString()}
                  </p>
                </div>
                <div className="p-4 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D]">
                  <p className="text-xs text-[#64708A]">Annual Budget Allocation</p>
                  <p className="text-2xl font-bold font-mono-numbers mt-1 text-[#0B1020] dark:text-white">
                    INR {Number(finance.annualPayrollCommitment).toLocaleString()}
                  </p>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* TAB 6: SECURITY & AUDIT LOGS */}
        {tab === "audit" && (
          <div className="card p-6 space-y-4">
            <h3 className="text-base font-bold text-[#0B1020] dark:text-white">Enterprise Security & Audit Trail</h3>
            <p className="text-xs text-[#64708A]">Immutable audit trail recording administrative account creation, role assignments, and IP addresses.</p>
            <div className="table-container max-h-[500px]">
              <table>
                <thead>
                  <tr>
                    <th>Timestamp</th>
                    <th>Action</th>
                    <th>Entity</th>
                    <th>Actor</th>
                    <th>IP Address</th>
                    <th>Details</th>
                  </tr>
                </thead>
                <tbody>
                  {auditLogs.map((log: any) => (
                    <tr key={log.id}>
                      <td className="text-xs font-mono text-[#64708A]">{new Date(log.created_at).toLocaleString()}</td>
                      <td>
                        <Badge label={log.action} variant="purple" />
                      </td>
                      <td className="font-mono text-xs font-semibold">{log.entity_name}</td>
                      <td className="text-xs text-[#64708A]">{log.actor_email || "System"}</td>
                      <td className="font-mono text-xs">{log.ip_address}</td>
                      <td className="text-xs text-[#64708A]">{log.details}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </main>

      {/* Modal: Provision Administrator */}
      {showAddAdminModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
          <div className="bg-white dark:bg-[#11162A] p-6 rounded-2xl max-w-md w-full border border-[#E5E8F0] dark:border-[#1F293D] shadow-2xl space-y-4">
            <div className="flex justify-between items-center">
              <h3 className="text-base font-bold text-[#0B1020] dark:text-white">Provision Administrator Account</h3>
              <button onClick={() => setShowAddAdminModal(false)} className="text-slate-400 hover:text-slate-600">✕</button>
            </div>
            <form onSubmit={handleCreateAdmin} className="space-y-3">
              <div>
                <label className="text-xs font-semibold text-[#64708A]">Official Institutional Email</label>
                <input
                  type="email"
                  required
                  placeholder="e.g. principal@college.local"
                  value={newAdmin.email}
                  onChange={(e) => setNewAdmin({ ...newAdmin, email: e.target.value })}
                  className="w-full"
                />
              </div>
              <div>
                <label className="text-xs font-semibold text-[#64708A]">Temporary Password</label>
                <input
                  type="password"
                  required
                  placeholder="Min 8 characters with symbol"
                  value={newAdmin.password}
                  onChange={(e) => setNewAdmin({ ...newAdmin, password: e.target.value })}
                  className="w-full"
                />
              </div>
              <div>
                <label className="text-xs font-semibold text-[#64708A]">Executive Role</label>
                <select
                  value={newAdmin.role}
                  onChange={(e) => setNewAdmin({ ...newAdmin, role: e.target.value })}
                  className="w-full"
                >
                  <option value="PRINCIPAL">Principal / Director</option>
                  <option value="DEAN">Academic Dean</option>
                  <option value="ADMIN">Administrative Officer</option>
                  <option value="HOD">Head of Department (HOD)</option>
                  <option value="ACCOUNTS">Finance & Accounts Officer</option>
                  <option value="EXAM_CELL">Controller of Examinations</option>
                </select>
              </div>
              <button
                type="submit"
                className="w-full py-2.5 rounded-xl bg-indigo-600 text-white font-semibold text-xs mt-3 shadow-md"
              >
                Provision Account
              </button>
            </form>
          </div>
        </div>
      )}

      {/* Password Change Modal */}
      {showPwdModal && <PasswordChangeModal isOpen={showPwdModal} onClose={() => setShowPwdModal(false)} />}
    </div>
  );
}
