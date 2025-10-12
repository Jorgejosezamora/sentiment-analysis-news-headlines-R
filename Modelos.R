## Modelo de regresión lineal simple

# Cargar librerías necesarias
library(ggplot2)
library(lmtest)
library(car)
library(readxl)

# Datos de entrada
Variables <- read_excel("C:/Users/Usuario/OneDrive - EXPERTOS TRIBUTARIOS ASOCIADOS, S.L.P/Escritorio/Jorge/Nóminas/Artículo/Modelos de regresión/Variables.xlsx")
attach(Variables)

# MRLS
modelo_mrls <- lm(consumo_digital ~ sentimiento, data = Variables)
summary(modelo_mrls)

# Diagnóstico: residuos
shapiro.test(residuals(modelo_mrls))        # Normalidad
bptest(modelo_mrls)                          # Homocedasticidad (Breusch-Pagan)
dwtest(modelo_mrls)                          # Autocorrelación (Durbin-Watson)

# Visualización: dispersión + recta
ggplot(Variables, aes(x = sentimiento, y = consumo_digital)) +
  geom_point(size = 3) +
  geom_smooth(method = "lm", se = FALSE, color = "blue") +
  theme_minimal() +
  labs(title = "Relación entre sentimiento y consumo digital",
       x = "Sentimiento medio anual", y = "Consumo digital estimado (€)")


## Modelo de regresión lineal múltiple

# MRLM
modelo_mrlm <- lm(consumo_digital ~ sentimiento + pib_per_capita, data = Variables)
summary(modelo_mrlm)

# Diagnóstico
shapiro.test(residuals(modelo_mrlm))         # Normalidad
bptest(modelo_mrlm)                           # Homocedasticidad
dwtest(modelo_mrlm)                           # Autocorrelación

#Visualización: efecto parcial
avPlots(modelo_mrlm)


## Comparación

# Comparación de R² ajustado y AIC
cat("R² ajustado MRLS:", summary(modelo_mrls)$adj.r.squared, "\n")
cat("R² ajustado MRLM:", summary(modelo_mrlm)$adj.r.squared, "\n")

AIC(modelo_mrls, modelo_mrlm)  # Comparar calidad relativa de ajuste

