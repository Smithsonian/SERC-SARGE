plot_sarge <- function(data, start, end, vars, colors){
  recent <- data %>%
    filter(
      as.Date(TIMESTAMP) >= start,
      as.Date(TIMESTAMP) <= end
    ) %>%
    select(TIMESTAMP, all_of(vars)) %>%
    pivot_longer(vars)
  
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