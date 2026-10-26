package edu.portal;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

/** Grade scale and credit-weighted SGPA / CGPA math. */
public final class Gpa {
    private Gpa() {}

    /** marks -> {grade, grade point}. Scale: 90+ O(10), 80+ A+(9), 70+ A(8), 60+ B+(7), 50+ B(6), 40+ C(5), else F(0). */
    public static Object[] grade(double marks) {
        if (marks >= 90) return new Object[] {"O", 10.0};
        if (marks >= 80) return new Object[] {"A+", 9.0};
        if (marks >= 70) return new Object[] {"A", 8.0};
        if (marks >= 60) return new Object[] {"B+", 7.0};
        if (marks >= 50) return new Object[] {"B", 6.0};
        if (marks >= 40) return new Object[] {"C", 5.0};
        return new Object[] {"F", 0.0};
    }

    public static double round2(double v) {
        return BigDecimal.valueOf(v).setScale(2, RoundingMode.HALF_UP).doubleValue();
    }

    /**
     * rows need: course_id, semester, credits, grade_point.
     * SGPA = sum(gp*credits)/sum(credits) per semester.
     * CGPA counts each course once, using the best attempt (so repeated courses are not double counted).
     */
    public static Map<String, Object> summarize(List<Map<String, Object>> rows) {
        Map<Integer, double[]> sem = new TreeMap<>();   // semester -> {points, credits}
        Map<Object, double[]> best = new HashMap<>();   // course -> {gp, credits}
        for (Map<String, Object> r : rows) {
            double gp = ((Number) r.get("grade_point")).doubleValue();
            double cr = ((Number) r.get("credits")).doubleValue();
            int s = ((Number) r.get("semester")).intValue();
            double[] a = sem.computeIfAbsent(s, k -> new double[2]);
            a[0] += gp * cr;
            a[1] += cr;
            best.merge(r.get("course_id"), new double[] {gp, cr}, (o, n) -> n[0] > o[0] ? n : o);
        }
        Map<String, Object> out = new LinkedHashMap<>();
        Map<String, Double> sgpa = new LinkedHashMap<>();
        sem.forEach((k, v) -> sgpa.put(String.valueOf(k), v[1] == 0 ? 0 : round2(v[0] / v[1])));
        double pts = 0, cred = 0;
        for (double[] v : best.values()) { pts += v[0] * v[1]; cred += v[1]; }
        out.put("sgpa", sgpa);
        out.put("cgpa", cred == 0 ? 0 : round2(pts / cred));
        return out;
    }
}
