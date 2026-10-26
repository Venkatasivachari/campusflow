import React, { useState, useEffect } from "react";
import { GraduationCap, Moon, Sun, Search, X, CheckCircle, AlertTriangle, Info } from "lucide-react";

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
