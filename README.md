# Bike Sharing Demand Forecasting
Daily bike rental demand forecasting using the UCI Bike Sharing Dataset (731 observations, 2011–2012). Applies Ordinary Least Squares regression as the primary model with careful feature selection, multicollinearity diagnostics, and residual assumption checks. Compares OLS against Ridge and Lasso regression to evaluate whether regularisation offers predictive gains under a well-specified feature set.

## Key Techniques
- Feature removal: target leakage detection, correlation screening ($r = 0.99$), aliased variable identification
- Multicollinearity assessment via VIF
- OLS coefficient analysis with t-statistics and significance testing
- Regularisation comparison: Ridge (L2) and Lasso (L1) with lambda tuned by cross-validation
- Residual diagnostics: Residuals vs Fitted, Q-Q plot, Scale-Location, Cook's Distance
- 5-fold cross-validation with caret and glmnet

## Tools
R &bull; caret &bull; glmnet &bull; ggplot2 &bull; corrplot &bull; car &bull; tidyr

## Repository
- `report/bikerental_report.tex` &mdash; LaTeX source file
- `report/bikerental_report.pdf` &mdash; Final report
- `code/bikerental_analysis.ipynb` &mdash; Main analysis notebook
- `code/bikerental_analysis.R` &mdash; Clean R script version of the analysis  
- `code/config.R` &mdash; Configuration file (data paths)

## References

Fanaee-T, H. (2013). Bike Sharing [Dataset]. UCI Machine Learning Repository.
https://doi.org/10.24432/C5W894