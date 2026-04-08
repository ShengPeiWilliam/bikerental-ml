# Bike Sharing Demand Forecasting

Daily bike rental demand forecasting using OLS regression on the UCI Bike Sharing Dataset (731 observations, Washington D.C., 2011–2012). Compares OLS against Ridge and Lasso to test whether regularization improves predictions when the feature set is already well-specified.

## Motivation

Most forecasting write-ups skip straight to gradient boosting or neural nets. This project goes the other direction: how far can a carefully constructed linear model go? The UCI Bike Sharing Dataset is small and well-documented enough to focus on the statistical fundamentals: feature selection, assumption checking, and honest evaluation, without infrastructure getting in the way.

## Design Decisions

**Why OLS instead of gradient boosting or neural nets?**

The goal was to understand what drives bike rental demand, not just predict it. OLS gives interpretable coefficients with significance tests: you can say "temperature increases demand by X units, controlling for season and weather" in a way that a black-box model can't. Starting simple also makes it easy to tell whether added complexity actually helps.

**Why compare against Ridge and Lasso?**

To test a specific hypothesis: if feature selection is done carefully upfront (removing leakage, aliased variables, and high-VIF predictors), does regularization still add value? The answer turned out to be no. OLS matched or beat both regularized models, suggesting that thoughtful feature engineering can substitute for algorithmic complexity on small, clean datasets.

**How were features selected?**

The raw dataset contains variables that leak the target (casual + registered = total count). Catching this early was critical. Beyond that, correlation screening (r = 0.99 between `temp` and `atemp`) and VIF-based removal brought the feature set down to 8 predictors spanning temporal, weather, and calendar dimensions.

## Key Results

The OLS model achieves an in-sample R² of 0.827. Rolling-origin cross-validation (5 expanding windows) gives a clearer picture of real performance:

| Model | CV RMSE | CV MAE |
|-------|---------|--------|
| **OLS** | **1166** | **890** |
| Lasso | 1170 | 893 |
| Ridge | 1229 | 969 |

Year and temperature are the strongest predictors. Residual diagnostics confirm that linear model assumptions are largely met, with only mild heteroscedasticity at higher fitted values.

## Reflections & Next Steps

The main takeaway: on a small, well-understood dataset, a carefully specified OLS model is hard to beat. Regularization didn't help here because the real work, removing leakage, handling multicollinearity, and selecting meaningful features, was already done before the model saw any data. This reinforced that feature engineering discipline matters more than model complexity at this scale.

That said, the `yr` effect may only reflect a 2011–2012 growth phase, and predictions on extreme weather days are less reliable due to sparse training data.

Next steps:
- **Count regression** — OLS assumes a continuous, normally distributed response, but rental counts are non-negative integers. Poisson or Negative Binomial regression better fits the data's nature. See [bikerental-poisson](https://github.com/ShengPeiWilliam/bikerental-poisson) for a follow-up applying this approach to the same dataset.
- **Temporal structure** — the model treats each day independently. Incorporating lagged demand or autoregressive terms would better reflect how bike usage actually behaves.
- **Interaction effects** — temperature likely behaves differently across seasons. Adding interaction terms could capture these dynamics without abandoning interpretability.

## Repository

- `report/bikerental_report.pdf`: Final report
- `code/bikerental_analysis.ipynb`: Main analysis notebook
- `code/bikerental_analysis.R`: Clean R script version
- `code/config.R`: Configuration file (data paths)

## Tools

R, glmnet, caret, ggplot2, corrplot, car, tidyr

## References

Fanaee-T, H. (2013). Bike Sharing [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5W894
