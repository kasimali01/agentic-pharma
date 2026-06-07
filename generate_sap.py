import os
import json
import sys

# Ensure required package
try:
    import requests
except ImportError:
    import subprocess, sys
    subprocess.check_call([sys.executable, "-m", "pip", "install", "requests"])
    import requests

# Load inputs
inputs_path = os.path.join(os.path.dirname(__file__), "sap_inputs.json")
with open(inputs_path, "r", encoding="utf-8") as f:
    sap_inputs = json.load(f)

api_key = os.getenv("GROQ_API_KEY")
if not api_key:
    sys.stderr.write("GROQ_API_KEY not set\n")
    sys.exit(1)

# Prepare prompt for SAP generation
prompt = (
    "Generate a full Statistical Analysis Plan (SAP) following ICH E9 guidelines. Include the following sections: "
    "1. Introduction, 2. Study Objectives, 3. Study Design, 4. Population, 5. Handling of Missing Data, "
    "6. Statistical Methods, 7. Appendices. Use the details provided in the JSON input."
)

# Build request payload
payload = {
    "model": "llama-3.3-70b-versatile",
    "messages": [
        {"role": "system", "content": "You are a clinical statistics writer."},
        {"role": "user", "content": f"Inputs: {json.dumps(sap_inputs)}\n\n{prompt}"}
    ],
    "temperature": 0.2,
    "max_tokens": 4096,
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

# Write SAP draft
output_path = os.path.join(os.path.dirname(__file__), "sap_draft.txt")
with open(output_path, "w", encoding="utf-8") as f:
    f.write(content)
print(f"SAP draft written to {output_path}")
