## Global variables for R CMD check

# Define global variables to avoid "no visible binding for global variable" notes during R CMD check

utils::globalVariables(c("ID", "method", "time", "type"))
