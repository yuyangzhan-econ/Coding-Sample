# Replication File Guide for: "Data Task for Research Assistant (RA) Candidates"

## Overview

This document includes ado files, Stata code, data (including raw data and result data), and charts of the results. To reproduce the results, run `code/master.do`. Note that you need to change the paths before running.

## The File Structure

The folder has the following structure:

```

project\_root/
├── ado/
├── code/
│   ├── master.do                    # Main execution file
│   └── stata\_dofile/
│       ├── 0\_Data\_Preparation.do    # Data cleaning and outcome construction
│       ├── 1\_Tables.do              # Regression analysis and table creation
│       └── 2\_Figures.do             # Monthly coefficient plots
├── data/
│   ├── simulated\_CBdata\_for\_RAtask.csv   # Raw experiment data
│   ├── simulated\_CBdata\_for\_RAtask.csv   # Raw bank transaction data
│   ├── simulated\_experiment\_dta          # .dta format of the experimental data
│   ├── simulated\_CB\_data.dta             # .dta format of the transaction data
│   ├── firm\_level\_outcomes.dta           # Processed results of firm-level data
│   └── firm\_to\_firm\_level\_outcomes.dta   # Processed results of firm-to-firm level data
└── results/
├── tables/
│   ├── firm\_level\_results.csv
│   └── firm\_to\_firm\_level\_results.csv
└── figures/
       └── monthly\_treatment\_effects.pdf     # This PDF compiles all figures

```

## How to Run the Code

To run: all of the code in this folder can be executed at once via `code/master.do`. Before running, you need to change the paths by modifying the global `dir`. The spots where paths need to be changed are clearly marked. The `master.do` file will set up the working environment and install the necessary ado files.

Additionally, if you want to run each dofile separately, a separate option is provided. You need to change the paths at the beginning of that dofile to run it independently.

## Approximate Time Needed

- The main analysis takes **5 minutes**. **Note:** the last few figures in the final dofile may take longer to generate; please be patient.
- **Machine specifications:** CPU: 12th Gen Intel® Core™ i7-12700H, 2.30 GHz; Memory: 16 GB; GPU: NVIDIA GeForce RTX 3060 Laptop GPU 6 GB; Model: Legion Y9000P IAH7H.

## Other Notes

1. You can see the construction of the outcome variables in `0_Data_Preparation.do`. Since the task instructions did not specify in detail how to construct the outcomes and were rather general, I chose what I considered to be a reasonable method.

## AI Usage Acknowledgement

The vast majority of this data task was completed independently by me. However, I acknowledge using AI during the process, mainly in the following parts:

- Translation and writing.
- Troubleshooting some difficult errors, such as plotting failures. I used AI tools' web search capabilities to look up error messages and the correct usage of certain commands.
```
