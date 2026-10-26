package edu.portal;

import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.util.List;
import java.util.Map;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

@Service
public class ExportService {

    public byte[] generateFeeReceiptPdf(Map<String, Object> payment, Map<String, Object> student) {
        try (ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Document doc = new Document(PageSize.A4, 36, 36, 36, 36);
            PdfWriter.getInstance(doc, out);
            doc.open();

            Font headerFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18, new Color(79, 70, 229));
            Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 13, Color.DARK_GRAY);
            Font bodyFont = FontFactory.getFont(FontFactory.HELVETICA, 10, Color.BLACK);
            Font boldFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, Color.BLACK);

            Paragraph pHeader = new Paragraph("Imperial Institute of Technology", headerFont);
            pHeader.setAlignment(Element.ALIGN_CENTER);
            doc.add(pHeader);

            Paragraph pSub = new Paragraph("OFFICIAL FEE PAYMENT RECEIPT\n\n", titleFont);
            pSub.setAlignment(Element.ALIGN_CENTER);
            doc.add(pSub);

            PdfPTable table = new PdfPTable(2);
            table.setWidthPercentage(100);
            table.setSpacingBefore(10f);
            table.setSpacingAfter(10f);

            addCell(table, "Receipt Number:", boldFont);
            addCell(table, String.valueOf(payment.getOrDefault("receipt_number", "N/A")), bodyFont);
            addCell(table, "Transaction Reference:", boldFont);
            addCell(table, String.valueOf(payment.getOrDefault("transaction_reference", "N/A")), bodyFont);
            addCell(table, "Payment Date:", boldFont);
            addCell(table, String.valueOf(payment.getOrDefault("payment_date", "N/A")), bodyFont);
            addCell(table, "Payment Mode:", boldFont);
            addCell(table, String.valueOf(payment.getOrDefault("payment_mode", "UPI")), bodyFont);
            addCell(table, "Student Name:", boldFont);
            addCell(table, String.valueOf(student.getOrDefault("full_name", "N/A")), bodyFont);
            addCell(table, "Registration Number:", boldFont);
            addCell(table, String.valueOf(student.getOrDefault("registration_number", "N/A")), bodyFont);
            addCell(table, "Amount Paid:", boldFont);
            addCell(table, "INR " + String.valueOf(payment.getOrDefault("amount_paid", "0.00")), headerFont);

            doc.add(table);

            Paragraph footer = new Paragraph("\nThis is a computer-generated receipt and requires no physical signature.", FontFactory.getFont(FontFactory.HELVETICA_OBLIQUE, 9, Color.GRAY));
            footer.setAlignment(Element.ALIGN_CENTER);
            doc.add(footer);

            doc.close();
            return out.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("Error generating Fee Receipt PDF", e);
        }
    }

    public byte[] generatePayslipPdf(Map<String, Object> payslip, Map<String, Object> faculty) {
        try (ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Document doc = new Document(PageSize.A4, 36, 36, 36, 36);
            PdfWriter.getInstance(doc, out);
            doc.open();

            Font headerFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18, new Color(15, 118, 110));
            Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, Color.DARK_GRAY);
            Font bodyFont = FontFactory.getFont(FontFactory.HELVETICA, 10, Color.BLACK);
            Font boldFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, Color.BLACK);

            Paragraph pHeader = new Paragraph("Imperial Institute of Technology", headerFont);
            pHeader.setAlignment(Element.ALIGN_CENTER);
            doc.add(pHeader);

            Paragraph pSub = new Paragraph("FACULTY SALARY PAYSLIP\n\n", titleFont);
            pSub.setAlignment(Element.ALIGN_CENTER);
            doc.add(pSub);

            PdfPTable table = new PdfPTable(2);
            table.setWidthPercentage(100);

            addCell(table, "Employee Name:", boldFont);
            addCell(table, String.valueOf(faculty.getOrDefault("full_name", "N/A")), bodyFont);
            addCell(table, "Employee ID:", boldFont);
            addCell(table, String.valueOf(faculty.getOrDefault("employee_id", "N/A")), bodyFont);
            addCell(table, "Designation:", boldFont);
            addCell(table, String.valueOf(faculty.getOrDefault("designation", "Faculty")), bodyFont);
            addCell(table, "Department:", boldFont);
            addCell(table, String.valueOf(faculty.getOrDefault("department_name", "Academic")), bodyFont);
            addCell(table, "Basic Pay:", boldFont);
            addCell(table, "INR " + payslip.getOrDefault("basic", "0.00"), bodyFont);
            addCell(table, "HRA:", boldFont);
            addCell(table, "INR " + payslip.getOrDefault("hra", "0.00"), bodyFont);
            addCell(table, "DA:", boldFont);
            addCell(table, "INR " + payslip.getOrDefault("da", "0.00"), bodyFont);
            addCell(table, "Allowances:", boldFont);
            addCell(table, "INR " + payslip.getOrDefault("allowances", "0.00"), bodyFont);
            addCell(table, "Deductions:", boldFont);
            addCell(table, "INR " + payslip.getOrDefault("deductions", "0.00"), bodyFont);
            addCell(table, "Net Salary Disbursed:", boldFont);
            addCell(table, "INR " + payslip.getOrDefault("net_amount", "0.00"), headerFont);

            doc.add(table);

            Paragraph footer = new Paragraph("\nConfidential - For employee use only.", FontFactory.getFont(FontFactory.HELVETICA_OBLIQUE, 9, Color.GRAY));
            footer.setAlignment(Element.ALIGN_CENTER);
            doc.add(footer);

            doc.close();
            return out.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("Error generating Payslip PDF", e);
        }
    }

    public byte[] generateResultSheetPdf(Map<String, Object> student, List<Map<String, Object>> marks) {
        try (ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Document doc = new Document(PageSize.A4, 36, 36, 36, 36);
            PdfWriter.getInstance(doc, out);
            doc.open();

            Font headerFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18, new Color(124, 58, 237));
            Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, Color.DARK_GRAY);
            Font bodyFont = FontFactory.getFont(FontFactory.HELVETICA, 10, Color.BLACK);
            Font boldFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, Color.BLACK);

            Paragraph pHeader = new Paragraph("Imperial Institute of Technology", headerFont);
            pHeader.setAlignment(Element.ALIGN_CENTER);
            doc.add(pHeader);

            Paragraph pSub = new Paragraph("SEMESTER GRADE SHEET\n\n", titleFont);
            pSub.setAlignment(Element.ALIGN_CENTER);
            doc.add(pSub);

            PdfPTable meta = new PdfPTable(2);
            meta.setWidthPercentage(100);
            addCell(meta, "Student Name:", boldFont);
            addCell(meta, String.valueOf(student.getOrDefault("full_name", "N/A")), bodyFont);
            addCell(meta, "Registration Number:", boldFont);
            addCell(meta, String.valueOf(student.getOrDefault("registration_number", "N/A")), bodyFont);
            addCell(meta, "Programme:", boldFont);
            addCell(meta, String.valueOf(student.getOrDefault("programme_name", "B.Tech")), bodyFont);
            addCell(meta, "Current CGPA:", boldFont);
            addCell(meta, String.valueOf(student.getOrDefault("current_cgpa", "0.00")), headerFont);
            doc.add(meta);

            PdfPTable table = new PdfPTable(5);
            table.setWidthPercentage(100);
            table.setSpacingBefore(15f);

            addCell(table, "Course Code", boldFont);
            addCell(table, "Course Name", boldFont);
            addCell(table, "Credits", boldFont);
            addCell(table, "Grade", boldFont);
            addCell(table, "Status", boldFont);

            for (Map<String, Object> m : marks) {
                addCell(table, String.valueOf(m.getOrDefault("course_code", "")), bodyFont);
                addCell(table, String.valueOf(m.getOrDefault("course_name", "")), bodyFont);
                addCell(table, String.valueOf(m.getOrDefault("credits", "3")), bodyFont);
                addCell(table, String.valueOf(m.getOrDefault("grade", "P")), boldFont);
                addCell(table, Boolean.TRUE.equals(m.get("is_pass")) ? "PASSED" : "ARREAR", bodyFont);
            }

            doc.add(table);
            doc.close();
            return out.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("Error generating Result Sheet PDF", e);
        }
    }

    public byte[] exportToExcel(String sheetName, List<String> headers, List<List<Object>> rows) {
        try (Workbook workbook = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = workbook.createSheet(sheetName);

            // Header row
            Row headerRow = sheet.createRow(0);
            CellStyle headerStyle = workbook.createCellStyle();
            org.apache.poi.ss.usermodel.Font font = workbook.createFont();
            font.setBold(true);
            headerStyle.setFont(font);

            for (int i = 0; i < headers.size(); i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers.get(i));
                cell.setCellStyle(headerStyle);
            }

            // Data rows
            int rowIdx = 1;
            for (List<Object> rowData : rows) {
                Row row = sheet.createRow(rowIdx++);
                for (int colIdx = 0; colIdx < rowData.size(); colIdx++) {
                    Cell cell = row.createCell(colIdx);
                    Object val = rowData.get(colIdx);
                    if (val == null) cell.setCellValue("");
                    else if (val instanceof Number n) cell.setCellValue(n.doubleValue());
                    else cell.setCellValue(val.toString());
                }
            }

            for (int i = 0; i < headers.size(); i++) {
                sheet.autoSizeColumn(i);
            }

            workbook.write(out);
            return out.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("Error generating Excel file", e);
        }
    }

    private void addCell(PdfPTable table, String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setPadding(6f);
        cell.setBorderColor(new Color(229, 232, 240));
        table.addCell(cell);
    }
}
