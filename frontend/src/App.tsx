import React, { useState, useEffect } from "react";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { LoginPage } from "./LoginPages";
import { AdminPortal } from "./AdminPages";
import { FacultyPortal } from "./FacultyPages";
import { StudentPortal } from "./StudentPages";
import { BrandedSplashLoader } from "./ui";
import { getStoredAuth } from "./api";

function ProtectedRoute({ role, children }: { role: "ADMIN" | "FACULTY" | "STUDENT"; children: JSX.Element }) {
  const auth = getStoredAuth();
  if (!auth?.token) {
    return <Navigate to={`/${role.toLowerCase()}/login`} replace />;
  }
  if (role === "ADMIN" && !auth.role?.includes("ADMIN") && auth.role !== "ACCOUNTS" && auth.role !== "EXAM_CELL") {
    return <Navigate to="/admin/login" replace />;
  }
  if (role === "FACULTY" && auth.role !== "FACULTY" && !auth.role?.includes("ADMIN")) {
    return <Navigate to="/faculty/login" replace />;
  }
  if (role === "STUDENT" && auth.role !== "STUDENT") {
    return <Navigate to="/student/login" replace />;
  }
  return children;
}

export default function App() {
  const [showSplash, setShowSplash] = useState(true);

  useEffect(() => {
    const t = setTimeout(() => setShowSplash(false), 800);
    return () => clearTimeout(t);
  }, []);

  return (
    <>
      {showSplash && <BrandedSplashLoader />}
      <BrowserRouter>
        <Routes>
          {/* Three Separate Login Pages */}
          <Route path="/admin/login" element={<LoginPage role="ADMIN" />} />
          <Route path="/faculty/login" element={<LoginPage role="FACULTY" />} />
          <Route path="/student/login" element={<LoginPage role="STUDENT" />} />

          {/* Role Dedicated Portals */}
          <Route
            path="/admin/*"
            element={
              <ProtectedRoute role="ADMIN">
                <AdminPortal />
              </ProtectedRoute>
            }
          />
          <Route
            path="/faculty/*"
            element={
              <ProtectedRoute role="FACULTY">
                <FacultyPortal />
              </ProtectedRoute>
            }
          />
          <Route
            path="/student/*"
            element={
              <ProtectedRoute role="STUDENT">
                <StudentPortal />
              </ProtectedRoute>
            }
          />

          {/* Default Redirect */}
          <Route path="*" element={<Navigate to="/admin/login" replace />} />
        </Routes>
      </BrowserRouter>
    </>
  );
}
