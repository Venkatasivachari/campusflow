import React, { useState, useEffect } from "react";
import { GraduationCap, Moon, Sun, Search, X, CheckCircle, AlertTriangle, Info, Bell, Check, Key } from "lucide-react";
import { api } from "./api";

export function BrandedSplashLoader({ name = "Imperial Institute of Technology" }: { name?: string }) {
  return (
    <div className="fixed inset-0 z-50 flex flex-col items-center justify-center bg-[#F6F7FB] dark:bg-[#0B1020] transition-opacity duration-300">
      <div className="relative flex items-center justify-center w-20 h-20 mb-6">
        <div className="absolute inset-0 rounded-full border-2 border-indigo-200 dark:border-indigo-900 border-t-indigo-600 dark:border-t-indigo-400 animate-spin" />
        <div className="w-12 h-12 rounded-2xl bg-indigo-600 flex items-center justify-center shadow-lg shadow-indigo-500/30">
          <GraduationCap className="w-7 h-7 text-white" />
        </div>
      </div>
      <h2 className="text-xl font-bold tracking-tight text-[#0B1020] dark:text-white font-heading">{name}</h2>
      <p className="text-xs text-[#64708A] mt-1 font-mono tracking-widest uppercase">Smart College Portal</p>
    </div>
  );
}

export function ProgressBar() {
  return (
    <div className="fixed top-0 left-0 right-0 h-[3px] bg-transparent z-50 overflow-hidden">
      <div className="h-full bg-gradient-to-r from-indigo-500 via-teal-400 to-violet-500 animate-[progress_1s_ease-in-out_infinite]" />
    </div>
  );
}

export function ThemeToggle() {
  const [isDark, setIsDark] = useState(() => {
    return (
      document.documentElement.classList.contains("dark") ||
      localStorage.getItem("theme") === "dark" ||
      (!("theme" in localStorage) && window.matchMedia("(prefers-color-scheme: dark)").matches)
    );
  });

  useEffect(() => {
    if (isDark) {
      document.documentElement.classList.add("dark");
      localStorage.setItem("theme", "dark");
    } else {
      document.documentElement.classList.remove("dark");
      localStorage.setItem("theme", "light");
    }
  }, [isDark]);

  return (
    <button
      type="button"
      onClick={() => setIsDark(!isDark)}
      title={isDark ? "Switch to light mode" : "Switch to dark mode"}
      className="p-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] hover:bg-slate-100 dark:hover:bg-slate-800 text-[#64708A] dark:text-slate-300 transition"
    >
      {isDark ? <Sun className="w-4 h-4 text-amber-400" /> : <Moon className="w-4 h-4 text-indigo-600" />}
    </button>
  );
}

