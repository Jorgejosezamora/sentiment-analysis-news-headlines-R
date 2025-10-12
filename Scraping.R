# ----------------------------------------------
# 📌 1. CARGA DE LIBRERÍAS NECESARIAS
# ----------------------------------------------
library(tidyRSS)
library(dplyr)
library(stringr)
library(tidytext)
library(openxlsx)

# ----------------------------------------------
# 📌 2. DEFINICIÓN DE CATEGORÍAS, SUJETOS Y EVENTOS
# ----------------------------------------------
sujetos <- list(
  politica = c("Pedro Sánchez", "PP", "PSOE", "Abascal", "Gobierno", "Congreso", "Yolanda Díaz", "Sumar"),
  sociedad = c("Menores", "Inmigrantes", "Policía", "Sanidad", "Educación", "Jóvenes", "Jubilados", "Pymes"),
  empresas = c("Amazon", "Inditex", "Iberdrola", "Mercadona", "Facebook", "Ryanair"),
  cultura = c("Rosalía", "Shakira", "Ibai", "Netflix", "Eurovisión", "Operación Triunfo"),
  deporte = c("Real Madrid", "Barcelona", "Vinicius", "Rubiales", "Luis Enrique", "Selección Española")
)

eventos_relacionados <- list(
  politica = c("corrupción", "elecciones", "dimisión", "polémica", "condena", "fraude"),
  sociedad = c("violencia", "protestas", "agresión", "suicidio", "crisis", "colapso"),
  empresas = c("fraude", "sanción", "investigación", "escándalo", "paro"),
  cultura = c("polémica", "acusación", "protestas", "tragedia"),
  deporte = c("escándalo", "agresión", "acusación", "investigación", "sanción")
)

combinaciones <- bind_rows(lapply(names(sujetos), function(categoria) {
  expand.grid(
    sujeto = sujetos[[categoria]],
    evento = eventos_relacionados[[categoria]],
    categoria = categoria,
    stringsAsFactors = FALSE
  )
}))

meses <- c("enero", "febrero", "marzo", "abril", "mayo", "junio",
           "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre")
anios <- 2017:2024

combinaciones_finales <- merge(combinaciones, expand.grid(mes = meses, anio = anios), all = TRUE)
combinaciones_finales$busqueda <- paste(combinaciones_finales$sujeto,
                                        combinaciones_finales$evento,
                                        combinaciones_finales$mes,
                                        combinaciones_finales$anio)

# ----------------------------------------------
# 📌 3. FUNCIÓN DE SCRAPING POR CATEGORÍA Y AÑO
# ----------------------------------------------
crear_url <- function(tema) {
  base <- "https://news.google.com/rss/search?q="
  query <- gsub(" ", "+", tema)
  paste0(base, query, "&hl=es&gl=ES&ceid=ES:es")
}

scrapear_categoria_anio <- function(nombre_categoria, anio_filtro) {
  cat("\n⏳ Procesando categoría:", nombre_categoria, "| Año:", anio_filtro, "\n")
  
  combinaciones_filtradas <- combinaciones_finales %>%
    filter(categoria == nombre_categoria, anio == anio_filtro)
  
  temas <- combinaciones_filtradas$busqueda
  
  lista_noticias <- lapply(seq_along(temas), function(i) {
    tema <- temas[i]
    cat("  → [", i, "/", length(temas), "] Tema:", tema, "\n")
    Sys.sleep(runif(1, 1, 2))  # Pausa para evitar bloqueo
    url <- crear_url(tema)
    feed <- tryCatch(tidyfeed(url), error = function(e) data.frame())
    if (nrow(feed) == 0) return(NULL)
    
    colnames(feed) <- tolower(colnames(feed))
    if ("entry_title" %in% colnames(feed)) feed$item_title <- feed$entry_title
    if ("entry_link" %in% colnames(feed)) feed$item_link <- feed$entry_link
    if ("entry_published" %in% colnames(feed)) feed$item_pub_date <- feed$entry_published
    if (!all(c("item_title", "item_link", "item_pub_date") %in% colnames(feed))) return(NULL)
    
    feed %>%
      select(item_title, item_link, item_pub_date) %>%
      mutate(tema = tema)
  })
  
  lista_noticias <- Filter(Negate(is.null), lista_noticias)
  if (length(lista_noticias) == 0) return(NULL)
  
  noticias <- bind_rows(lista_noticias) %>%
    distinct(item_title, .keep_all = TRUE) %>%
    mutate(id = row_number(), categoria = nombre_categoria, anio = anio_filtro)
  
  saveRDS(noticias, paste0("noticias_", nombre_categoria, "_", anio_filtro, ".rds"))
  cat("✅ Guardado: noticias_", nombre_categoria, "_", anio_filtro, ".rds\n")
  return(noticias)
}

