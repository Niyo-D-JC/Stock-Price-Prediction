# -------------------- Charger les biblioth�ques n�cessaires --------------------
library(xts)        # Pour la gestion des s�ries temporelles
library(ggplot2)    # Pour la visualisation des donn�es
library(quantmod)   # Pour t�l�charger les donn�es boursi�res
library(prophet)    # Pour la mod�lisation des s�ries temporelles
library(dplyr)      # Pour la manipulation des donn�es

# -------------------- Charger les donn�es de l'action ADBE (Adobe) depuis Yahoo Finance --------------------
getSymbols("ADBE", from = "2010-01-01", to = "2024-10-31", src = "yahoo")

# -------------------- Extraire les prix ajust�s d'Adobe --------------------
adobe_prices <- ADBE$ADBE.Adjusted

# -------------------- Enlever la premi�re observation du prix pour que cela corresponde aux donn�es de volatilit� --------------------
adobe_prices <- adobe_prices[-1]

# -------------------- Calcul des rendements log-transform�s des prix d'Adobe --------------------
#adobe_returns <- na.omit(diff(log(adobe_prices)))

# -------------------- Pr�parer les donn�es pour l'analyse --------------------
adobe_data <- data.frame(
  ds = index(adobe_prices),           # Date des observations
  y = as.numeric(adobe_prices)        # Prix de l'action
)

# Ajouter les colonnes de date (mois, jour, ann�e)
adobe_data$month <- format(adobe_data$ds, "%m")
adobe_data$year <- format(adobe_data$ds, "%Y")
adobe_data$day <- format(adobe_data$ds, "%d")

# Extraire le jour de la semaine
adobe_data$day_of_week <- weekdays(adobe_data$ds)

# V�rifier un aper�u des donn�es
head(adobe_data)

# -------------------- Visualisation de la volatilit� --------------------
plot(y = adobe_data$y, x = adobe_data$ds, main = "", 
     ylab = "Prix", col = "blue", type = "l", xlab = "")

# -------------------- Tracer par mois --------------------
# Boxplot de la distribution des rendements par mois
ggplot(adobe_data, aes(x = month, y = y)) +
  geom_boxplot() +
  labs(
    title = "Distribution mensuelle des rendements",
    x = "Mois",
    y = "Rendement"
  ) +
  theme_minimal()

# Densit� des rendements par mois
ggplot(adobe_data, aes(x = y, fill = month)) +
  geom_density(alpha = 0.5) +
  labs(
    title = "Densit� des rendements par mois",
    x = "Rendement",
    y = "Densit�"
  ) +
  theme_minimal()

# -------------------- Tracer par jour du mois --------------------
# Boxplot de la distribution des rendements par jour
ggplot(adobe_data, aes(x = day, y = y)) +
  geom_boxplot() +
  labs(
    title = "Distribution journali�re des rendements",
    x = "Jour",
    y = "Rendement"
  ) +
  theme_minimal()

# Densit� des rendements par jour
ggplot(adobe_data, aes(x = y, fill = day)) +
  geom_density(alpha = 0.5) +
  labs(
    title = "Densit� des rendements par jour du mois",
    x = "Rendement",
    y = "Densit�"
  ) +
  theme_minimal()

# -------------------- Tracer par jour de la semaine --------------------
# Boxplot de la distribution des rendements par jour de la semaine
ggplot(adobe_data, aes(x = day_of_week, y = y)) +
  geom_boxplot() +
  labs(
    title = "Distribution hebdomadaire",
    x = "Jour de la semaine",
    y = "Volatilit�"
  ) +
  theme_minimal()

# Densit� des rendements par jour de la semaine
ggplot(adobe_data, aes(x = y, fill = day_of_week)) +
  geom_density(alpha = 0.5) +
  labs(
    title = "Densit� par jour de la semaine",
    x = "Volatilit�",
    y = "Densit�"
  ) +
  theme_minimal()

# -------------------- Importer les donn�es de volatilit� --------------------
# Importer les donn�es CSV avec les colonnes Volatility et SquaredVolatility
data <- read.csv("E:/ENSAI/ENSAI 3A/Series temp avanc�es/Projet_serie_temp/Stock-Price-Prediction/volatilite_estimee.csv")

