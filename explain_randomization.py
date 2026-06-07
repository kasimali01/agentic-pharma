import os
import sys
import json
import subprocess

# Ensure requests is installed
try:
    import requests
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "requests"])
    import requests

# Paths
script_dir = os.path.dirname(os.path.abspath(__file__))
csv_path = os.path.join(script_dir, "randomization_schedule.csv")
output_path = os.path.join(script_dir, "randomization_review.txt")

# Read CSV content
with open(csv_path, "r", encoding="utf-8") as f:
    csv_content = f.read()

api_key = os.getenv("GROQ_API_KEY")
if not api_key:
    sys.stderr.write("GROQ_API_KEY not set\n")
    sys.exit(1)

prompt = (
    "Please review the following stratified blocked randomization schedule for balance across sites and baseline HbA1c categories, and assess any potential selection bias. "
    "Provide a concise summary highlighting any imbalances and suggestions for improvement."
)

payload = {
    "model": "llama-3.3-70b-versatile",
    "messages": [
        {"role": "system", "content": "You are a clinical trial statistician reviewing randomization balance."},
        {"role": "user", "content": f"Schedule CSV:\n{csv_content}\n\n{prompt}"}
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
print(f"Randomization review written to {output_path}")
