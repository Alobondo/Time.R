# TimeR
R package for estimating and compare time of concentration and lag time of watersheds

# Requirements
Dependencies:
  ggplot2,readxl,utils

# Installation
You can install the currently-released version of **TimeR** from CRAN with this R command:
```
install.packages("TimeR")
```
Alternatively, you can install the development version from GitHub with:
```
# install.packages("remotes")
remotes::install_github("Alobondo/TimeR")
library(TimeR)
```

# Usage
Functions | Description |
--- | --- |
```TimeR_calc()``` | Apply functions to estimate the time of concentration and lag times for watersheds based on their morphometric characteristics. It includes various methods for calculation and offers plotting functionalities for comparative analysis. |


```TimeR_calc()``` works with a dataframe with columns: ID, Area_km2, Slope_perc, BasinLength_km, Z_max_masl, Z_min_masl, Z_ave_masl, CurveNumber, ManningCoeff, Paved (ID character type and Paved logical type, numeric the rest). 

# Reporting bugs
If you find an error in some function, want to report a typo in the documentation or submit a recommendation, you can do it [here](https://github.com/Alobondo/TimeR/issues)

# Keywords
Hydrology, R package, Time of Concentration, Lag Time, Watersheds
