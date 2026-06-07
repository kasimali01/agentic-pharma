import os
import sys
import subprocess
import json

# Ensure requests installed
try:
    import requests
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "requests"])
    import requests

script_dir = os.path.dirname(os.path.abspath(__file__))
risk_csv = os.path.join(script_dir, "site_risk_scores.csv")
output_path = os.path.join(script_dir, "site_visit_reports.txt")

# Read CSV content
with open(risk_csv, "r", encoding="utf-8") as f:
    csv_content = f.read()

api_key = os.getenv("GROQ_API_KEY")
if not api_key:
    sys.stderr.write("GROQ_API_KEY not set\n")
    sys.exit(1)

prompt = (
    "For each site with HIGH risk, draft a formal site visit report in ICH E6 GCP format. "
    "Include site identifier, identified risk factors, recommended corrective actions, and a timeline. "
    "Separate each site report with a blank line."
)

payload = {
    "model": "llama-3.3-70b-versatile",
    "messages": [
        {"role": "system", "content": "You are a clinical trial CRA writing site visit reports."},
        {"role": "user", "content": f"Site risk CSV:\n{csv_content}\n\n{prompt}"}
    ],
    "temperature": 0.2,
    "max_tokens": 4096,
}

headers = {
    "Authorization": f"Bearer {api_key}",
    "Content-Type": "application/json"
}

response = requests.post("https://api.groq.com/openai/v1/chat/completions", json=payload, headers=headers, timeout=120)
if response.status_code != 200:
    sys.stderr.write(f"Groq API error {response.status_code}: {response.text}\n")
    sys.exit(1)

result = response.json()
content = result["choices"][0]["message"]["content"]

with open(output_path, "w", encoding="utf-8") as f:
    f.write(content)
print(f"Site visit reports written to {output_path}")
