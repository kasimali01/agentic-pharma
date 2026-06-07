import os
import shutil
import sys

# Base directory (Desktop)
base_dir = os.path.join(os.path.expanduser('~'), 'Desktop')
submission_dir = os.path.join(base_dir, 'DIAB2024_eCTD_Submission')

# Folder structure
folders = [
    os.path.join(submission_dir, 'm5', 'datasets', 'sdtm'),
    os.path.join(submission_dir, 'm5', 'datasets', 'adam'),
    os.path.join(submission_dir, 'm5', 'reports', 'csr'),
    os.path.join(submission_dir, 'm5', 'tfl', 'tables'),
    os.path.join(submission_dir, 'm5', 'tfl', 'figures'),
    os.path.join(submission_dir, 'm5', 'safety', 'sae'),
    os.path.join(submission_dir, 'admin', 'cover-letter')
]

# Create directories
for d in folders:
    os.makedirs(d, exist_ok=True)

# Helper to copy files if they exist
def copy_if_exists(src, dst):
    if os.path.exists(src):
        shutil.copy2(src, dst)
        print(f"Copied {src} to {dst}")
    else:
        print(f"Source file not found: {src}")

# Define file mappings (source -> destination folder)
desktop = base_dir
mappings = {
    # SDTM datasets
    os.path.join(desktop, 'SDTM_DM.csv'): os.path.join(submission_dir, 'm5', 'datasets', 'sdtm'),
    os.path.join(desktop, 'SDTM_AE.csv'): os.path.join(submission_dir, 'm5', 'datasets', 'sdtm'),
    os.path.join(desktop, 'SDTM_LB.csv'): os.path.join(submission_dir, 'm5', 'datasets', 'sdtm'),
    # ADaM datasets
    os.path.join(desktop, 'ADSL.csv'): os.path.join(submission_dir, 'm5', 'datasets', 'adam'),
    os.path.join(desktop, 'ADLB.csv'): os.path.join(submission_dir, 'm5', 'datasets', 'adam'),
    os.path.join(desktop, 'ADAE.csv'): os.path.join(submission_dir, 'm5', 'datasets', 'adam'),
    # CSR draft
    os.path.join(desktop, 'CSR_Draft.docx'): os.path.join(submission_dir, 'm5', 'reports', 'csr'),
    # TLF tables and figures
    os.path.join(desktop, 'TLF_Table1_Demographics.html'): os.path.join(submission_dir, 'm5', 'tfl', 'tables'),
    os.path.join(desktop, 'TLF_Table2_Efficacy.html'): os.path.join(submission_dir, 'm5', 'tfl', 'tables'),
    os.path.join(desktop, 'TLF_Table3_AE.html'): os.path.join(submission_dir, 'm5', 'tfl', 'tables'),
    os.path.join(desktop, 'TLF_Figure1_HbA1c.png'): os.path.join(submission_dir, 'm5', 'tfl', 'figures'),
    # SAE documents
    os.path.join(desktop, 'SAE_narratives.txt'): os.path.join(submission_dir, 'm5', 'safety', 'sae'),
    os.path.join(desktop, 'SAE_tracking_report.html'): os.path.join(submission_dir, 'm5', 'safety', 'sae'),
    # Cover letter will be generated later
}

# Copy files
for src, dst_dir in mappings.items():
    copy_if_exists(src, dst_dir)

print('eCTD folder structure created at', submission_dir)
