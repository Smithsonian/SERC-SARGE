check_timestamps <- function(data, TIMEZONE, current_time) {
  
  latest_data <- max(data$TIMESTAMP, na.rm = TRUE)
  formatted_date_data <- paste(format(latest_data, "%Y-%m-%d %H:%M:%S"), TIMEZONE)
  data_color <- if (current_time - latest_data > hours(1)) {
    ' style="color: #990000;"'
  } else {""}
  
  return(list(formatted_date_data, data_color))
}
