# Time.R <img src="man/Figures/Time.R_logo.png" align="right" width="180px" height="195px" />
R package for estimating and compare time of concentration and lag time of watersheds

# Requirements
Dependencies:
  ggplot2, readxl, utils

# Installation
You can install the currently-released version of **Time.R** from CRAN with this R command:
```
install.packages("Time.R")
```
Alternatively, you can install the development version from GitHub with:
```
# install.packages("remotes")
remotes::install_github("Alobondo/Time.R")
library(Time.R)
```

# Usage
Functions | Description |
--- | --- |
```Time.R_calc()``` | Apply functions to estimate the time of concentration and lag times for watersheds based on their morphometric characteristics. It includes various methods for calculation and offers plotting functionalities for comparative analysis. |


```Time.R_calc()``` works with a dataframe with columns: ID, Area_km2, Slope_perc, BasinLength_km, Z_max_masl, Z_min_masl, Z_ave_masl, CurveNumber, ManningCoeff, Paved (ID character type and Paved logical type, numeric the rest). 

# Reporting bugs
If you find an error in some function, want to report a typo in the documentation or submit a recommendation, you can do it [here](https://github.com/Alobondo/Time.R/issues)

# Keywords
Hydrology, R package, Time of Concentration, Lag Time, Watersheds
