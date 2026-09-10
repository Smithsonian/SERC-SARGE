# ============================================================
# UI HELPERS
# ============================================================

make_tab_ui <- function(tab_name, variables) {
  
  tab_vars <- variables %>%
    filter(tab_name == !!tab_name)
  
  # ID needs to be unique and safe for Shiny
  tab_id <- paste0(
    "tab_",
    make.names(tab_name)
  )
  
  checkbox_id <- paste0(
    "vars_",
    make.names(tab_name)
  )
  
  plot_id <- paste0(
    "plot_",
    make.names(tab_name)
  )
  
  table_id <- paste0(
    "table_",
    make.names(tab_name)
  )
  
  checkbox_choices <- setNames(
    tab_vars$colname,
    tab_vars$label
  )
  
  selected <- tab_vars %>%
    filter(default) %>%
    pull(colname)
  
  tabPanel(
    title = tab_name,
    
    sidebarLayout(
      
      sidebarPanel(
        
        checkboxGroupInput(
          checkbox_id,
          h4("Variables to plot"),
          choices = checkbox_choices,
          selected = selected
        ),
        
        width = 3
      ),
      
      mainPanel(
        
        plotlyOutput(
          plot_id,
          height = "400px"
        ),
        
        br(),
        
        h3(
          paste(
            "Table of all",
            tolower(tab_name),
            "data"
          )
        ),
        
        div(
          DTOutput(table_id),
          style = "font-size:80%;"
        ),
        
        width = 9
      )
    )
  )
}