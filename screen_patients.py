import csv
from groq import Groq
import json
import re

GROQ_API_KEY = "GROQ_API_KEY = "YOUR_KEY_PLACEHOLDER"

client = Groq(api_key=GROQ_API_KEY)

# Load trial criteria from Flow 1
with open(r"C:\Users\kasim\Desktop\trial_data.json") as f:
    trial = json.load(f)

# Dummy patient data
patients = [
    {"patient_id": "P001", "age": 58, "diagnosis": "Type2Diabetes", "hba1c": 8.2, "current_med": "metformin", "prior_insulin": "No", "weight_loss_med": "No"},
    {"patient_id": "P002", "age": 45, "diagnosis": "Type2Diabetes", "hba1c": 7.1, "current_med": "metformin", "prior_insulin": "No", "weight_loss_med": "Yes"},
    {"patient_id": "P003", "age": 67, "diagnosis": "Type1Diabetes", "hba1c": 9.8, "current_med": "insulin", "prior_insulin": "Yes", "weight_loss_med": "No"},
    {"patient_id": "P004", "age": 34, "diagnosis": "Type2Diabetes", "hba1c": 8.5, "current_med": "metformin", "prior_insulin": "No", "weight_loss_med": "No"},
    {"patient_id": "P005", "age": 52, "diagnosis": "Type2Diabetes", "hba1c": 7.9, "current_med": "metformin", "prior_insulin": "No", "weight_loss_med": "No"},
]

results = []

for patient in patients:
    print(f"Screening {patient['patient_id']}...")

    prompt = f"""You are a clinical trial coordinator. Given these patient details and trial criteria, decide if the patient is ELIGIBLE or INELIGIBLE.

Trial inclusion criteria: {trial['inclusion_criteria']}
Trial exclusion criteria: {trial['exclusion_criteria']}

Patient data: {json.dumps(patient)}

Return JSON only, no extra text:
{{
  "patient_id": "{patient['patient_id']}",
  "decision": "ELIGIBLE or INELIGIBLE",
  "reason": "one sentence summary",
  "criteria_results": [
    {{"criterion": "criterion text", "result": "PASS or FAIL", "reason": "one sentence"}}
  ]
}}"""

    response = client.chat.completions.create(
        model="llama-3.3-70b-versatile",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.1
    )

    raw = response.choices[0].message.content.strip()
    raw = re.sub(r"```json|```", "", raw).strip()
    result = json.loads(raw)
    results.append(result)

with open(r"C:\Users\kasim\Desktop\screening_results.json", "w") as f:
    json.dump(results, f, indent=2)

print("\nDone! screening_results.json saved to Desktop.")
for r in results:
    print(f"{r['patient_id']}: {r['decision']} — {r['reason']}")