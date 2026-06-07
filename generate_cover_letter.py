import os
import sys
import subprocess

# Ensure requests installed
try:
    import requests
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "requests"])
    import requests

script_dir = os.path.dirname(os.path.abspath(__file__))
output_path = os.path.join(script_dir, "DIAB2024_eCTD_Submission", "admin", "cover-letter", "Cover_Letter.txt")

api_key = os.getenv("GROQ_API_KEY")
if not api_key:
    sys.stderr.write("GROQ_API_KEY not set\n")
    sys.exit(1)

prompt = (
    "Draft a formal FDA NDA cover letter for dulaglutide 1.5mg in Type 2 Diabetes. "
    "The letter should be ~300 words, include study ID DIAB2024, a brief summary of the trial, and a request for submission acceptance. "
    "Use a professional tone and standard cover letter format."
)

payload = {
    "model": "llama-3.3-70b-versatile",
    "messages": [
        {"role": "system", "content": "You are a regulatory affairs specialist drafting FDA cover letters."},
        {"role": "user", "content": prompt}
    ],
    "temperature": 0.3,
    "max_tokens": 800,
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

# Ensure directory exists
os.makedirs(os.path.dirname(output_path), exist_ok=True)

with open(output_path, "w", encoding="utf-8") as f:
    f.write(content)
print(f"Cover letter written to {output_path}")