# Afficher les premi�res lignes du fichier pour v�rifier le format
head(data)

# Convertir la colonne de date en format Date
data$Date <- as.Date(data$Date)

# Extraire les colonnes Volatility et SquaredVolatility
regressor_data <- data[, c("Date", "Volatility", "SquaredVolatility")]

# Renommer les colonnes pour correspondre � l'input du mod�le Prophet
colnames(regressor_data) <- c("ds", "volatility", "squared_volatility")
head(regressor_data)
nrow(regressor_data)
nrow(adobe_data)

# -------------------- Fusionner les donn�es de volatilit� et de rendements Adobe --------------------
adobe_data$volatility <- regressor_data$volatility
adobe_data$squared_volatility <- regressor_data$squared_volatility

head(adobe_data)

# -------------------- Diviser les donn�es en ensemble d'entra�nement et de test --------------------
train_end_date <- as.Date("2024-08-30")  # Date de fin de l'ensemble d'entra�nement
train_data <- adobe_data[adobe_data$ds <= train_end_date, ]
test_data <- adobe_data[adobe_data$ds > train_end_date, ]

# Cr�er les colonnes de r�gressors pour les �v�nements macro�conomiques dans train_data
train_data$sovereign_debt_crisis <- as.integer(train_data$ds >= as.Date("2010-01-01") & train_data$ds <= as.Date("2012-12-31"))
train_data$oil_shock <- as.integer(train_data$ds >= as.Date("2014-01-01") & train_data$ds <= as.Date("2016-12-31"))
train_data$trade_war <- as.integer(train_data$ds >= as.Date("2018-01-01") & train_data$ds <= as.Date("2019-12-31"))
train_data$covid_pandemic <- as.integer(train_data$ds >= as.Date("2020-01-01") & train_data$ds <= as.Date("2022-12-31"))
train_data$war_ukraine <- as.integer(train_data$ds >= as.Date("2022-02-24"))

# -------------------- Cr�er un dataframe pour Prophet avec les r�gressors --------------------
prophet_train_data <- data.frame(
  ds = as.Date(train_data$ds),
  y = train_data$y
)

# Ajouter les r�gressors � Prophet
prophet_train_data$volatility <- train_data$volatility
prophet_train_data$squared_volatility <- train_data$squared_volatility
prophet_train_data$sovereign_debt_crisis <- train_data$sovereign_debt_crisis
prophet_train_data$oil_shock <- train_data$oil_shock
prophet_train_data$trade_war <- train_data$trade_war
prophet_train_data$covid_pandemic <- train_data$covid_pandemic
prophet_train_data$war_ukraine <- train_data$war_ukraine

head(prophet_train_data)

# -------------------- Cr�er et ajuster le mod�le Prophet --------------------
model <- prophet(
  yearly.seasonality = TRUE,
  weekly.seasonality = TRUE,
  daily.seasonality = FALSE
)

# Ajouter les r�gressors de volatilit� et des �v�nements macro�conomiques
model <- add_regressor(model, 'volatility')
model <- add_regressor(model, 'squared_volatility')
model <- add_regressor(model, 'sovereign_debt_crisis')
model <- add_regressor(model, 'oil_shock')
model <- add_regressor(model, 'trade_war')
model <- add_regressor(model, 'covid_pandemic')
model <- add_regressor(model, 'war_ukraine')

# Ajuster le mod�le aux donn�es d'entra�nement
fit <- fit.prophet(model, prophet_train_data)

# -------------------- Cr�er la dataframe future pour la pr�vision --------------------
future <- make_future_dataframe(fit, periods = nrow(test_data))
future$ds <- as.POSIXct(future$ds, tz = "UTC")

