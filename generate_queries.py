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
report_csv = os.path.join(script_dir, "query_report.csv")
output_path = os.path.join(script_dir, "formal_queries.txt")

# Read CSV content
with open(report_csv, "r", encoding="utf-8") as f:
    csv_content = f.read()

api_key = os.getenv("GROQ_API_KEY")
if not api_key:
    sys.stderr.write("GROQ_API_KEY not set\n")
    sys.exit(1)

prompt = (
    "For each row in the following query report CSV, draft a formal query message to the site coordinator. "
    "Include subject ID, visit, the issue description, and request clarification or correction. "
    "Separate each query with a blank line."
)

payload = {
    "model": "llama-3.3-70b-versatile",
    "messages": [
        {"role": "system", "content": "You are a clinical data manager drafting formal queries for a clinical trial."},
        {"role": "user", "content": f"Query report CSV:\n{csv_content}\n\n{prompt}"}
    ],
    "temperature": 0.2,
    "max_tokens": 2048,
}

headers = {
    "Authorization": f"Bearer {api_key}",
    "Content-Type": "application/json"
}

response = requests.post("https://api.groq.com/openai/v1/chat/completions", json=payload, headers=headers, timeout=60)
if response.status_code != 200:
    sys.stderr.write(f"Groq API error {response.status_code}: {response.text}\n")
    sys.exit(1)

result = response.json()
content = result["choices"][0]["message"]["content"]

with open(output_path, "w", encoding="utf-8") as f:
    f.write(content)
print(f"Formal queries written to {output_path}")
