# ============================================================
# Bike Sharing Demand Forecasting
# ============================================================

library(car)
library(caret)
library(glmnet)
library(tidyr)
library(corrplot)
source("config.R")

# ---- Load Data ----
bike.data <- read.csv(DAY_DATA)
str(bike.data)

result.na <- data.frame(
  Total_Observations = nrow(bike.data),
  Missing_Values     = sum(is.na(bike.data))
)
print(result.na, row.names = FALSE)

# ---- Preprocessing ----
preprocess <- function(df) {
  df$instant    <- NULL
  df$dteday     <- NULL
  df$casual     <- NULL
  df$registered <- NULL

  df$season     <- factor(df$season, levels = 1:4,
                          labels = c("Winter", "Spring", "Summer", "Fall"))
  df$yr         <- as.factor(df$yr)
  df$mnth       <- as.factor(df$mnth)
  df$holiday    <- factor(df$holiday,    levels = c(0, 1))
  df$weekday    <- factor(df$weekday,    levels = 0:6)
  df$workingday <- factor(df$workingday, levels = c(0, 1))
  df$weathersit <- as.factor(df$weathersit)

  return(df)
}
bike.data <- preprocess(bike.data)

# ---- Missing Value Check ----
check_missing <- function(df, df.name = "") {
  missing.idx <- which(!complete.cases(df))
  cat(df.name, ": Found", length(missing.idx), "missing rows\n")
  if (length(missing.idx) > 0) print(df[missing.idx, ], row.names = FALSE)
  invisible(missing.idx)
}
check_missing(bike.data, "bike.data")

# ---- Feature Distribution ----
ggplot(bike.data, aes(x = cnt)) +
  geom_histogram(fill = "steelblue", bins = 30) +
  labs(title = "Distribution of Daily Bike Rentals",
       x = "", y = "Frequency")

# ---- Categorical Features ----
ggplot(bike.data, aes(x = season, y = cnt, fill = season)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "Bike Rentals by Season", x = "Season", y = "Count") +
  theme(legend.position = "none")

ggplot(bike.data, aes(x = mnth, y = cnt, fill = mnth)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "Bike Rentals by Month", x = "Month", y = "Count") +
  theme(legend.position = "none")

cat.group2 <- c("weathersit", "holiday", "weekday", "workingday")

df.cat2 <- pivot_longer(
  data = bike.data[, c("cnt", cat.group2)],
  cols = -cnt,
  names_to = "feature",
  values_to = "value",
  values_transform = list(value = as.character)
)

df.cat2$value <- factor(df.cat2$value,
                        levels = as.character(sort(unique(as.numeric(df.cat2$value)))))

ggplot(df.cat2, aes(x = value, y = cnt, fill = value)) +
  geom_boxplot(alpha = 0.7) +
  facet_wrap(~feature, scales = "free_x") +
  labs(title = "Bike Rentals by Weather and Day Type",
       x = "", y = "Count") +
  theme(legend.position = "none")

ggplot(bike.data, aes(x = yr, y = cnt, fill = yr)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "Bike Rentals by Year", x = "Year", y = "Count") +
  theme(legend.position = "none")

# ---- Numeric Features ----
numeric.features <- c("temp", "atemp", "hum", "windspeed")

df.num.long <- pivot_longer(data = bike.data[, c("cnt", numeric.features)],
                            cols = -cnt,
                            names_to = "feature",
                            values_to = "value")

ggplot(df.num.long, aes(x = value, y = cnt)) +
  geom_point(alpha = 0.3, color = "steelblue") +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  facet_wrap(~feature, scales = "free_x") +
  labs(title = "Bike Rentals vs Numeric Features",
       x = "", y = "Count")

# ---- Feature Correlation ----
numeric.features <- c("temp", "atemp", "hum", "windspeed", "cnt")
cor.data <- bike.data[, numeric.features]

corrplot(cor(cor.data, use = "complete.obs"),
    method = "color",
    type = "upper",
    tl.cex = 0.8,
    addCoef.col = "black",
    number.cex = 0.6)