# Ajouter les r�gressors dans le futur
future <- future %>%
  mutate(
    sovereign_debt_crisis = as.integer(ds >= as.POSIXct("2010-01-01", tz = "UTC") & ds <= as.POSIXct("2012-12-31", tz = "UTC")),
    oil_shock = as.integer(ds >= as.POSIXct("2014-01-01", tz = "UTC") & ds <= as.POSIXct("2016-12-31", tz = "UTC")),
    trade_war = as.integer(ds >= as.POSIXct("2018-01-01", tz = "UTC") & ds <= as.POSIXct("2019-12-31", tz = "UTC")),
    covid_pandemic = as.integer(ds >= as.POSIXct("2020-01-01", tz = "UTC") & ds <= as.POSIXct("2022-12-31", tz = "UTC")),
    war_ukraine = as.integer(ds >= as.POSIXct("2022-02-24", tz = "UTC")),
    volatility = adobe_data$volatility,
    squared_volatility = adobe_data$squared_volatility
  )

# -------------------- Visualisation des pr�visions --------------------
forecast <- predict(fit, future)

# S'assurer que la premi�re date de forecast correspond � la premi�re date de test_data
forecast$ds <- adobe_data$ds

# Tracer les pr�visions
plot(fit, forecast)

# Visualisation des pr�visions et des composantes
prophet_plot_components(fit, forecast)

# Visualisation de la pr�vision avec les intervalles d'incertitude
dyplot.prophet(fit, forecast)

# -------------------- Comparaison des donn�es r�elles et des pr�dictions du test --------------------
test_data$ds <- as.Date(test_data$ds)
forecast$ds <- as.Date(forecast$ds)

# Tracer les donn�es r�elles et les pr�dictions
ggplot() +
  geom_line(data = test_data, aes(x = ds, y = y), color = "blue", linewidth = 1, alpha = 0.7, linetype = "dashed") +
  geom_line(data = forecast, aes(x = ds, y = yhat), color = "red", linewidth = 1) +
  geom_ribbon(data = forecast, aes(x = ds, ymin = yhat_lower, ymax = yhat_upper), fill = "red", alpha = 0.2) +
  labs(title = "Pr�dictions de prix d'Adobe vs. R�alit�s du test",
       x = "Date",
       y = "Prix") +
  theme_minimal() +
  theme(legend.position = "none")




#--------------------------------------------- Juste pour test
future <- make_future_dataframe(fit, periods = nrow(test_data), include_history = FALSE)
future$ds <- as.POSIXct(future$ds, tz = "UTC")

# Ajouter les r�gressors dans le futur
future <- future %>%
  mutate(
    sovereign_debt_crisis = as.integer(ds >= as.POSIXct("2010-01-01", tz = "UTC") & ds <= as.POSIXct("2012-12-31", tz = "UTC")),
    oil_shock = as.integer(ds >= as.POSIXct("2014-01-01", tz = "UTC") & ds <= as.POSIXct("2016-12-31", tz = "UTC")),
    trade_war = as.integer(ds >= as.POSIXct("2018-01-01", tz = "UTC") & ds <= as.POSIXct("2019-12-31", tz = "UTC")),
    covid_pandemic = as.integer(ds >= as.POSIXct("2020-01-01", tz = "UTC") & ds <= as.POSIXct("2022-12-31", tz = "UTC")),
    war_ukraine = as.integer(ds >= as.POSIXct("2022-02-24", tz = "UTC")),
    volatility = test_data$volatility,
    squared_volatility = test_data$squared_volatility
  )

# -------------------- Visualisation des pr�visions --------------------
forecast <- predict(fit, future)

# S'assurer que la premi�re date de forecast correspond � la premi�re date de test_data
forecast$ds <- test_data$ds


# Tracer les donn�es r�elles et les pr�dictions
ggplot() +
  geom_line(data = test_data, aes(x = ds, y = y), color = "blue", linewidth = 1, alpha = 0.7, linetype = "dashed") +
  geom_line(data = forecast, aes(x = ds, y = yhat), color = "red", linewidth = 1) +
  geom_ribbon(data = forecast, aes(x = ds, ymin = yhat_lower, ymax = yhat_upper), fill = "red", alpha = 0.2) +
  labs(title = "Pr�dictions de prix d'Adobe vs. R�alit�s du test",
       x = "Date",
       y = "Prix") +
  theme_minimal() +
  theme(legend.position = "none")
