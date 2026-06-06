import subprocess
import sys
import time

steps = [
    ("Flow 1: Extracting trial criteria from protocol PDF...", "extract_trial.py"),
    ("Flow 2: Screening patients against trial criteria...", "screen_patients.py"),
    ("Flow 3: Generating CSR draft...", "generate_csr.py"),
]

print("=" * 60)
print("AGENTIC PHARMA — CLINICAL TRIAL AUTOMATION PIPELINE")
print("=" * 60)

for message, script in steps:
    print(f"\n{message}")
    result = subprocess.run([sys.executable, script], capture_output=False)
    if result.returncode != 0:
        print(f"ERROR in {script}. Pipeline stopped.")
        sys.exit(1)
    time.sleep(1)

print("\n" + "=" * 60)
print("PIPELINE COMPLETE. Output files on Desktop:")
print("  trial_data.json        — extracted trial criteria")
print("  screening_results.json — patient eligibility decisions")
print("  csr_draft.txt          — CSR draft sections")
print("=" * 60)