# ---- Multicollinearity Check (VIF) ----
compute_vif <- function(data) {
  lm.proxy <- lm(cnt ~ . - atemp - mnth - workingday, data = data)
  vif.result <- vif(lm.proxy)
  vif.data <- data.frame(
    Feature = rownames(vif.result),
    VIF     = round(vif.result[, 1], 3)
  )
  print(vif.data, row.names = FALSE)
  invisible(vif.data)
}
compute_vif(bike.data)

# ---- OLS Regression ----
ctrl <- trainControl(method = "cv", number = 5)
train_lm <- function(data, ctrl) {
  set.seed(42)
  model <- train(cnt ~ season + yr + weekday + holiday +
                   temp + hum + windspeed + weathersit,
                 data = data,
                 method = "lm",
                 trControl = ctrl)
  return(model)
}
lm.model <- train_lm(bike.data, ctrl)
summary(lm.model$finalModel)

# ---- Residuals vs Fitted ----
fitted.vals    <- fitted(lm.model$finalModel)
residuals.vals <- residuals(lm.model$finalModel)

plot(fitted.vals, residuals.vals,
     main = "Residuals vs Fitted Values",
     xlab = "Fitted Values",
     ylab = "Residuals",
     pch = 16,
     col = "steelblue")
abline(h = 0, col = "red", lty = 2, lwd = 2)

# ---- Normal Q-Q Plot ----
qqnorm(residuals.vals,
       main = "Normal Q-Q Plot",
       pch = 16,
       col = "steelblue")
qqline(residuals.vals, col = "red", lwd = 2)

# ---- Scale-Location ----
residuals.vals         <- residuals(lm.model$finalModel)
standardized.residuals <- residuals.vals / sd(residuals.vals)
fitted.vals            <- fitted(lm.model$finalModel)

plot(fitted.vals, sqrt(abs(standardized.residuals)),
     main = "Scale-Location Plot",
     xlab = "Fitted Values",
     ylab = "√|Standardized Residuals|",
     pch = 16,
     col = "steelblue")
lines(lowess(fitted.vals, sqrt(abs(standardized.residuals))),
      col = "red", lwd = 2)

# ---- Cook's Distance ----
cooks.d <- cooks.distance(lm.model$finalModel)

plot(cooks.d,
     type = "h",
     main = "Cook's Distance Plot",
     xlab = "Observation Index",
     ylab = "Cook's Distance",
     col = "steelblue",
     lwd = 1.5)
abline(h = 4/nrow(bike.data), col = "red", lty = 2)
cat("Influential points:", sum(cooks.d > 4/nrow(bike.data)), "\n")

# ---- Regularisation (Ridge & Lasso) ----
X <- model.matrix(cnt ~ season + yr + weekday + holiday +
                    temp + hum + windspeed + weathersit,
                  data = bike.data)[, -1]
y <- bike.data$cnt

cv.lasso <- cv.glmnet(X, y, alpha = 1, nfolds = 5)
cv.ridge <- cv.glmnet(X, y, alpha = 0, nfolds = 5)

best.lambda.lasso <- cv.lasso$lambda.min
best.lambda.ridge <- cv.ridge$lambda.min

lasso.model <- glmnet(X, y, alpha = 1, lambda = best.lambda.lasso)
ridge.model <- glmnet(X, y, alpha = 0, lambda = best.lambda.ridge)

plot(cv.lasso)
plot(cv.ridge)

cat("Best lambda Lasso:", best.lambda.lasso, "\n")
cat("Best lambda Ridge:", best.lambda.ridge, "\n")

# ---- Model Comparison ----
cat("OLS   - CV RMSE:", min(lm.model$results$RMSE), "\n")
cat("Lasso - CV RMSE:", sqrt(min(cv.lasso$cvm)), "\n")
cat("Ridge - CV RMSE:", sqrt(min(cv.ridge$cvm)), "\n")

ridge.pred <- predict(ridge.model, newx = X)
lasso.pred <- predict(lasso.model, newx = X)

ridge.r2 <- 1 - sum((y - ridge.pred)^2) / sum((y - mean(y))^2)
lasso.r2 <- 1 - sum((y - lasso.pred)^2) / sum((y - mean(y))^2)

cat("OLS   R²:", summary(lm.model$finalModel)$r.squared, "\n")
cat("Ridge R²:", ridge.r2, "\n")
cat("Lasso R²:", lasso.r2, "\n")