# ----------------------------------------------
# 📌 4. EJECUCIÓN POR BLOQUES CON CONTROL DE ERRORES
# ----------------------------------------------
categorias <- names(sujetos)
anios <- 2017:2024

for (cat in categorias) {
  for (a in anios) {
    tryCatch({
      scrapear_categoria_anio(cat, a)
    }, error = function(e) {
      cat("⚠️ Error en:", cat, "-", a, "|", conditionMessage(e), "\n")
    })
  }
}

# ----------------------------------------------
# 📌 5. UNIFICACIÓN DE RESULTADOS
# ----------------------------------------------
archivos <- list.files(pattern = "noticias_.*\\.rds")
noticias_total <- bind_rows(lapply(archivos, readRDS)) %>%    # ERROR AQUI
  distinct(item_title, .keep_all = TRUE) %>%
  mutate(id = row_number())

# ----------------------------------------------
# 📌 6. ANÁLISIS DE SENTIMIENTO CON AFINN-ES
# ----------------------------------------------
titulares <- noticias_total %>%
  unnest_tokens(palabra, item_title)

afinn_es <- read.csv("C:/ruta/a/afinn_es.csv", stringsAsFactors = FALSE)

sentimiento_afinn <- titulares %>%
  inner_join(afinn_es, by = "palabra") %>%
  group_by(id) %>%
  summarise(sentimiento_afinn = sum(score))

# ----------------------------------------------
# 📌 6BIS. FILTRADO POR MEDIOS DIGITALES PRINCIPALES + FECHA
# ----------------------------------------------
noticias_afinn <- noticias_total %>%
  left_join(sentimiento_afinn, by = "id") %>%
  mutate(
    sentimiento_afinn = ifelse(is.na(sentimiento_afinn), 0, sentimiento_afinn),
    item_pub_date = as.Date(item_pub_date),
    anio_pub = format(item_pub_date, "%Y"),
    mes_pub = format(item_pub_date, "%m"),
    dominio = str_extract(item_link, "(?<=//)[^/]+"),
    medio = case_when(
      str_detect(dominio, "elpais") ~ "El País",
      str_detect(dominio, "elmundo") ~ "El Mundo",
      str_detect(dominio, "abc.es") ~ "ABC",
      str_detect(dominio, "lavanguardia") ~ "La Vanguardia",
      str_detect(dominio, "elconfidencial") ~ "El Confidencial",
      str_detect(dominio, "eldiario") ~ "eldiario.es",
      str_detect(dominio, "20minutos") ~ "20 Minutos",
      str_detect(dominio, "okdiario") ~ "OKDiario",
      str_detect(dominio, "elespanol") ~ "El Español",
      str_detect(dominio, "publico") ~ "Publico",
      TRUE ~ "Otro"
    )
  ) %>%
  filter(medio != "Otro")

# ----------------------------------------------
# 📌 7. EXPORTACIÓN FINAL
# ----------------------------------------------
write.xlsx(noticias_afinn, file = "noticias_afinn_filtradas.xlsx")
cat("✅ Exportado con", nrow(noticias_afinn), "titulares de medios principales.\n")

