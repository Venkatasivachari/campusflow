import os
import re
import pandas as pd
import openpyxl

def analyze():
    base_dir = os.path.join(os.path.dirname(__file__), "..", "data")
    excel_path = os.path.join(base_dir, "student_dataset_v1.xlsx")
    csv_path = os.path.join(base_dir, "student_dataset_v1.csv")

    print(f"Reading {excel_path}...")
    wb = openpyxl.load_workbook(excel_path)
    sheet_names = wb.sheetnames
    print(f"Worksheets: {sheet_names}")

    df = pd.read_excel(excel_path, sheet_name=0)
    print(f"Columns: {list(df.columns)}")
    print(f"Total rows: {len(df)}")
    print(df.head(5))

    # 1. Missing values
    missing = df.isnull().sum()
    print("Missing values per column:\n", missing)

    # 2. Gender distribution
    gender_col = [c for c in df.columns if 'gender' in c.lower()][0]
    name_col = [c for c in df.columns if 'name' in c.lower()][0]
    phone_col = [c for c in df.columns if 'phone' in c.lower()][0]

    print("\nGender counts:")
    print(df[gender_col].value_counts(dropna=False))

    # 3. Duplicate checks
    complete_dup = df.duplicated().sum()
    phone_dup = df.duplicated(subset=[phone_col]).sum()
    name_counts = df[name_col].value_counts()
    repeated_names = name_counts[name_counts > 1]

    print(f"\nComplete duplicate rows: {complete_dup}")
    print(f"Duplicate phone numbers: {phone_dup}")
    print(f"Repeated names count: {len(repeated_names)} (total occurrences: {repeated_names.sum()})")

    # 4. Phone format checks
    # convert phone to string, strip whitespace
    df['phone_clean'] = df[phone_col].astype(str).str.strip().str.replace(r'\.0$', '', regex=True)
    df['phone_len'] = df['phone_clean'].str.len()
    df['phone_is_digit'] = df['phone_clean'].str.isdigit()
    invalid_phones = df[(df['phone_len'] != 10) | (~df['phone_is_digit'])]
    print(f"Invalid phone numbers (<> 10 digits or non-digit): {len(invalid_phones)}")

    # 5. Encoding issues in names
    # Detect typical mojibake characters like Ã, Â, â, ?, unprintable, etc.
    mojibake_pattern = re.compile(r'[ÃÂâ€šï¿½\?\x80-\x9f]')
    
    encoding_issues = []
    clean_names = []

    for idx, row in df.iterrows():
        raw_name = str(row[name_col])
        has_issue = bool(mojibake_pattern.search(raw_name))
        
        # Check non-ascii or weird sequences
        # Common mojibake in Indian names: e.g. Ã©, â€™, etc.
        # Try ftfy style decoding or latin1 -> utf8
        fixed_name = raw_name
        if has_issue:
            try:
                # Common fix for Windows-1252 / latin1 misread as UTF-8
                fixed = raw_name.encode('latin1').decode('utf-8')
                if not mojibake_pattern.search(fixed):
                    fixed_name = fixed
            except Exception:
                # If cannot safely convert, remove invalid artifact bytes
                fixed_name = re.sub(r'[ÃÂâ€šï¿½\?]', '', raw_name).strip()
            
            encoding_issues.append({
                "row_index": idx + 2, # 1-based + header
                "original_name": raw_name,
                "suggested_fixed_name": fixed_name,
                "phone": row['phone_clean'],
                "gender": row[gender_col]
            })

    print(f"Names with detected encoding/character issues: {len(encoding_issues)}")

    # 6. Generate Data Quality Report Excel
    dq_report_path = os.path.join(base_dir, "data_quality_report.xlsx")
    with pd.ExcelWriter(dq_report_path, engine='openpyxl') as writer:
        # Sheet 1: Executive Summary
        summary_data = [
            {"Metric": "Total Records in Source File", "Value": len(df)},
            {"Metric": "Worksheets Count", "Value": len(sheet_names)},
            {"Metric": "Columns Present", "Value": ", ".join(df.columns[:3])},
            {"Metric": "Missing / Null Values", "Value": int(missing.sum())},
            {"Metric": "Complete Duplicate Rows", "Value": complete_dup},
            {"Metric": "Duplicate Phone Numbers", "Value": phone_dup},
            {"Metric": "Repeated Names (Legitimate same names)", "Value": len(repeated_names)},
            {"Metric": "Invalid Phone Number Formats", "Value": len(invalid_phones)},
            {"Metric": "Names with Encoding / Mojibake Issues", "Value": len(encoding_issues)},
            {"Metric": "Male Students Count", "Value": int((df[gender_col] == 'Male').sum())},
            {"Metric": "Female Students Count", "Value": int((df[gender_col] == 'Female').sum())},
            {"Metric": "Male Percentage", "Value": f"{(df[gender_col] == 'Male').mean()*100:.2f}%"},
            {"Metric": "Female Percentage", "Value": f"{(df[gender_col] == 'Female').mean()*100:.2f}%"}
        ]
        pd.DataFrame(summary_data).to_excel(writer, sheet_name="Executive Summary", index=False)

        # Sheet 2: Repeated Names
        if len(repeated_names) > 0:
            rep_df = repeated_names.reset_index()
            rep_df.columns = ["Student_Name", "Occurrences_Count"]
            rep_df.to_excel(writer, sheet_name="Repeated Names", index=False)

        # Sheet 3: Encoding Issues
        if len(encoding_issues) > 0:
            pd.DataFrame(encoding_issues).to_excel(writer, sheet_name="Encoding Issues", index=False)

        # Sheet 4: Invalid Phones (if any)
        if len(invalid_phones) > 0:
            invalid_phones[[name_col, phone_col, gender_col]].to_excel(writer, sheet_name="Invalid Phones", index=False)

    print(f"Generated {dq_report_path}")

    # 7. Student Import Errors (if any rejected rows)
    import_errors_path = os.path.join(base_dir, "student_import_errors.xlsx")
    if len(invalid_phones) > 0:
        invalid_phones.to_excel(import_errors_path, index=False)
    else:
        # Create empty template sheet with schema
        empty_err = pd.DataFrame(columns=["Row_Index", "Student_Name", "Phone_No", "Gender", "Error_Reason", "Action_Required"])
        empty_err.to_excel(import_errors_path, index=False)
    print(f"Generated {import_errors_path}")

if __name__ == "__main__":
    analyze()
