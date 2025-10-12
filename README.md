# Análisis de sentimiento en titulares de noticias (2017–2024)
Este repositorio contiene el código en **R** utilizado para recopilar titulares desde **Google News** y aplicar un análisis de sentimiento con el léxico **AFINN-ES**.

## Archivos incluidos
- `codigo_analisis_sentimiento.R`: código principal.
- `afinn_es.csv`: léxico AFINN-ES.
- `noticias_afinn_filtradas.xlsx`: ejemplo de resultados.

## Requisitos
- R versión ≥ 4.2  
- Librerías: `tidyRSS`, `dplyr`, `stringr`, `tidytext`, `openxlsx`

## Ejecución
1. Descargue este repositorio.  
2. Abra el archivo `.R` en RStudio.  
3. Asegúrese de tener el léxico `afinn_es.csv` en la misma carpeta.  
4. Ejecute el script para generar el archivo de resultados.

Autor: Jorge José Zamora Cánovas  
Año: 2025
