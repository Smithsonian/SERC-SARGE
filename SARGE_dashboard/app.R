library(shiny)
library(tidyverse)
library(lubridate)
library(plotly)
library(DT)

source("../SARGE_dashboard/R/plot_sarge.R")
source("../SARGE_dashboard/R/check_timestamps.R")
source("../SARGE_dashboard/R/make_tab_ui.R")


# ============================================================
# SETTINGS
# ============================================================

TIMEZONE <- "EST"


# ============================================================
# CONFIGURATION
# ============================================================

tabs <- read_delim(
  "../SARGE_dashboard/config/tab_descriptions.txt",
  show_col_types = FALSE, delim = "\t"
)

variables <- read_csv(
  "../SARGE_dashboard/config/colname_descriptions.csv",
  show_col_types = FALSE
) %>%
  mutate(
    default = as.logical(default)
  ) %>%
  mutate(colname = if_else(is.na(colname), label, colname),
         label = if_else(is.na(label), colname, label))


# ============================================================
# LOAD DATA
# ============================================================

data <- list()

for (i in seq_len(nrow(tabs))) {
  
  tab <- tabs$tab_name[i]
  
  vars <- variables %>%
    filter(tab_name == tab) %>%
    pull(colname)
  
  data[[tab]] <- read_delim(
    tabs$data_link[i],
    delim = ",",
    skip = tabs$skip[i],
    col_names = eval(parse(text = tabs$colname_override[i])),
    show_col_types = FALSE
  ) %>%
    mutate(
      TIMESTAMP = ymd_hms(
        TIMESTAMP,
        tz = TIMEZONE
      ),
      TIMESTAMP = round_date(TIMESTAMP, "minute")
    ) %>%
    select(any_of(c("TIMESTAMP", vars))) %>%
    group_by(TIMESTAMP) %>%
    summarize(
      across(everything(), ~ mean(.x, na.rm = TRUE)),
      .groups = "drop"
    )
}

data_tabs <- lapply(
  tabs$tab_name,
  function(x) make_tab_ui(x, variables = variables)
)


# ============================================================
# DATE RANGE
# ============================================================

all_dates <- map(
  data,
  ~ .x$TIMESTAMP
)

min_date <- as.POSIXct(min(unlist(all_dates), na.rm = TRUE))
max_date <- as.POSIXct(max(unlist(all_dates),na.rm = TRUE))


# ============================================================
# UI
# ============================================================

