# Sentiment Analysis in News Headlines (2017–2023)
This repository contains the R scripts used to collect Spanish-language news headlines from Google News and perform a sentiment analysis using the AFINN-ES lexicon.
The project is part of the doctoral research “Activating Headlines: Negative Discourse, Emotional Consumption, and Critical Media Literacy in Post-COVID Digital Press (2017–2023)”.

## Included Files
- codigo_analisis_sentimiento.R — main script containing functions for data collection, cleaning, and sentiment analysis.
- afinn_es.csv — AFINN-ES lexicon used for semantic scoring.
- noticias_afinn_filtradas.xlsx — example output dataset containing analysed headlines.

## Requirements

- R version ≥ 4.2
- Required libraries: install.packages(c("tidyRSS", "dplyr", "stringr", "tidytext", "openxlsx"))

## Execution

1. Download or clone this repository.
2. Open the .R script in RStudio.
3. Ensure that the file afinn_es.csv is located in the same working directory.
4. Run the script to generate the results file (noticias_afinn_filtradas.xlsx).

## Methodological Overview

- Data source: Google News RSS (2017–2023)
- Language: Spanish
- Sentiment analysis: AFINN-ES lexicon (values from −8 to +8)
- Analytical approach: Tokenisation, lexicon-based scoring, and descriptive statistics.

The script allows for reproducible large-scale sentiment analysis on Spanish media headlines and can be adapted for other datasets, languages, or timeframes.

## Citation

If you use this code or dataset in your research, please cite as:

Zamora Cánovas, J. J. (2025). Sentiment Analysis in News Headlines (2017–2023) [Computer software]. GitHub.
Available at: https://github.com/yourusername/sentiment-news-ES

## License

This repository is distributed under the MIT License, allowing reuse with attribution.
See the LICENSE
 file for details.

✉️ Contact

Author: Jorge José Zamora Cánovas
Email: jorge.zamora@edu.upct.es

Year: 2025
