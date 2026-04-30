# Bike Sharing Demand Forecasting (OLS)

[![Full Report](https://img.shields.io/badge/📄_Read_Full_Report-PDF-blue?style=for-the-badge)](report/bikerental_report.pdf)

Daily bike rental demand forecasting on 731 days of Capital Bikeshare data 
(Washington D.C., 2011–2012), comparing OLS, Ridge, and Lasso under 
rolling-origin cross-validation.

OLS leads the linear models (R² = 0.827, CV RMSE = 1,166), outperforming 
both regularized alternatives. The result reinforces that careful feature 
selection (correlation screening, VIF diagnostics) can substitute for 
algorithmic complexity on small, well-understood datasets, but also motivates 
a follow-up question: is OLS even the right model family for a non-negative 
count response?

## Motivation

Predictive models can achieve strong results, but they often offer little 
explanation for why. In practice, understanding what drives a prediction 
matters as much as the prediction itself. This project starts with the 
simplest approach, a well-specified linear model, to see how far it can 
go before complexity becomes necessary.

## Design Decisions

**How were features selected?**

The raw dataset contains variables that leak the target (casual + registered = 
total count). Correlation screening (r = 0.99 between `temp` and `atemp`) 
and VIF-based removal brought the feature set down to 8 predictors spanning 
temporal, weather, and calendar dimensions.

**Why compare against Ridge and Lasso?**

To test whether regularization adds value when feature selection is already 
done carefully upfront. If OLS with well-selected features performs comparably, 
it suggests that good preprocessing can substitute for algorithmic complexity.

**Why rolling-origin cross-validation instead of standard k-fold?**

Bike rental data has temporal structure. Standard k-fold randomly shuffles 
observations, which can allow future data to leak into training. Rolling-origin 
CV preserves the time ordering, always training on past data and validating 
on future data.

## Key Results

**Headline finding**: OLS leads with R² = 0.827 and CV RMSE = 1,166, with regularization providing limited benefit under careful preprocessing.

| Model | CV RMSE | CV MAE |
|-------|---------|--------|
| **OLS** | **1,166** | **890** |
| Lasso | 1,170 | 893 |
| Ridge | 1,229 | 969 |

## Reflections & Next Steps

On a small, well-understood dataset, a carefully specified OLS model is hard 
to beat. That said, the model has clear boundaries. The `yr` effect may only 
reflect a 2011–2012 growth phase, and predictions on extreme weather days 
are less reliable due to sparse training data.

Next steps:
- **Count regression**: OLS assumes a continuous, normally distributed response, but rental counts are non-negative integers. Poisson or Negative Binomial regression better fits the data's nature. See [bikerental-poisson](https://github.com/ShengPeiWilliam/bikerental-poisson) for a follow-up applying this approach to the same dataset.
- **Temporal structure**: the model treats each day independently. Incorporating lagged demand or autoregressive terms would better reflect how bike usage actually behaves.
- **Interaction effects**: temperature likely behaves differently across seasons. Adding interaction terms could capture these dynamics without abandoning interpretability.

## Repository

```
report/
└── bikerental_report.pdf       # Full analysis writeup
code/
├── bikerental_analysis.ipynb   # Main analysis (R notebook)
├── bikerental_analysis.R       # Clean R script
└── config.R                    # Data path configuration
```

## Tools

**Statistical methods**: OLS, Ridge regression, Lasso regression, Rolling-origin CV, VIF diagnostics  
**Language**: R  
**Libraries**: glmnet, caret, car, tidyr, ggplot2, corrplot

## References

Fanaee-T, H. (2013). [Bike Sharing](https://archive.ics.uci.edu/dataset/275/bike+sharing+dataset) [Dataset]. UCI Machine Learning Repository.