get_data_chart_topVariantTypes <- function(data_core){
  included_publications <- data_core

  split_variants <- strsplit(included_publications$`Variant types`, ';')
  all_variants <- unlist(split_variants)
  unique_variants <- unique(all_variants)

  variation_types_accepted <- sort(unique_variants[unique_variants %in% unique_variants])

  result_table_variants <- data.table::data.table(matrix(ncol = length(variation_types_accepted), nrow = nrow(included_publications)))

  data.table::setnames(result_table_variants, variation_types_accepted)

  # Iterate through the rows of included_publications and fill in result_table_variants
  for (i in 1:nrow(included_publications)) {
    variants_in_publication <- unlist(strsplit(included_publications$`Variant types`[i], ';'))
    result_table_variants[i, (variants_in_publication) := 1]
  }

  # Fill NA values with FALSE, as they indicate that the publication doesn't cover the variant
  result_table_variants[is.na(result_table_variants)] <- 0
  result_table_variants[, pub := 1:nrow(included_publications)]

  col_sums <- result_table_variants[, lapply(.SD, sum), .SDcols = !'pub']

  melted_col_sums <- data.table::melt(col_sums, variable.name = 'variation_type', value.name = 'nb_tools')
  data.table::setorder(melted_col_sums, -nb_tools)
  n_max_variation_types <- 10
  top_variation_types <- melted_col_sums[1:n_max_variation_types]
  top_variation_types[variation_type == 'non_protein_coding_variant', variation_type := 'non-protein-coding\nvariant']
  top_variation_types[variation_type == 'nonsynonymous_variant', variation_type := 'non-synonymous\nvariant']
  top_variation_types[, variation_type := stringr::str_replace_all(variation_type, '_', '\n')]
  top_variation_types[variation_type == 'copy\nnumber\nvariation', variation_type := 'copy number\nvariation']
  top_variation_types[variation_type == 'splice\nsite\nvariant', variation_type := 'splice site\nvariant']
  top_variation_types[variation_type == 'structural\nvariant', variation_type := 'SV']

  split_consequences <- strsplit(included_publications$`Functional impacts`, ';')
  all_consequences <- unlist(split_consequences)
  unique_consequences <- sort(unique(all_consequences))

  # Create a new data.table with the same number of rows as included_publications
  result_table_consequences <- data.table::data.table(matrix(ncol = length(unique_consequences), nrow = nrow(included_publications)))

  # Name the columns based on the unique consequences
  data.table::setnames(result_table_consequences, unique_consequences)

  # Iterate through the rows of included_publications and fill in result_table_consequences
  for (i in 1:nrow(included_publications)) {
    consequences_in_publication <- unique(unlist(strsplit(included_publications$`Functional impacts`[i], ';')))
    result_table_consequences[i, (consequences_in_publication) := 1]
  }

  # Fill NA values with FALSE, as they indicate that the publication doesn't cover the variant
  result_table_consequences[is.na(result_table_consequences)] <- 0
  result_table_consequences[, pub := 1:nrow(included_publications)]

  col_sums <- result_table_consequences[, lapply(.SD, sum), .SDcols = !'pub']
  sum(col_sums == 1)

  melted_col_sums <- data.table::melt(col_sums, variable.name = 'consequence', value.name = 'nb_tools')
  data.table::setorder(melted_col_sums, -nb_tools)
  n_max_consequences <- 10
  top_consequences <- melted_col_sums[1:n_max_consequences]

  top_consequences[consequence == 'association of DNA variation to pathogenicity', consequence := 'pathogenicity']
  top_consequences[consequence == '3_prime_UTR_variant', consequence := "3′ UTR\nvariant"]
  top_consequences[consequence == '5_prime_UTR_variant', consequence := "5′ UTR\nvariant"]
  top_consequences[, consequence := stringr::str_replace_all(consequence, '_', '\n')]

  return(top_variation_types)
}


get_data_chart_vepPlot <- function(data_core){

  included_publications <- data.table::as.data.table(data_core)

  included_publications[, c('nb_variants', 'nb_consequences') := .(
    lengths(stringr::str_split(`Variant types`, ';')),
    lengths(stringr::str_split(`Functional impacts`, ';'))
  )]

  included_publications_not_1_1 <- included_publications[!(nb_variants == 1 & nb_consequences == 1)]

  return(included_publications_not_1_1)
}


get_data_chart_vepYears <- function(data_core){

  included_publications <- data.table::as.data.table(data_core)

  for (i in 1:included_publications[, .N]) {
    included_publications[i, nb_variants :=  included_publications[i, stringr::str_split(`Variant types`, ';')][, .N]]
    included_publications[i, nb_consequences := included_publications[i, stringr::str_split(`Functional impacts`, ';')][, .N]]
  }

  included_publications$`Create Date` <- lubridate::dmy(included_publications$`Create Date`)

  year_range <- range(lubridate::year(included_publications$`Create Date`), na.rm = TRUE)

  lm_fit <- stats::lm(nb_consequences ~ `Create Date`, data = included_publications)
  # summary(lm_fit)
  # df <- 92
  # t_critical <- qt(1 - (0.05 / 2), df)
  # estimate <- -0.0011783
  # std_error <- 0.0009991
  # lower_bound <- estimate - (t_critical * std_error)
  # upper_bound <- estimate + (t_critical * std_error)
  # print(paste("The 95% confidence interval for the slope is [", lower_bound, ", ", upper_bound, "]"))

  included_publications <- included_publications %>% mutate(valores_ajustados = lm_fit$fitted.values)
  return(included_publications)
}


