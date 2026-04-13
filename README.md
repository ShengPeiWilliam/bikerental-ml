# Bike Sharing Demand Forecasting (OLS)

Daily bike rental demand forecasting using OLS regression on the UCI Bike Sharing Dataset (731 observations, Washington D.C., 2011–2012). Year and temperature are the strongest predictors. Compares OLS against Ridge and Lasso, with OLS achieving CV RMSE of 1,166 and R² of 0.827, outperforming both regularized models.

## Motivation

Predictive models can achieve strong results, but they often offer little explanation for why. In practice, understanding what drives a prediction matters as much as the prediction itself. This project starts with the simplest approach, a well-specified linear model, to see how far it can go before complexity becomes necessary.

## Design Decisions

**How were features selected?**

The raw dataset contains variables that leak the target (casual + registered = total count). Correlation screening (r = 0.99 between `temp` and `atemp`) and VIF-based removal brought the feature set down to 8 predictors spanning temporal, weather, and calendar dimensions.

**Why compare against Ridge and Lasso?**

To test whether regularization adds value when feature selection is already done carefully upfront. If OLS with well-selected features performs comparably, it suggests that good preprocessing can substitute for algorithmic complexity.

**Why rolling-origin cross-validation instead of standard k-fold?**

Bike rental data has temporal structure. Standard k-fold randomly shuffles observations, which can allow future data to leak into training. Rolling-origin CV preserves the time ordering, always training on past data and validating on future data.

## Key Results

The OLS model achieves an in-sample R² of 0.827. Rolling-origin cross-validation (5 expanding windows) gives a clearer picture of real performance:

| Model | CV RMSE | CV MAE |
|-------|---------|--------|
| **OLS** | **1,166** | **890** |
| Lasso | 1,170 | 893 |
| Ridge | 1,229 | 969 |

## Reflections & Next Steps

On a small, well-understood dataset, a carefully specified OLS model is hard to beat. That said, the model has clear boundaries. The `yr` effect may only reflect a 2011–2012 growth phase, and predictions on extreme weather days are less reliable due to sparse training data.

Next steps:
- **Count regression**: OLS assumes a continuous, normally distributed response, but rental counts are non-negative integers. Poisson or Negative Binomial regression better fits the data's nature. See [bikerental-poisson](https://github.com/ShengPeiWilliam/bikerental-poisson) for a follow-up applying this approach to the same dataset.
- **Temporal structure**: the model treats each day independently. Incorporating lagged demand or autoregressive terms would better reflect how bike usage actually behaves.
- **Interaction effects**: temperature likely behaves differently across seasons. Adding interaction terms could capture these dynamics without abandoning interpretability.

## Repository

- `report/bikerental_report.pdf`: Final report
- `code/bikerental_analysis.ipynb`: Main analysis notebook
- `code/bikerental_analysis.R`: Clean R script version
- `code/config.R`: Configuration file (data paths)

## Tools

R, glmnet, caret, ggplot2, corrplot, car, tidyr

## References

Fanaee-T, H. (2013). Bike Sharing [Dataset]. UCI Machine Learning Repository. doi:10.24432/C5W894