from groq import Groq
import json

GROQ_API_KEY = "YOUR_KEY_PLACEHOLDER"

client = Groq(api_key=GROQ_API_KEY)

with open(r"C:\Users\kasim\Desktop\trial_data.json") as f:
    trial = json.load(f)

with open(r"C:\Users\kasim\Desktop\screening_results.json") as f:
    screening = json.load(f)

eligible = [r for r in screening if r["decision"] == "ELIGIBLE"]
ineligible = [r for r in screening if r["decision"] == "INELIGIBLE"]

prompt = f"""You are a senior medical writer with 15 years of experience writing FDA submission documents. Write in formal ICH E3 Clinical Study Report format.

Using the trial protocol data and patient screening results below, draft the following CSR sections:

1. Background and Rationale (200 words)
2. Study Design Summary (150 words)
3. Patient Disposition and Demographics (200 words)
4. Safety Overview (150 words)

Use formal regulatory language. Say adverse events not side effects. Say subjects not patients.

Trial data: {json.dumps(trial, indent=2)}
Screening summary: {len(eligible)} eligible subjects, {len(ineligible)} ineligible subjects
Ineligible reasons: {[r['reason'] for r in ineligible]}"""

print("Generating CSR draft...")

response = client.chat.completions.create(
    model="llama-3.3-70b-versatile",
    messages=[{"role": "user", "content": prompt}],
    temperature=0.2
)

csr_text = response.choices[0].message.content.strip()

with open(r"C:\Users\kasim\Desktop\csr_draft.txt", "w") as f:
    f.write(csr_text)

print("Done! csr_draft.txt saved to Desktop.")
print("\nPreview:")
print(csr_text[:500])