import pdfplumber
from groq import Groq
import json
import re

# Your Groq API key
GROQ_API_KEY = "YOUR_KEY_PLACEHOLDER"

client = Groq(api_key=GROQ_API_KEY)

print("Reading PDF...")
text = ""
with pdfplumber.open(r"C:\Users\kasim\Desktop\trial_protocol.pdf") as pdf:
    for page in pdf.pages:
        text += page.extract_text() or ""

print(f"Extracted {len(text)} characters from PDF")
print("Sending to Groq AI...")

prompt = f"""You are a clinical trial expert. Extract the following from this protocol as JSON only, no extra text, no markdown:
{{
  "inclusion_criteria": ["list of inclusion criteria"],
  "exclusion_criteria": ["list of exclusion criteria"],
  "primary_endpoint": "string",
  "secondary_endpoints": ["list"],
  "drug_dose": "string",
  "trial_phase": "string",
  "sample_size": 0,
  "trial_duration": "string"
}}

Protocol text:
{text[:10000]}"""

response = client.chat.completions.create(
    model="llama-3.3-70b-versatile",
    messages=[{"role": "user", "content": prompt}],
    temperature=0.1
)

raw = response.choices[0].message.content.strip()
raw = re.sub(r"```json|```", "", raw).strip()

data = json.loads(raw)

with open(r"C:\Users\kasim\Desktop\trial_data.json", "w") as f:
    json.dump(data, f, indent=2)

print("Done! trial_data.json saved to Desktop.")
print(f"Found {len(data['inclusion_criteria'])} inclusion criteria")
print(f"Found {len(data['exclusion_criteria'])} exclusion criteria")
print(f"Trial phase: {data['trial_phase']}")
print(f"Sample size: {data['sample_size']}")
