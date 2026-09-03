#' Read in SARGE data
# need to document this more 
sarge_read <- function(files,
                       variables,
                       timezone,
                       resolution = "minute") {
  
  data <- list()
  
  # Start message
  message("Reading SARGE data...")
  message("  Timezone: ", timezone)
  message("  Resolution: ", resolution)
  message("  Files found: ", nrow(files))
  message("")
  
  # Store file information
  file_summary <- data.frame(
    data_type = character(),
    file = character(),
    first_timestamp = as.POSIXct(character()),
    last_timestamp = as.POSIXct(character()),
    stringsAsFactors = FALSE
  )
  
  for (i in seq_len(nrow(files))) {
    
    tab <- files$data_type[i]
    
    # Get variables for this data type
    vars <- variables %>%
      filter(data_type == tab) %>%
      pull(colname)
    
    # Read and process data
    data[[tab]] <- read_delim(
      files$data_link[i],
      delim = ",",
      skip = files$skip[i],
      col_names = eval(parse(text = files$colname_override[i])),
      show_col_types = FALSE
    ) %>%
      mutate(
        TIMESTAMP = ymd_hms(
          TIMESTAMP,
          tz = timezone
        ),
        TIMESTAMP = round_date(TIMESTAMP, resolution)
      ) %>%
      select(any_of(c("TIMESTAMP", vars))) %>%
      group_by(TIMESTAMP) %>%
      summarize(
        across(everything(), ~ mean(.x, na.rm = TRUE)),
        .groups = "drop"
      )
    
    # Get timestamp information
    first_time <- min(data[[tab]]$TIMESTAMP, na.rm = TRUE)
    last_time <- max(data[[tab]]$TIMESTAMP, na.rm = TRUE)
    
    # Store file summary
    file_summary <- rbind(
      file_summary,
      data.frame(
        data_type = tab,
        file = basename(files$data_link[i]),
        first_timestamp = first_time,
        last_timestamp = last_time,
        stringsAsFactors = FALSE
      )
    )
    
    # Message for each file
    message(
      "  ✓ ", tab,
      " | ", basename(files$data_link[i]),
      " | ", first_time,
      " → ", last_time
    )
  }
  
  message("")
  message("SARGE data reading complete.")
  
  # Attach file summary to returned data
  attr(data, "file_summary") <- file_summary
  
  return(data)
}