ui <- fixedPage(
  
  tags$head(
    tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "custom.css"
    ),
    
    tags$script(HTML("
      Shiny.addCustomMessageHandler(
        'hideLoadingOverlay',
        function(message) {
          const overlay =
            document.getElementById('loading-overlay');

          if (overlay) {
            overlay.classList.add('hidden');

            setTimeout(
              () => overlay.remove(),
              600
            );
          }
        }
      );
    "))
  ),
  
  # title
  div(
    class = "quarto-title-banner",
    div(
      class = "banner-content",
      h1(
        class = "title",
        "SARGE Real-Time Data Dashboard"
      )
    )
  ),
  
  # loading
  div(
    id = "loading-overlay",
    div(class = "spinner"),
    p("Loading the latest SARGE data…")
  ),
  
  # dates
  div(
    class = "date-controls",
    fluidRow(
      column(
        width = 3,
        dateInput(
          "start_date",
          "Start date for plots",
          value = as.Date(max_date) - days(3),
          min = as.Date(min_date),
          max = Sys.Date()
        )
      ),
      
      column(
        width = 3,
        dateInput(
          "end_date",
          "End date for plots",
          value = as.Date(max_date),
          min = as.Date(min_date),
          max = Sys.Date()
        )
      )
    )
  ),
  
  # tabs
  do.call(
    tabsetPanel,
    c(
      list(
        id = "main_tabs",
        type = "tabs",
        
        tabPanel(
          title = "Overview",
          fluidRow(
            column(
              width = 8,
              div(
                class = "overview-text",
                br(),
                htmlOutput("today"),
                h3("Latest data"),
                htmlOutput("data_latest")
              )
            ),
            
            column(
              width = 4,
              div(
                class = "overview-images",
                img(
                  src = "images/SARGE_BKGD_SHINY.jpg",
                  alt = "SARGE in the field"
                ),
                img(
                  src = "images/GCW_HighTide.png",
                  alt = "marsh at high tide"
                )
              )
            )
          )
        )
      ),
      
      data_tabs
    )
  )
)


# ============================================================
# SERVER
# ============================================================

server <- function(input, output, session) {
  
  Sys.setenv(TZ = TIMEZONE)
  
  
  # ----------------------------------------------------------
  # DATE INPUTS
  # ----------------------------------------------------------
  
  updateDateInput(
    session,
    "start_date",
    min = as.Date(min_date),
    max = Sys.Date(),
    value = as.Date(max_date) - days(3)
  )
  
  updateDateInput(
    session,
    "end_date",
    min = as.Date(min_date),
    max = Sys.Date(),
    value = as.Date(max_date)
  )
  
  
  # ==========================================================
  # GENERATE PLOTS + TABLES
  # ==========================================================
  
  for (tab in tabs$tab_name) {
    
    local({
      this_tab <- tab
      safe_name <- make.names(this_tab)
      checkbox_id <- paste0("vars_", safe_name)
      plot_id <- paste0("plot_", safe_name)
      table_id <- paste0("table_", safe_name)
      
      
      # ------------------------------------------------------
      # COLORS
      # ------------------------------------------------------
      
      colors <- variables %>%
        filter(tab_name == this_tab) %>%
        select(colname, color) %>%
        deframe()
      
      
      # ------------------------------------------------------
      # PLOT
      # ------------------------------------------------------
      
      output[[plot_id]] <- renderPlotly({
        
        req(input[[checkbox_id]])
        
        p <- plot_sarge(
          data = data[[this_tab]],
          start = input$start_date,
          end = input$end_date,
          vars = input[[checkbox_id]],
          colors = colors
        )
        
        ggplotly(
          p,
          height = 400,
          width = 600,
          tooltip = c(
            "TIMESTAMP",
            "value"
          )
        )
      })
      
      
      # ------------------------------------------------------
      # TABLE
      # ------------------------------------------------------
      
      output[[table_id]] <- DT::renderDataTable({
        data[[this_tab]] %>%
          arrange(desc(TIMESTAMP)) %>%
          mutate(TIMESTAMP = format(TIMESTAMP, "%Y-%m-%d %H:%M"))
      },
      rownames = FALSE,
      class = "display nowrap"
      )
    })
  }
  
  
  # ==========================================================
  # CURRENT TIME
  # ==========================================================
  
  now_txt <- reactiveTimer(1000)
  
  output$today <- renderText({
    
    paste(
      "Current time: ",
      format(now_txt(), "%Y-%m-%d %H:%M:%S"),
      TIMEZONE
    )
  })
  
  
  # ==========================================================
  # LATEST DATA
  # ==========================================================
  
  output$data_latest <- renderText({
    
    current_time <- now_txt()
    
    status <- map(
      data,
      ~ check_timestamps(
        .x,
        TIMEZONE,
        current_time
      )
    )
    
    html <- map2_chr(
      names(status),
      status,
      ~ paste0(
        "<li",
        .y[[2]],
        ">",
        "<b>",
        .x,
        ":</b> ",
        .y[[1]],
        "</li>"
      )
    )
    
    paste0(
      "<ul>",
      paste(html, collapse = ""),
      "</ul>"
    )
  })
  
  
  # ==========================================================
  # HIDE LOADING SCREEN
  # ==========================================================
  
  observe({
    
    req(all(map_lgl(data, ~ nrow(.x) > 0)))
    
    session$sendCustomMessage(
      "hideLoadingOverlay",
      TRUE
    )
  })
}


# ============================================================
# RUN
# ============================================================

shinyApp(
  ui = ui,
  server = server
)