get_data_topFunctionalImpacts <- function(data_core){
  included_publications <- data.table::as.data.table(data_core)

  split_variants <- strsplit(included_publications$`Variant types`, ';')
  all_variants <- unlist(split_variants)
  unique_variants <- unique(all_variants)

  variation_types_accepted <- sort(unique_variants[unique_variants %in% unique_variants])

  result_table_variants <- data.table::data.table(matrix(ncol = length(variation_types_accepted), nrow = nrow(included_publications)))

  data.table::setnames(result_table_variants, variation_types_accepted)

  # Iterate through the rows of included_publications and fill in result_table_variants
  for (i in 1:nrow(included_publications)) {
    variants_in_publication <- unlist(strsplit(included_publications$`Variant types`[i], ';'))
    result_table_variants[i, (variants_in_publication) := 1]
  }

  # Fill NA values with FALSE, as they indicate that the publication doesn't cover the variant
  result_table_variants[is.na(result_table_variants)] <- 0
  result_table_variants[, pub := 1:nrow(included_publications)]

  col_sums <- result_table_variants[, lapply(.SD, sum), .SDcols = !'pub']

  melted_col_sums <- data.table::melt(col_sums, variable.name = 'variation_type', value.name = 'nb_tools')
  data.table::setorder(melted_col_sums, -nb_tools)
  n_max_variation_types <- 10
  top_variation_types <- melted_col_sums[1:n_max_variation_types]
  top_variation_types[variation_type == 'non_protein_coding_variant', variation_type := 'non-protein-coding\nvariant']
  top_variation_types[variation_type == 'nonsynonymous_variant', variation_type := 'non-synonymous\nvariant']
  top_variation_types[, variation_type := stringr::str_replace_all(variation_type, '_', '\n')]
  top_variation_types[variation_type == 'copy\nnumber\nvariation', variation_type := 'copy number\nvariation']
  top_variation_types[variation_type == 'splice\nsite\nvariant', variation_type := 'splice site\nvariant']
  top_variation_types[variation_type == 'structural\nvariant', variation_type := 'SV']

  split_consequences <- strsplit(included_publications$`Functional impacts`, ';')
  all_consequences <- unlist(split_consequences)
  unique_consequences <- sort(unique(all_consequences))

  # Create a new data.table with the same number of rows as included_publications
  result_table_consequences <- data.table::data.table(matrix(ncol = length(unique_consequences), nrow = nrow(included_publications)))

  # Name the columns based on the unique consequences
  data.table::setnames(result_table_consequences, unique_consequences)

  # Iterate through the rows of included_publications and fill in result_table_consequences
  for (i in 1:nrow(included_publications)) {
    consequences_in_publication <- unique(unlist(strsplit(included_publications$`Functional impacts`[i], ';')))
    result_table_consequences[i, (consequences_in_publication) := 1]
  }

  # Fill NA values with FALSE, as they indicate that the publication doesn't cover the variant
  result_table_consequences[is.na(result_table_consequences)] <- 0
  result_table_consequences[, pub := 1:nrow(included_publications)]

  col_sums <- result_table_consequences[, lapply(.SD, sum), .SDcols = !'pub']
  sum(col_sums == 1)

  melted_col_sums <- data.table::melt(col_sums, variable.name = 'consequence', value.name = 'nb_tools')
  data.table::setorder(melted_col_sums, -nb_tools)
  n_max_consequences <- 10
  top_consequences <- melted_col_sums[1:n_max_consequences]

  top_consequences[consequence == 'association of DNA variation to pathogenicity', consequence := 'pathogenicity']
  top_consequences[consequence == '3_prime_UTR_variant', consequence := "3′ UTR\nvariant"]
  top_consequences[consequence == '5_prime_UTR_variant', consequence := "5′ UTR\nvariant"]
  top_consequences[, consequence := stringr::str_replace_all(consequence, '_', '\n')]

  return(top_consequences)
}

 get_tool_names_for_max_coverage <- function(number_of_tools, data) {
   selected_tool <- as.character()

   data_separated <- data %>%
     select(PMID, `Tool name`, `Functional impacts`) %>%
     tidyr::separate_rows(`Functional impacts`, sep = ";")

   for(i in 1:number_of_tools) {
     data_count <- data_separated %>%
       count(`Tool name`) %>%
       arrange(desc(n))
     selected_tool <- append(selected_tool, data_count$`Tool name`[1])

     impacts_to_remove <- unique(data_separated$`Functional impacts`[data_separated$`Tool name` == selected_tool[i]])

     data_separated <- data_separated %>%
       filter(!(`Functional impacts` %in% impacts_to_remove))
   }

   return(selected_tool)
 }
