import os
import sys
import json
import subprocess

# Ensure requests installed
try:
    import requests
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "requests"])
    import requests

script_dir = os.path.dirname(os.path.abspath(__file__))
pk_params_path = os.path.join(script_dir, "PK_parameters.csv")
output_path = os.path.join(script_dir, "pk_interpretation.txt")

# Read PK parameters
with open(pk_params_path, "r", encoding="utf-8") as f:
    pk_csv = f.read()

api_key = os.getenv("GROQ_API_KEY")
if not api_key:
    sys.stderr.write("GROQ_API_KEY not set\n")
    sys.exit(1)

prompt = (
    "Please provide a regulatory interpretation of the following PK parameters for dulaglutide in a Type 2 Diabetes trial. "
    "Comment on Cmax, Tmax, AUC, and half-life values, indicating if they are within expected ranges and any implications for dosing. "
    "Provide a concise paragraph (max 200 words)."
)

payload = {
    "model": "llama-3.3-70b-versatile",
    "messages": [
        {"role": "system", "content": "You are a clinical pharmacokinetics expert."},
        {"role": "user", "content": f"PK parameters CSV:\n{pk_csv}\n\n{prompt}"}
    ],
    "temperature": 0.2,
    "max_tokens": 1024,
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
print(f"PK interpretation written to {output_path}")
