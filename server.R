# Server logic for the Shiny app
function(input, output, session) {
  # plot section ---------------------------------------------------------------
  output$vepPlot <- renderEcharts4r({

    included_publications_not_1_1 |>
      group_by(nb_variants, nb_consequences) |>
      summarise(test = paste0(`Tool name`, collapse = ",")) |>
      ungroup() |>
      e_charts(nb_variants) |>
      e_scatter(nb_consequences, bind=test, symbol_size = 8)|>
      e_x_axis(name = 'Variant types') |>
      e_y_axis(name = 'Functional impacts') |>
      e_tooltip(
        formatter = htmlwidgets::JS("
      function(params){
        return('<strong>' + params.name +
                '</strong><br />Variants: ' + params.value[0] +
                '<br />Functional impacts: ' + params.value[1])
                }
    ")
      ) |>
      e_legend(show = FALSE)

  })

  output$vepYears <- renderEcharts4r({

    included_publications |>
      e_charts(`Create Date`) |>
      e_scatter(nb_consequences, bind=`Tool name`, symbol_size = 8) |>
      e_line(valores_ajustados) |>
      e_x_axis(name = 'Date of publication in MEDLINE') |>
      e_y_axis(name = 'Number of functional impacts') |>
      e_tooltip(
        formatter = htmlwidgets::JS("
      function(params){
        return('<strong>' + params.name +
                '</strong><br />Date: ' + params.value[0] +
                '<br />Impacts: ' + params.value[1])
                }
    ")
      ) |>
      e_legend(show = FALSE)

  })

  output$topVariantTypes <- renderEcharts4r({

    top_variation_types |>
      arrange(nb_tools) |>
      head(input$sliderTopVariantTypes) |>
      e_charts(variation_type) |>
      e_bar(nb_tools) |>
      e_flip_coords() |>
      e_x_axis(name = 'Tools') |>
      e_tooltip(
        formatter = htmlwidgets::JS("
      function(params){
        return('<strong>' + params.name +
                '</strong><br />Tools: ' + params.value[0])
                }
    ")
      ) |>
      e_legend(show = FALSE) |>
      e_labels(position = "right")
  })

  output$topFunctionalImpacts <- renderEcharts4r({

    top_consequences |>
      arrange(nb_tools) |>
      head(input$sliderTopFunctionalImpacts) |>
      e_charts(consequence) |>
      e_bar(nb_tools) |>
      e_flip_coords() |>
      e_x_axis(name = 'Tools') |>
      e_tooltip(
        formatter = htmlwidgets::JS("
      function(params){
        return('<strong>' + params.name +
                '</strong><br />Tools: ' + params.value[0])
                }
    ")
      ) |>
      e_legend(show = FALSE) |>
      e_labels(position = "right")
  })

  output$dateFirstSupport <- renderPlot({
    included_publications <- data_core
    split_variants <- strsplit(publications_of_interest$variant, ';')
    all_variants <- unlist(split_variants)
    unique_variants <- unique(all_variants)

    variant_types_dt <- data.table::data.table(variant_type = unique_variants, first_support_date = rep(0, length(unique_variants)))

    for (i in 1:variant_types_dt[, .N]) {
      variant_type_i <- variant_types_dt[i, variant_type]
      year_i <- publications_of_interest[stringr::str_detect(variant, variant_type_i), min(year)]
      variant_types_dt[i, first_support_date := year_i]
    }

    first_support_numbers <- variant_types_dt[, .N, first_support_date]

    lm_first_support_date <- stats::lm(N ~ first_support_date, data = first_support_numbers)
    lm_first_support_date_summary <- summary(lm_first_support_date)

    p_value <- lm_first_support_date_summary$coefficients["first_support_date", "Pr(>|t|)"]

    ggplot(first_support_numbers, aes(x = first_support_date, y = N)) +
      geom_point() +
      geom_smooth(method = 'lm') +
      ggplot2::theme_classic() +
      labs(
        title = 'Years of First Support for Different Variant Types',
        x = 'Year',
        y = 'Frequency'
      )

    ggplot(first_support_numbers, aes(x = factor(first_support_date), y = N)) +
      geom_bar(stat = 'identity') +
      ggplot2::theme_classic() +
      labs(
        title = 'Years of First Support for Different Variant Types',
        x = 'Year',
        y = 'Number of variant types supported for the first time'
      ) + ggplot2::annotate("text", x = Inf, y = Inf, label = paste("p-value of linear regression model:", format(p_value, digits = 3)), hjust = 1, vjust = 1, size = 3.5)
  })

  # data wrangling section -----------------------------------------------------
  data$first_author <- sapply(data$Authors, function(x) unlist(strsplit(x, ', '))[1])
  data$Source <- paste(data$first_author, 'et al.', data$'Publication Year')
  data$'Tool name' <- sprintf('<a href="https://pubmed.ncbi.nlm.nih.gov/%s/" target="_blank">%s</a>', data$PMID, data$'Tool name')
  data$Source <- sprintf('<a href="https://pubmed.ncbi.nlm.nih.gov/%s/" target="_blank">%s</a>', data$PMID, data$Source)
  data$`Number of variant types` <- str_count(string = data$`Variant types`, pattern = ";") + 1
  data$`Number of functional impacts` <- str_count(string = data$`Functional impacts`, pattern = ";") + 1
  data$Website <- ifelse(!is.na(data$Website), 
                         sprintf('<a href="%s" target="_blank">%s</a>', data$Website, data$Website),
                         'Online version not available.')
  

  unique_var_types <- unique(unlist(strsplit(as.character(data$`Variant types`), ';')))
  unique_conseq <- unique(unlist(strsplit(as.character(data$`Functional impacts`), ';')))

  # filter UI section ----------------------------------------------------------
  output$filters <- renderUI({
    if(input$filter_type == 'Variant and Impact') {
      tagList(
        selectInput('var_type', 'Choose Variant Type:', choices = c('ALL', unique_var_types), multiple = T),
        selectInput('conseq', 'Choose Functional Impact:', choices = c('ALL', unique_conseq), multiple = T)
      )
    } else if (input$filter_type == 'Maximize coverage') {
      sliderInput(inputId = 'number_of_tools', label = "Select Number of tools", min = 1, max = nrow(data), value = 1, step = 1)
    } else if(input$filter_type == 'Operating System') {
      tagList(
        selectInput('operating_system', 'Choose Operating System:', choices = c('GNU/Linux', 'macOS', 'Windows'), multiple = TRUE),
      )
    } else if(input$filter_type == 'Website') {
      tagList(
        selectInput('website', 'Website', choices = c('With website', 'Without website'), multiple = FALSE),
      )
    }
  })

  # table view section ---------------------------------------------------------
  filtered_tools <- reactive({
    filtered_data <- data

    if(input$filter_type == 'Variant and Impact') {
      if(!is.null(input$var_type) & !("ALL" %in% c(input$var_type))) {
        regext_pattern <- paste(paste0("(?=.*\\b", input$var_type, "\\b)"), collapse = "")
        filtered_data <- filtered_data %>%
          filter(stringr::str_detect(`Variant types`, pattern = regext_pattern))
      }

      if(!is.null(input$conseq) & !("ALL" %in% c(input$conseq))) {
        regext_pattern <- paste(paste0("(?=.*\\b", input$conseq, "\\b)"), collapse = "")
        filtered_data <- filtered_data %>%
          filter(stringr::str_detect(`Functional impacts`, pattern = regext_pattern))
      }
    } else if (input$filter_type == 'Maximize coverage') {
      tool_names <- get_tool_names_for_max_coverage(number_of_tools = input$number_of_tools, data = filtered_data)
      filtered_data <- filtered_data %>%
        filter(`Tool name` %in% tool_names) %>%
        mutate(`Tool name` = factor(`Tool name`, levels = tool_names, ordered = TRUE)) %>%
        arrange(`Tool name`)
    } else if (input$filter_type == 'Operating System' && !is.null(input$operating_system)) {
      # # Assuming 'macOS', 'Windows', and 'GNU/Linux' are columns in 'data' with TRUE/FALSE values
      # os_selected <- input$operating_system
      # if('macOS' %in% os_selected) {
      #   filtered_data <- filtered_data[filtered_data$macOS == TRUE, ]
      # }
      # if('Windows' %in% os_selected) {
      #   filtered_data <- filtered_data[filtered_data$Windows == TRUE, ]
      # }
      # if('GNU/Linux' %in% os_selected) {
      #   filtered_data <- filtered_data[filtered_data$`GNU/Linux` == TRUE, ]
      # }
      for(os in input$operating_system) {
        if(os == 'macOS') {
          filtered_data <- filtered_data[filtered_data$macOS == TRUE, ]
        }
        if(os == 'Windows') {
          filtered_data <- filtered_data[filtered_data$Windows == TRUE, ]
        }
        if(os == 'GNU/Linux') {
          filtered_data <- filtered_data[filtered_data$`GNU/Linux` == TRUE, ]
        }
      }
    } # else if (input$filter_type == 'Website') {
    #  if (input$website == 'With website') {
    #    filtered_data[filtered_data$Website != 'Online version not available.', ]
    #  } 
    #  if (input$website == 'Without website') {
    #    filtered_data[filtered_data$Website == 'Online version not available.', ]
    #  }
    #}
    else if (input$filter_type == 'Website') {
      # Ensure that 'input$website' matches the actual ID of the input in the UI
      if (input$website == 'With website') {
        filtered_data <- filtered_data %>% 
          filter(!is.na(Website) & Website != 'Online version not available.') # Filter out NA and the specific string
      } 
      if (input$website == 'Without website') {
        filtered_data <- filtered_data %>% 
          filter(is.na(Website) | Website == 'Online version not available.') # Include NA and the specific string
      }
    }
    filtered_data <- dplyr::relocate(filtered_data, c('Number of variant types', 'Number of functional impacts'), .before = 'Functional impacts')
  })

  output$table <- DT::renderDT({

    DT::datatable(
      filtered_tools(),
      options = list(
        dom='Bftsp',
        scrollX = TRUE,
        paging = TRUE,
        scrollY = 'auto',
        scroller = TRUE,
        pageLength = 10,
        lengthMenu = list(c(1, 5, 10, 20, 30, 40, 50, 94), c('1', '5', '10', '20', '30', '40', '50', 'all')),
        columnDefs = list(
          list(width = '2px', targets = which(names(filtered_tools()) == 'Tool name')), # Reduce width of 'Tool name'
          list(width = '2px', targets = which(names(filtered_tools()) %in% c('Variation types', 'Source'))),
          list(visible = FALSE, targets = which(names(filtered_tools()) %in% c('Authors', 'Title', 'PubMed ID', 'first_author', 'Journal', 'Year')))
        ),
        #rowCallback = JS(rowCallback),
        colResize = TRUE
      ),
      escape = FALSE
    )
  })

  # Display release date -------------------------------------------------------
  observe({
    release_date <- Sys.Date()
    day_ordinal <- scales::ordinal(lubridate::day(release_date))
    month_name <- lubridate::month(release_date, label = TRUE, abbr = FALSE)
    year_num <- lubridate::year(release_date)
    formatted_date <- paste0(day_ordinal, " ", month_name, " ", year_num)
    shinyjs::html('release_date', paste0(
      tags$b('Version: '), version_vep_finder, tags$br(),
      tags$b('Released on: '), formatted_date
    ))
  })

  # Download handler for filtered data -----------------------------------------
  output$downloadData <- downloadHandler(
    filename = function() {
      Sys.setenv(TZ = 'Europe/Zurich')
      current_time <- format(Sys.time(), '%H%M%S')
      paste('vep_finder_version_', version_vep_finder, '_', Sys.Date(), '_', current_time, '.csv', sep = '')
    },
    content = function(file) {
      filtered_data <- data

      if(input$filter_type == 'Variant and Functional Impact') {
        if(!is.null(input$var_type) & !("ALL" %in% c(input$var_type))) {
          regext_pattern <- paste(input$var_type, collapse = "|", sep = "")
          filtered_data <- filtered_data %>%
            filter(stringr::str_detect(`Variant types`, pattern = regext_pattern))
        }

        if(!is.null(input$conseq) & !("ALL" %in% c(input$conseq))) {
          regext_pattern <- paste(input$conseq, collapse = "|", sep = "")
          filtered_data <- filtered_data %>%
            filter(stringr::str_detect(`Functional impacts`, pattern = regext_pattern))
        }
      } else {
        tool_names <- get_tool_names_for_max_coverage(number_of_tools = input$number_of_tools, data = filtered_data)
        filtered_data <- filtered_data %>%
          filter(`Tool name` %in% tool_names) %>%
          mutate(`Tool name` = factor(`Tool name`, levels = tool_names, ordered = TRUE)) %>%
          arrange(`Tool name`)
      }

      filtered_data <- dplyr::relocate(filtered_data, c('Number of variant types', 'Number of functional impacts'), .before = 'Functional impacts')
      pattern_regex <- "<a[^>]*>([^<]+)</a>"
      filtered_data$`Tool name` <- stringr::str_match(filtered_data$`Tool name`, pattern_regex)[,2]
      filtered_data$Source <- stringr::str_match(filtered_data$Source, pattern_regex)[,2]
      write.csv(filtered_data, file, row.names = FALSE)
    }
  )
    reviews <- data.table::fread('data/search_results_rev.csv')
    reviews[, c('Authors', 'Citation', 'Create Date', 'PMCID', 'NIHMS ID') := NULL]
    reviews[, Title := sprintf('<a href="https://pubmed.ncbi.nlm.nih.gov/%s/" target="_blank">%s</a>', PMID, Title)]
    
    output$table_reviews <- DT::renderDataTable({
      DT::datatable(reviews, escape = FALSE)
    })
    benchmarks <- data.table::fread('data/search_results_ben.csv')
    benchmarks[, c('Authors', 'Citation', 'Create Date', 'PMCID', 'NIHMS ID') := NULL]
    benchmarks[, Title := sprintf('<a href="https://pubmed.ncbi.nlm.nih.gov/%s/" target="_blank">%s</a>', PMID, Title)]
    
    output$table_benchmarks <- DT::renderDataTable({
      DT::datatable(benchmarks, escape = FALSE)
    })
    
    benchmark_ghosh <- readxl::read_excel('data/13059_2017_1353_MOESM1_ESM_Table_S6.xlsx')
    benchmark_ghosh <- data.table::as.data.table(benchmark_ghosh)
    for (col_name in names(benchmark_ghosh)) {
      if (is.numeric(benchmark_ghosh[[col_name]])) {
        benchmark_ghosh[[col_name]] <- round(benchmark_ghosh[[col_name]], 4)
      }
    }
    output$table_benchmark_ghosh <- DT::renderDataTable({
      DT::datatable(benchmark_ghosh)
    })
    
    benchmark_livesey <- readxl::read_excel('data/msb202211474-sup-0006-table ev5_rank.xlsx')
    benchmark_livesey <- data.table::as.data.table(benchmark_livesey)
    benchmark_livesey[, `rank score` := round(`rank score`, 4)]
    output$table_benchmark_livesey <- DT::renderDataTable({
      DT::datatable(benchmark_livesey)
    })
}

