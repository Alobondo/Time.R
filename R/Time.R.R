
# Time.R Package Functions

#' @title Calculate Time of Concentration and Lag Time
#' @description Estimates time of concentration and lag time for watersheds using various methods.
#' @export
#' @param data A data frame containing watershed morphometric information.
#'   Required columns: watershed ID, area (km2), mean slope (%), basin length (km),
#'   max elevation (masl), min elevation (masl), average elevation (masl),
#'   curve number, manning coefficient, paved (TRUE/FALSE).
#' @param plot_watershed A logical value. If TRUE, plots a comparative ggplot for each watershed.
#' @param plot_formulas A logical value. If TRUE, plots a faceted ggplot to compare each formula for all watersheds.
#' @return A data frame with calculated time of concentration and lag times.
#' @import ggplot2
#' @import readxl
#' @import utils

Time.R_calc <- function(data, plot_watershed = FALSE, plot_formulas = FALSE) {

  # Ensure required columns are present
  required_cols <- c("ID", "Area_km2", "Slope_perc", "BasinLength_km",
                     "Z_max_masl", "Z_min_masl", "Z_ave_masl",
                     "CurveNumber", "ManningCoeff", "Paved")

  if (!all(required_cols %in% colnames(data))) {
    stop(paste("Missing required columns. Please ensure the following columns are present:",
               paste(required_cols, collapse = ", ")))
  }

  results_list <- list()

  for (i in 1:nrow(data)) {

    L <- data$BasinLength_km[i]
    A <- data$Area_km2[i]
    S <- data$Slope_perc[i]
    H <- data$Z_max_masl[i] - data$Z_min_masl[i]
    Hm <- data$Z_ave_masl[i] - data$Z_min_masl[i]
    CN <- data$CurveNumber[i]
    n_man <- data$ManningCoeff[i]
    paved <- data$Paved[i]
    id <- as.character(data$ID[i])

    # tc
    tc_brw <- 0.2426 * (L / ((A^0.1) * (S / 100)^0.2)) # Bransby_Williams
    tc_krp <- 0.4 * 0.0663 * ((L^2) / (S / 100))^0.385 # Kirpich
    tc_krb <- ifelse(L <= 0.1 & A <= 0.04 & S <= 1, 1.4394 / 60 * ((L * 1000) * n_man / (S / 100)^0.5)^0.467, NA) # Kerby
    tc_jhc <- ifelse(A >= 65, 0.0543 * (L / (S / 100))^0.5, NA) # Johnstone_Cross
    tc_clf <- (60 * ((0.87075 * (L)^3) / H)^0.385) / 60 # California
    tc_clk <- 0.335 * (A / (S / 100)^0.5)^0.593 # Clark
    tc_gnd <- (4 * ((A)^0.5) + 1.5 * L) / (0.8 * (Hm)^0.5)
    tc_gnd <- ifelse(L / 3600 >= tc_gnd & tc_gnd >= (L / 3600 + 1.5), tc_gnd, NA) # Giandotti
    tc_psn <- ifelse(0.04 <= L / (A^0.5) & L / (A^0.5) <= 0.13, abs(0.108 * ((A * L)^(1 / 3))) / ((S / 100)^0.5), NA) # Passini
    tc_tmz <- 0.3 * (L / ((S / 100)^0.25))^0.76 # Temez
    tc_prz <- L / (72 * ((H / L)^0.6)) # Perez
    tc_plg <- 0.76 * ((A)^0.38) # Pilgrim
    tc_usb <- ifelse(A >= 1, 2 - 0.5 * log10(A), 2) * ((0.87 * L^2) / (1000 * (S / 100)))^0.385 # USBR
    tc_val <- 1.7694 * ((A)^0.325) * ((L)^-0.096) * ((S)^-0.290) # Valencia Zuluaga
    tc_vnt <- ifelse(0.04 <= L / (A^0.5) & L / (A^0.5) <= 0.14, L / (A^0.5) * ((A^0.5) / S), NA) # Ventura Heras
    tc_scs <- (3.42 * L^0.8 * ((1000 / CN) - 9)^0.7 / S^0.5) / 60 # SCS
    Vmed <- ifelse(paved == F, 16.1345 * sqrt(S / 100), 20.3282 * sqrt(S / 100)) # Average velocity (USDA - Urban Hydrology for Small Watersheds - PAG 163 (1986))
    tc_USNavy <- 1 / 3.6 * L / (Vmed * 0.3048) # US Navy

    # tl
    tl_ner <- 2.8 * (L / (S / 100 * 1000)^0.5)^0.47 # NERC (re-using NERC for consistency with original script)
    tl_mim <- 0.43 * A^0.418 # Mimikou
    tl_wc <- 0.000326 * (1000 * L / (S / 100)^0.5)^0.79 # Watt-Chow
    tl_haz <- 0.2685 * L^0.841 # Haktanir-Sezen
    tl_scs <- tc_scs * 0.6 # SCS (re-using SCS from tc_scs)

    tab_tc <- data.frame(type = 'Tc',
                         method = c('Bransby_Williams', 'Kirpich', 'Kerby', 'Johnstone_Cross',
                                    'California', 'Clark', 'Giandotti', 'Passini',
                                    'Temez', 'Perez', 'Pilgrim', 'USBR',
                                    'Valencia_Zuluaga', 'Ventura_Heras', 'SCS', 'USNavy'),
                         time = round(c(tc_brw, tc_krp, tc_krb, tc_jhc, tc_clf, tc_clk, tc_gnd,
                                        tc_psn, tc_tmz, tc_prz, tc_plg, tc_usb, tc_val, tc_vnt,
                                        tc_scs, tc_USNavy), 6))

    tab_tl <- data.frame(type = 'Tl',
                         method = c('NERC', 'Mimikou', 'Watt-Chow', 'Haktanir-Sezen', 'SCS'),
                         time = round(c(tl_ner, tl_mim, tl_wc, tl_haz, tl_scs), 6))

    results_list[[i]] <- cbind(data.frame(ID = id), rbind(tab_tc, tab_tl))
  }

  all_results <- do.call(rbind, results_list)

  if (plot_watershed) {
    # Plot 1: Comparative ggplot for each watershed
    for (watershed_id in unique(all_results$ID)) {
      watershed_data <- subset(all_results, ID == watershed_id)
      p1 <- ggplot(watershed_data, aes(x = method, y = time, fill = type)) +
        geom_bar(stat = "identity", position = "dodge",
                 colour = "black", linewidth = 0.05) +
        labs(title = paste("Time of Concentration and Lag Time for Watershed:", watershed_id),
             x = "Method/Formula", y = "Time (hours)") +
        theme_bw() +
        theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
        labs(caption = "Note: Some formulas may not be applicable for certain watersheds, resulting in NA values. \
        Tc: Time of Concentration, Tl: Lag Time")
      print(p1)
    }
  }

  if (plot_formulas) {
    # Plot 2: Faceted ggplot comparing each formula for all watersheds
    # Adjust x-axis text size based on the number of watersheds
    aux <- if(nrow(data) >= 30)   3.5 else 6
    p2 <- ggplot(all_results, aes(x = ID, y = time, fill = type)) +
      geom_bar(stat = "identity", position = "dodge",
               colour = "black", linewidth = 0.05) +
      facet_wrap(~ method, scales = "free_y") +
      labs(title = "Comparison of Formulas Across Watersheds",
           x = "Watershed ID", y = "Time (hours)") +
      theme_bw() +
      # x-values interleaved, on above and one bellow, to avoid overlapping the IDs
      theme(axis.text.x = element_text(angle = 90, vjust = 0, size = aux)) +
      labs(caption = "Note: Some formulas may not be applicable for certain watersheds, resulting in NA values. \
        Tc: Time of Concentration, Tl: Lag Time")

    print(p2)
  }

  return(all_results)
}

