# Agentic Pharma

Automated clinical trial pipeline using LLMs + R + SAS.

## What it does

- **Flow 1** — Upload a trial protocol PDF → AI extracts eligibility criteria, endpoints, dosing schedule → structured JSON output
- **Flow 2** — Patient data → AI screens against trial criteria → include/exclude decision with reasoning per criterion
- **Flow 3** — Trial data + screening results → AI drafts CSR sections in ICH E3 format → ready for review

## Stack

- Python + Groq API / LLaMA 3.3 70B (LLM reasoning)
- R + ggplot2 + gt (statistical visualization and tables)
- SAS OnDemand — PROC MEANS, PROC FREQ (regulatory descriptive statistics)

## Output files


|
 File 
|
 Description 
|
|
------
|
-------------
|
|
 trial_data.json 
|
 Extracted trial criteria from protocol PDF 
|
|
 screening_results.json 
|
 Patient eligibility decisions with reasoning 
|
|
 csr_draft.txt 
|
 Draft CSR sections in ICH E3 format 
|

## How to run

```bash
python run_pipeline.py
```

## highlights

- Full pipeline runs end to end in under 3 minutes with one command
- Uses pharma-standard terminology: adverse events, CSR, inclusion/exclusion criteria, ICH E3
- AI reasoning is transparent — every eligibility decision includes criterion-level pass/fail with explanation
- SAS outputs are regulatory-grade descriptive statistics matching FDA submission standards

## Author

Kasim Ali — Clinical SAS & R Programmer
- Portfolio: https://kasim-ali-sas-programmer-yg7ud0q.gamma.site
- LinkedIn: https://linkedin.com/in/kasimali2025
- Email: kasimali.global3@gmail.com
