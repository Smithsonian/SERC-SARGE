#' Plot SARGE data
#'
#' @param data dataset to plot
#' @param start start date for plot
#' @param end end date for plot
#' @param vars variable names to plot
#' @param colors named vector of colors for each variable
#'
#' @returns Plot of SARGE data
#' @export
#'
#' @examples
plot_sarge <- function(data, data_type, start, end, variables){
  
  # Get data for selected data type
  dat <- data[[data_type]]
  
  # Get default variables and colors
  var_info <- variables %>%
    filter(
      data_type == !!data_type,
      default == TRUE
    )
  
  vars <- var_info$colname
  
  colors <- setNames(
    var_info$color,
    var_info$colname
  )
  
  # Isolate the time period and variables we want to plot
  recent <- dat %>%
    filter(
      as.Date(TIMESTAMP) >= start,
      as.Date(TIMESTAMP) <= end
    ) %>%
    select(TIMESTAMP, all_of(vars)) %>%
    pivot_longer(
      cols = -TIMESTAMP,
      names_to = "name",
      values_to = "value"
    )
  
  # Generate plot
  p1 <- recent %>%
    ggplot(aes(x = TIMESTAMP, y = value, color = name)) +
    geom_point(size = 0.3) +
    theme_classic() +
    scale_color_manual(values = colors) +
    facet_wrap(~name, scales = "free_y") +
    theme(
      axis.title.x = element_blank(),
      legend.position = "none"
    )
  
  return(p1)
}