export function NotificationBell() {
  const [open, setOpen] = useState(false);
  const [notifs, setNotifs] = useState<any[]>([]);
  const [unread, setUnread] = useState(0);

  const fetchNotifs = async () => {
    try {
      const res = await api.notifications.getMyNotifications();
      setNotifs(res.notifications || []);
      setUnread(res.unreadCount || 0);
    } catch {
      // Ignore background failure
    }
  };

  useEffect(() => {
    fetchNotifs();
    const interval = setInterval(fetchNotifs, 30000);
    return () => clearInterval(interval);
  }, []);

  const handleMarkRead = async (id: number) => {
    try {
      await api.notifications.markRead(id);
      setNotifs((prev) => prev.map((n) => (n.id === id ? { ...n, is_read: true } : n)));
      setUnread((c) => Math.max(0, c - 1));
    } catch {}
  };

  const handleMarkAllRead = async () => {
    try {
      await api.notifications.markAllRead();
      setNotifs((prev) => prev.map((n) => ({ ...n, is_read: true })));
      setUnread(0);
    } catch {}
  };

  return (
    <div className="relative">
      <button
        type="button"
        onClick={() => setOpen(!open)}
        className="relative p-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] hover:bg-slate-100 dark:hover:bg-slate-800 text-[#64708A] dark:text-slate-300 transition"
        title="Notifications"
      >
        <Bell className="w-4 h-4" />
        {unread > 0 && (
          <span className="absolute -top-1 -right-1 w-4 h-4 rounded-full bg-rose-500 text-white text-[10px] font-bold flex items-center justify-center animate-pulse">
            {unread > 9 ? "9+" : unread}
          </span>
        )}
      </button>

      {open && (
        <>
          <div className="fixed inset-0 z-30" onClick={() => setOpen(false)} />
          <div className="absolute right-0 mt-2 w-80 md:w-96 bg-white dark:bg-[#11162A] rounded-2xl border border-[#E5E8F0] dark:border-[#1F293D] shadow-2xl z-40 overflow-hidden">
            <div className="px-4 py-3 border-b border-[#E5E8F0] dark:border-[#1F293D] flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Bell className="w-4 h-4 text-indigo-500" />
                <h4 className="text-xs font-bold text-[#0B1020] dark:text-white uppercase tracking-wider">Notifications</h4>
              </div>
              {unread > 0 && (
                <button
                  type="button"
                  onClick={handleMarkAllRead}
                  className="text-[11px] text-indigo-600 dark:text-indigo-400 hover:underline flex items-center gap-1 font-medium"
                >
                  <Check className="w-3 h-3" /> Mark all read
                </button>
              )}
            </div>
            <div className="max-h-80 overflow-y-auto divide-y divide-slate-100 dark:divide-slate-800">
              {notifs.length === 0 ? (
                <div className="p-6 text-center text-xs text-[#64708A]">No notifications yet.</div>
              ) : (
                notifs.map((n) => (
                  <div
                    key={n.id}
                    onClick={() => handleMarkRead(n.id)}
                    className={`p-3.5 text-xs transition cursor-pointer hover:bg-slate-50 dark:hover:bg-slate-800/50 ${
                      !n.is_read ? "bg-indigo-50/50 dark:bg-indigo-950/20" : ""
                    }`}
                  >
                    <div className="flex items-start justify-between gap-2">
                      <p className="font-semibold text-[#0B1020] dark:text-white">{n.title}</p>
                      {!n.is_read && <span className="w-1.5 h-1.5 rounded-full bg-indigo-600 mt-1 flex-shrink-0" />}
                    </div>
                    <p className="text-[#64708A] dark:text-slate-400 mt-1 line-clamp-2">{n.message}</p>
                    <span className="text-[10px] text-slate-400 mt-1.5 block font-mono">
                      {new Date(n.created_at).toLocaleString([], { dateStyle: "short", timeStyle: "short" })}
                    </span>
                  </div>
                ))
              )}
            </div>
          </div>
        </>
      )}
    </div>
  );
}

