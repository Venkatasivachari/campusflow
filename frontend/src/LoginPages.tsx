import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { GraduationCap, Eye, EyeOff, ShieldCheck, BookOpen, Users, Lock, ArrowRight, CheckCircle, AlertCircle } from "lucide-react";
import { api, saveAuth } from "./api";

interface LoginProps {
  role: "ADMIN" | "FACULTY" | "STUDENT";
}

export function LoginPage({ role }: LoginProps) {
  const navigate = useNavigate();
  const [identifier, setIdentifier] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Forced password change modal state
  const [firstTimeModal, setFirstTimeModal] = useState(false);
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [pwdError, setPwdError] = useState<string | null>(null);

  // Forgot password modal state
  const [forgotModal, setForgotModal] = useState(false);
  const [forgotStep, setForgotStep] = useState<1 | 2>(1);
  const [forgotId, setForgotId] = useState("");
  const [otp, setOtp] = useState("");
  const [forgotNewPassword, setForgotNewPassword] = useState("");
  const [forgotMsg, setForgotMsg] = useState<string | null>(null);

  const configs = {
    ADMIN: {
      headline: "Institutional Management Portal",
      subhead: "Administrative control center for academic records, payroll, students, and regulatory compliance.",
      accent: "#4F46E5",
      accentBg: "bg-indigo-600 hover:bg-indigo-700",
      accentText: "text-indigo-600 dark:text-indigo-400",
      gradient: "from-[#0B1020] via-[#1E1B4B] to-[#312E81]",
      icon: ShieldCheck,
      portalName: "Administration",
      idPlaceholder: "admin@college.local or User ID",
      apiCall: api.loginAdmin,
      redirect: "/admin",
    },
    FACULTY: {
      headline: "Faculty & Academic Workspace",
      subhead: "Manage today's schedule, mark class attendance with one tap, grade assignments, and inspect curriculum.",
      accent: "#0F766E",
      accentBg: "bg-teal-600 hover:bg-teal-700",
      accentText: "text-teal-600 dark:text-teal-400",
      gradient: "from-[#042F2E] via-[#115E59] to-[#0F766E]",
      icon: BookOpen,
      portalName: "Faculty Portal",
      idPlaceholder: "FAC25001 or registered email",
      apiCall: api.loginFaculty,
      redirect: "/faculty",
    },
    STUDENT: {
      headline: "Student Campus Experience",
      subhead: "Track real-time attendance, SGPA progress, examination arrears, assignments, and fee statements.",
      accent: "#7C3AED",
      accentBg: "bg-violet-600 hover:bg-violet-700",
      accentText: "text-violet-600 dark:text-violet-400",
      gradient: "from-[#2E1065] via-[#581C87] to-[#7C3AED]",
      icon: Users,
      portalName: "Student Portal",
      idPlaceholder: "25CSE0001 or college email",
      apiCall: api.loginStudent,
      redirect: "/student",
    },
  };

  const config = configs[role];
  const Icon = config.icon;

  async function handleLogin(e: React.FormEvent) {
    e.preventDefault();
    if (!identifier.trim() || !password) {
      setError("Please enter your identifier and password.");
      return;
    }
    setError(null);
    setLoading(true);

    try {
      const res = await config.apiCall({ identifier: identifier.trim(), password });
      saveAuth({
        token: res.token,
        refreshToken: res.refreshToken,
        id: res.id,
        email: res.email,
        role: res.role,
        name: res.name,
        code: res.code,
        mustChangePassword: res.mustChangePassword,
      });

      if (res.mustChangePassword) {
        setFirstTimeModal(true);
      } else {
        navigate(config.redirect);
      }
    } catch (err: any) {
      setError(err.message || "Login failed. Please verify credentials.");
    } finally {
      setLoading(false);
    }
  }

  async function handleFirstTimePassword(e: React.FormEvent) {
    e.preventDefault();
    if (newPassword !== confirmPassword) {
      setPwdError("Passwords do not match.");
      return;
    }
    setPwdError(null);
    try {
      const res = await api.setInitialPassword(newPassword);
      // Update token with non-must-change-password token
      const current = JSON.parse(localStorage.getItem("auth") || "{}");
      saveAuth({ ...current, token: res.token, mustChangePassword: false });
      setFirstTimeModal(false);
      navigate(config.redirect);
    } catch (err: any) {
      setPwdError(err.message || "Failed to update password.");
    }
  }

  async function handleForgotRequest(e: React.FormEvent) {
    e.preventDefault();
    try {
      const res = await api.forgotRequest(forgotId);
      setForgotMsg(res.message);
      setForgotStep(2);
    } catch (err: any) {
      setForgotMsg(err.message);
    }
  }

  async function handleForgotReset(e: React.FormEvent) {
    e.preventDefault();
    try {
      const res = await api.forgotReset({ identifier: forgotId, otp, newPassword: forgotNewPassword });
      setForgotMsg(res.message);
      setTimeout(() => {
        setForgotModal(false);
        setForgotStep(1);
      }, 2000);
    } catch (err: any) {
      setForgotMsg(err.message);
    }
  }

  return (
    <div className="min-h-screen flex flex-col md:flex-row bg-[#F6F7FB] dark:bg-[#0B1020]">
      {/* Brand Left Panel */}
      <div className={`w-full md:w-1/2 p-8 md:p-16 flex flex-col justify-between text-white bg-gradient-to-br ${config.gradient} relative overflow-hidden`}>
        <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-white/10 via-transparent to-transparent pointer-events-none" />
        
        <div className="relative z-10 flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-white/10 backdrop-blur border border-white/20 flex items-center justify-center">
            <GraduationCap className="w-6 h-6 text-white" />
          </div>
          <div>
            <span className="font-bold tracking-tight text-lg">Imperial Institute</span>
            <span className="block text-[11px] text-white/70 uppercase tracking-widest font-mono">Autonomous 2026</span>
          </div>
        </div>

        <div className="relative z-10 my-12 max-w-lg">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-white/10 backdrop-blur border border-white/20 text-xs font-semibold mb-4 text-white/90">
            <Icon className="w-3.5 h-3.5" /> {config.portalName}
          </div>
          <h1 className="text-3xl md:text-4xl font-extrabold tracking-tight leading-tight mb-4">
            {config.headline}
          </h1>
          <p className="text-white/80 text-sm md:text-base leading-relaxed">
            {config.subhead}
          </p>
        </div>

        <div className="relative z-10 flex items-center justify-between text-xs text-white/60 border-t border-white/10 pt-4 font-mono">
          <span>SECURE AUTH 256-BIT</span>
          <div className="flex gap-4">
            <button onClick={() => navigate("/admin/login")} className="hover:text-white transition">Admin</button>
            <button onClick={() => navigate("/faculty/login")} className="hover:text-white transition">Faculty</button>
            <button onClick={() => navigate("/student/login")} className="hover:text-white transition">Student</button>
          </div>
        </div>
      </div>

      {/* Right Login Form Panel */}
      <div className="w-full md:w-1/2 flex items-center justify-center p-6 md:p-12">
        <div className="w-full max-w-md bg-white dark:bg-[#11162A] p-8 rounded-2xl border border-[#E5E8F0] dark:border-[#1F293D] shadow-xl">
          <div className="mb-6">
            <h2 className="text-2xl font-bold text-[#0B1020] dark:text-white">Sign In</h2>
            <p className="text-xs text-[#64708A] mt-1">Please enter your authorized institutional credentials.</p>
          </div>

          {error && (
            <div className="mb-4 p-3 rounded-xl bg-rose-50 dark:bg-rose-950/40 border border-rose-200 dark:border-rose-900 flex items-start gap-2.5 text-xs text-rose-700 dark:text-rose-300">
              <AlertCircle className="w-4 h-4 mt-0.5 shrink-0" />
              <span>{error}</span>
            </div>
          )}

          <form onSubmit={handleLogin} className="space-y-4">
            <div>
              <label className="block text-xs font-semibold text-[#0B1020] dark:text-slate-200 uppercase tracking-wider mb-1.5">
                Identifier or Email
              </label>
              <input
                type="text"
                value={identifier}
                onChange={(e) => setIdentifier(e.target.value)}
                placeholder={config.idPlaceholder}
                required
                className="w-full"
              />
            </div>

            <div>
              <div className="flex items-center justify-between mb-1.5">
                <label className="text-xs font-semibold text-[#0B1020] dark:text-slate-200 uppercase tracking-wider">
                  Password
                </label>
                <button
                  type="button"
                  onClick={() => { setForgotId(identifier); setForgotModal(true); }}
                  className="text-xs font-medium text-[#64708A] hover:underline"
                >
                  Forgot password?
                </button>
              </div>
              <div className="relative">
                <input
                  type={showPassword ? "text" : "password"}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Enter account password"
                  required
                  className="w-full pr-10"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-2.5 text-[#64708A] hover:text-[#0B1020] dark:hover:text-white"
                >
                  {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className={`w-full py-3 rounded-xl text-white font-semibold text-sm shadow-md transition flex items-center justify-center gap-2 ${config.accentBg}`}
            >
              {loading ? "Authenticating..." : <>Sign In to {config.portalName} <ArrowRight className="w-4 h-4" /></>}
            </button>
          </form>

          <div className="mt-6 pt-5 border-t border-[#E5E8F0] dark:border-[#1F293D] text-center text-xs text-[#64708A]">
            <span>Need another experience? </span>
            <div className="flex justify-center gap-3 mt-2">
              <button onClick={() => navigate("/admin/login")} className="hover:underline font-medium text-indigo-600">Admin</button>
              <span>•</span>
              <button onClick={() => navigate("/faculty/login")} className="hover:underline font-medium text-teal-600">Faculty</button>
              <span>•</span>
              <button onClick={() => navigate("/student/login")} className="hover:underline font-medium text-violet-600">Student</button>
            </div>
          </div>
        </div>
      </div>

      {/* Forced Password Change Modal */}
      {firstTimeModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
          <div className="bg-white dark:bg-[#11162A] p-6 rounded-2xl max-w-md w-full border border-[#E5E8F0] dark:border-[#1F293D] shadow-2xl">
            <h3 className="text-lg font-bold text-[#0B1020] dark:text-white mb-2">Set Your New Password</h3>
            <p className="text-xs text-[#64708A] mb-4">
              This is your first login. For security compliance, you must choose a personal password (min 8 characters, upper, lower, digit, symbol).
            </p>

            {pwdError && <p className="text-xs text-rose-600 mb-3">{pwdError}</p>}

            <form onSubmit={handleFirstTimePassword} className="space-y-3">
              <div>
                <label className="text-xs font-semibold text-[#64708A]">New Password</label>
                <input
                  type="password"
                  value={newPassword}
                  onChange={(e) => setNewPassword(e.target.value)}
                  required
                  placeholder="Min 8 characters with symbol"
                />
              </div>
              <div>
                <label className="text-xs font-semibold text-[#64708A]">Confirm New Password</label>
                <input
                  type="password"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  required
                  placeholder="Re-enter password"
                />
              </div>
              <button
                type="submit"
                className={`w-full py-2.5 rounded-xl text-white font-semibold text-sm mt-3 ${config.accentBg}`}
              >
                Update Password & Continue
              </button>
            </form>
          </div>
        </div>
      )}

      {/* Forgot Password Modal */}
      {forgotModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
          <div className="bg-white dark:bg-[#11162A] p-6 rounded-2xl max-w-md w-full border border-[#E5E8F0] dark:border-[#1F293D] shadow-2xl">
            <div className="flex justify-between items-center mb-3">
              <h3 className="text-lg font-bold text-[#0B1020] dark:text-white">Account Recovery</h3>
              <button onClick={() => setForgotModal(false)} className="text-slate-400 hover:text-slate-600">✕</button>
            </div>

            {forgotMsg && <p className="text-xs text-indigo-600 dark:text-indigo-400 mb-3 bg-indigo-50 dark:bg-indigo-950/40 p-2 rounded-lg">{forgotMsg}</p>}

            {forgotStep === 1 ? (
              <form onSubmit={handleForgotRequest} className="space-y-3">
                <p className="text-xs text-[#64708A]">Enter your Registration Number, Employee ID, or email address. We will email a 6-digit OTP.</p>
                <input
                  type="text"
                  value={forgotId}
                  onChange={(e) => setForgotId(e.target.value)}
                  placeholder="e.g. 25CSE0001 or email"
                  required
                />
                <button type="submit" className={`w-full py-2.5 rounded-xl text-white font-semibold text-sm ${config.accentBg}`}>
                  Send OTP Code
                </button>
              </form>
            ) : (
              <form onSubmit={handleForgotReset} className="space-y-3">
                <p className="text-xs text-[#64708A]">Check your registered email for the 6-digit code.</p>
                <div>
                  <label className="text-xs font-semibold text-[#64708A]">6-Digit OTP</label>
                  <input
                    type="text"
                    value={otp}
                    onChange={(e) => setOtp(e.target.value)}
                    placeholder="123456"
                    required
                    className="font-mono text-center tracking-widest text-lg"
                  />
                </div>
                <div>
                  <label className="text-xs font-semibold text-[#64708A]">New Password</label>
                  <input
                    type="password"
                    value={forgotNewPassword}
                    onChange={(e) => setForgotNewPassword(e.target.value)}
                    placeholder="Choose new strong password"
                    required
                  />
                </div>
                <button type="submit" className={`w-full py-2.5 rounded-xl text-white font-semibold text-sm ${config.accentBg}`}>
                  Reset Password
                </button>
              </form>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
