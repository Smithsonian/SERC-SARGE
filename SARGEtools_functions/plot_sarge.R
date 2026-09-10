#' Plot sarge data
#'
#' @param data data to plot
#' @param start start date
#' @param end end date
#' @param vars variables to plot
#' @param colors colors to use
#'
#' @returns ggplot of sarge data
#' @export
#'
plot_sarge <- function(data, start, end, vars, colors){
  # Isolate the time period and variables we want to plot
  recent <- data %>%
    filter(
      as.Date(TIMESTAMP) >= start,
      as.Date(TIMESTAMP) <= end
    ) %>%
    select(TIMESTAMP, all_of(vars)) %>%
    pivot_longer(vars)
  
  # Generate Plot
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
}