export function GlobalSearchModal({ isOpen, onClose }: { isOpen: boolean; onClose: () => void }) {
  const [query, setQuery] = useState("");
  const [results, setResults] = useState<{ students: any[]; faculty: any[]; courses: any[] }>({
    students: [],
    faculty: [],
    courses: [],
  });
  const [searching, setSearching] = useState(false);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.ctrlKey || e.metaKey) && e.key === "k") {
        e.preventDefault();
        if (isOpen) onClose();
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [isOpen, onClose]);

  useEffect(() => {
    if (!query.trim() || query.length < 2) {
      setResults({ students: [], faculty: [], courses: [] });
      return;
    }
    const timer = setTimeout(async () => {
      setSearching(true);
      try {
        const res = await api.admin.search(query);
        setResults(res);
      } catch {
        // ignore
      } finally {
        setSearching(false);
      }
    }, 250);
    return () => clearTimeout(timer);
  }, [query]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center pt-20 px-4 bg-black/50 backdrop-blur-sm">
      <div className="bg-white dark:bg-[#11162A] w-full max-w-xl rounded-2xl border border-[#E5E8F0] dark:border-[#1F293D] shadow-2xl overflow-hidden">
        <div className="p-4 border-b border-[#E5E8F0] dark:border-[#1F293D] flex items-center gap-3">
          <Search className="w-5 h-5 text-indigo-500" />
          <input
            type="text"
            autoFocus
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Search students, faculty, courses... (Ctrl+K)"
            className="flex-1 bg-transparent border-none text-sm text-[#0B1020] dark:text-white placeholder-[#64708A] focus:outline-none"
          />
          <button type="button" onClick={onClose} className="p-1 text-slate-400 hover:text-slate-600 dark:hover:text-white">
            <X className="w-4 h-4" />
          </button>
        </div>
        <div className="max-h-96 overflow-y-auto p-4 space-y-4">
          {searching && <p className="text-xs text-[#64708A] py-2 text-center">Searching...</p>}
          {!searching && query.length >= 2 && results.students.length === 0 && results.faculty.length === 0 && results.courses.length === 0 && (
            <p className="text-xs text-[#64708A] py-4 text-center">No matching records found.</p>
          )}

          {results.students.length > 0 && (
            <div>
              <p className="text-[11px] font-bold text-[#64708A] uppercase tracking-wider mb-2">Students</p>
              <div className="space-y-1.5">
                {results.students.map((s) => (
                  <div key={s.id} className="p-2.5 rounded-xl hover:bg-slate-100 dark:hover:bg-slate-800 text-xs flex justify-between items-center">
                    <div>
                      <p className="font-semibold text-[#0B1020] dark:text-white">{s.full_name}</p>
                      <p className="text-[#64708A]">{s.college_email}</p>
                    </div>
                    <span className="font-mono text-indigo-600 dark:text-indigo-400 bg-indigo-50 dark:bg-indigo-950 px-2 py-0.5 rounded">
                      {s.registration_number}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {results.faculty.length > 0 && (
            <div>
              <p className="text-[11px] font-bold text-[#64708A] uppercase tracking-wider mb-2">Faculty</p>
              <div className="space-y-1.5">
                {results.faculty.map((f) => (
                  <div key={f.id} className="p-2.5 rounded-xl hover:bg-slate-100 dark:hover:bg-slate-800 text-xs flex justify-between items-center">
                    <div>
                      <p className="font-semibold text-[#0B1020] dark:text-white">{f.full_name}</p>
                      <p className="text-[#64708A]">{f.email}</p>
                    </div>
                    <span className="font-mono text-teal-600 dark:text-teal-400 bg-teal-50 dark:bg-teal-950 px-2 py-0.5 rounded">
                      {f.employee_id}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {results.courses.length > 0 && (
            <div>
              <p className="text-[11px] font-bold text-[#64708A] uppercase tracking-wider mb-2">Courses</p>
              <div className="space-y-1.5">
                {results.courses.map((c) => (
                  <div key={c.id} className="p-2.5 rounded-xl hover:bg-slate-100 dark:hover:bg-slate-800 text-xs flex justify-between items-center">
                    <p className="font-semibold text-[#0B1020] dark:text-white">{c.name}</p>
                    <span className="font-mono text-violet-600 dark:text-violet-400 bg-violet-50 dark:bg-violet-950 px-2 py-0.5 rounded">
                      {c.code} ({c.credits} cr)
                    </span>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export function PasswordChangeModal({ isOpen, onClose, onDone }: { isOpen: boolean; onClose: () => void; onDone?: () => void }) {
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [err, setErr] = useState("");
  const [submitting, setSubmitting] = useState(false);

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErr("");
    if (newPassword !== confirmPassword) {
      setErr("New passwords do not match.");
      return;
    }
    setSubmitting(true);
    try {
      await api.changePassword({ currentPassword, newPassword });
      if (onDone) onDone();
      onClose();
    } catch (e: any) {
      setErr(e.message || "Failed to change password.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
      <div className="bg-white dark:bg-[#11162A] w-full max-w-md rounded-2xl border border-[#E5E8F0] dark:border-[#1F293D] shadow-2xl p-6 space-y-4">
        <div className="flex items-center justify-between border-b border-[#E5E8F0] dark:border-[#1F293D] pb-3">
          <div className="flex items-center gap-2">
            <Key className="w-5 h-5 text-indigo-500" />
            <h3 className="font-bold text-sm text-[#0B1020] dark:text-white">Change Password</h3>
          </div>
          <button type="button" onClick={onClose} className="p-1 text-slate-400 hover:text-slate-600 dark:hover:text-white">
            <X className="w-4 h-4" />
          </button>
        </div>

        {err && <div className="p-3 text-xs bg-rose-50 dark:bg-rose-950/40 text-rose-600 rounded-xl">{err}</div>}

        <form onSubmit={handleSubmit} className="space-y-3 text-xs">
          <div>
            <label className="block text-[#64708A] mb-1">Current Password</label>
            <input
              type="password"
              required
              value={currentPassword}
              onChange={(e) => setCurrentPassword(e.target.value)}
              className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent text-[#0B1020] dark:text-white"
            />
          </div>
          <div>
            <label className="block text-[#64708A] mb-1">New Password (8+ chars, upper, lower, number, symbol)</label>
            <input
              type="password"
              required
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent text-[#0B1020] dark:text-white"
            />
          </div>
          <div>
            <label className="block text-[#64708A] mb-1">Confirm New Password</label>
            <input
              type="password"
              required
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              className="w-full px-3 py-2 rounded-xl border border-[#E5E8F0] dark:border-[#1F293D] bg-transparent text-[#0B1020] dark:text-white"
            />
          </div>
          <div className="pt-2 flex justify-end gap-2">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 rounded-xl border border-slate-200 dark:border-slate-800 text-slate-600 dark:text-slate-300"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={submitting}
              className="px-4 py-2 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-medium disabled:opacity-50"
            >
              {submitting ? "Updating..." : "Update Password"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export function StatCard({ title, value, subtitle, icon: Icon, color = "indigo" }: {
  title: string;
  value: string | number;
  subtitle?: string;
  icon?: any;
  color?: "indigo" | "teal" | "violet" | "amber" | "emerald" | "rose";
}) {
  const colorMap = {
    indigo: "text-indigo-600 bg-indigo-50 dark:bg-indigo-950/40 dark:text-indigo-400",
    teal: "text-teal-600 bg-teal-50 dark:bg-teal-950/40 dark:text-teal-400",
    violet: "text-violet-600 bg-violet-50 dark:bg-violet-950/40 dark:text-violet-400",
    amber: "text-amber-600 bg-amber-50 dark:bg-amber-950/40 dark:text-amber-400",
    emerald: "text-emerald-600 bg-emerald-50 dark:bg-emerald-950/40 dark:text-emerald-400",
    rose: "text-rose-600 bg-rose-50 dark:bg-rose-950/40 dark:text-rose-400",
  };

  return (
    <div className="card p-5 flex flex-col justify-between">
      <div className="flex items-start justify-between">
        <div>
          <p className="text-xs font-medium text-[#64708A] uppercase tracking-wider">{title}</p>
          <h3 className="text-2xl font-bold font-mono-numbers mt-1 text-[#0B1020] dark:text-white">{value}</h3>
        </div>
        {Icon && (
          <div className={`p-2.5 rounded-xl ${colorMap[color]}`}>
            <Icon className="w-5 h-5" />
          </div>
        )}
      </div>
      {subtitle && <p className="text-xs text-[#64708A] mt-3">{subtitle}</p>}
    </div>
  );
}

export function SkeletonCard() {
  return (
    <div className="card p-5 space-y-3">
      <div className="skeleton h-3 w-24" />
      <div className="skeleton h-8 w-32" />
      <div className="skeleton h-3 w-40" />
    </div>
  );
}

export function SkeletonTable({ rows = 5, cols = 4 }: { rows?: number; cols?: number }) {
  return (
    <div className="card p-4 space-y-3">
      <div className="skeleton h-5 w-48 mb-4" />
      <div className="space-y-2">
        {Array.from({ length: rows }).map((_, r) => (
          <div key={r} className="flex gap-4">
            {Array.from({ length: cols }).map((_, c) => (
              <div key={c} className="skeleton h-6 flex-1" />
            ))}
          </div>
        ))}
      </div>
    </div>
  );
}

export function Badge({ label, variant = "default" }: {
  label: string;
  variant?: "default" | "success" | "warning" | "danger" | "info" | "purple";
}) {
  const styles = {
    default: "bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-300",
    success: "bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/50 dark:text-emerald-300 dark:border-emerald-900",
    warning: "bg-amber-50 text-amber-700 border border-amber-200 dark:bg-amber-950/50 dark:text-amber-300 dark:border-amber-900",
    danger: "bg-rose-50 text-rose-700 border border-rose-200 dark:bg-rose-950/50 dark:text-rose-300 dark:border-rose-900",
    info: "bg-blue-50 text-blue-700 border border-blue-200 dark:bg-blue-950/50 dark:text-blue-300 dark:border-blue-900",
    purple: "bg-purple-50 text-purple-700 border border-purple-200 dark:bg-purple-950/50 dark:text-purple-300 dark:border-purple-900",
  };

  return (
    <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-xs font-semibold tracking-wide ${styles[variant]}`}>
      {label}
    </span>
  );
}

export function Toast({ message, type = "info", onClose }: {
  message: string;
  type?: "success" | "error" | "info";
  onClose: () => void;
}) {
  return (
    <div className="fixed bottom-5 right-5 z-50 flex items-center gap-3 px-4 py-3 rounded-xl bg-white dark:bg-[#11162A] border border-[#E5E8F0] dark:border-[#1F293D] shadow-xl text-sm">
      {type === "success" && <CheckCircle className="w-4 h-4 text-emerald-500" />}
      {type === "error" && <AlertTriangle className="w-4 h-4 text-rose-500" />}
      {type === "info" && <Info className="w-4 h-4 text-indigo-500" />}
      <span className="text-[#0B1020] dark:text-white font-medium">{message}</span>
      <button onClick={onClose} className="p-1 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg text-slate-400">
        <X className="w-3.5 h-3.5" />
      </button>
    </div>
  );
}

export class ErrorBoundary extends React.Component<
  { children: React.ReactNode },
  { hasError: boolean; error: Error | null }
> {
  constructor(props: { children: React.ReactNode }) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: any) {
    console.error("ErrorBoundary caught:", error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen flex items-center justify-center bg-[#F6F7FB] dark:bg-[#0B1020] p-6">
          <div className="bg-white dark:bg-[#11162A] p-8 rounded-2xl border border-rose-200 dark:border-rose-900 shadow-xl max-w-md w-full text-center space-y-4">
            <div className="w-12 h-12 rounded-2xl bg-rose-50 dark:bg-rose-950/40 text-rose-600 flex items-center justify-center mx-auto">
              <AlertTriangle className="w-6 h-6" />
            </div>
            <h2 className="text-lg font-bold text-[#0B1020] dark:text-white">Something went wrong</h2>
            <p className="text-xs text-[#64708A]">
              An unexpected error occurred while rendering the page.
            </p>
            {this.state.error?.message && (
              <p className="p-3 rounded-lg bg-slate-50 dark:bg-slate-800/50 text-[11px] font-mono text-rose-500 overflow-x-auto text-left">
                {this.state.error.message}
              </p>
            )}
            <div className="flex gap-2 justify-center pt-2">
              <button
                onClick={() => {
                  this.setState({ hasError: false, error: null });
                  window.location.reload();
                }}
                className="px-4 py-2 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-semibold text-xs shadow-md transition"
              >
                Reload Page
              </button>
              <button
                onClick={() => {
                  localStorage.removeItem("auth");
                  window.location.href = "/admin/login";
                }}
                className="px-4 py-2 rounded-xl border border-slate-200 dark:border-slate-800 text-slate-600 dark:text-slate-300 font-semibold text-xs transition"
              >
                Return to Login
              </button>
            </div>
          </div>
        </div>
      );
    }
    return this.props.children;
  }
}
