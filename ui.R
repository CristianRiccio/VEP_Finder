fluidPage(
  shinyjs::useShinyjs(),
  tags$head(
    tags$style(
      HTML('
      .header {
        text-align: center;
        background-color: #f1f1f1;
        padding: 20px;
      }

      .logo-left {
        width: 100%;  /* Make the logo width responsive */
        max-width: 200px;  /* Maximum size of the logo */
        height: auto;  /* Maintain aspect ratio */
      }

      /* Media query for screens smaller than 768px wide */
      @media only screen and (max-width: 768px) {
        .logo-left {
          max-width: 150px;  /* Smaller size for smaller screens */
        }
      }

     .thick-hr {
       border-top: 1px solid #D3D3D3;  
     }
     .footer {
       position: relative; 
       bottom: 0;
       left: 0;
       width: 100%;
       background-color: #FFFFFF;
       text-align: left;
       padding: 10px;
       font-size: small;
       overflow: auto;
     }
     .table {
       width: 70% !important;
       margin: auto;
     }
     .dataTables_wrapper {
        max-width: 90%;
        margin-right: auto !important;
     }
     .navbar-nav > li > a {
        color: black !important;
        font-weight: bold;
        font-size: 33;
     }
      ')
#       HTML('
#       .header {
#         text-align: center;
#         background-color: #f1f1f1;
#         padding: 20px;
#       }
# 
#       .logo-left {
#         width: 10%;  /* Take full width */
#         height: 100px;  /* But not more than 200px */
#       }
# 
#       /* Media query for screens smaller than 768px wide */
#       @media only screen and (max-width: 768px) {
#         .logo-left {
#           max-width: 150px;  /* Smaller size */
#        }
#       }
# 
#      .thick-hr {
#        border-top: 1px solid #D3D3D3;  /* Change 3px to make it as thick as you like and use the color you prefer */
#      }
#      .footer {
#        position: relative; /* Changed from absolute */
#        bottom: 0;
#        left: 0;
#        width: 100%;
#        background-color: #FFFFFF;
#        text-align: left;
#        padding: 10px;
#        font-size: small;
#        overflow: auto; /* Added this to handle overflowing content */
#      }
#      .table {
#        width: 70% !important;
#        margin: auto;
#      }
#      .dataTables_wrapper {
#         max-width: 90%;
#         margin-right: auto !important;
#      }
#      .navbar-nav > li > a {
#         color: black !important;
#         font-weight: bold;
#         font-size: 33; /* Change to desired font size */
#      }
#       ')
    )
  ),
  tags$div(
    class = 'header',
    tags$img(class = 'logo-left', src = 'logo_vep_finder.jpg')
  ),
  navbarPage(
    title = '',
    tabPanel('VEP Finder',
             titlePanel(''),
             sidebarLayout(
               sidebarPanel(
                 div( # This div wraps the two sidebarPanels
                   radioGroupButtons(
                     inputId = 'filter_type',
                     label = 'Filter By:',
                     choices = c('Variant and Impact', 'Maximize coverage', 'Operating System', 'Website'),
                     justified = TRUE,
                     checkIcon = list(yes = icon("ok", lib = "glyphicon"))
                   ),
                   uiOutput('filters'),
                   downloadButton('downloadData', 'Download'),
                   tags$div(
                     id = 'release_date',  # New ID for the release date
                     tags$hr(),
                     tags$b('Version: '),
                     version_vep_finder,
                     tags$br(),
                     tags$b('Released on: ')
                     # Date will be inserted here by the server
                   ),
                 ),
                 width = 4
               ),
               mainPanel(
                 DTOutput('table'),
                 width = 8
               )
             )
    ),
    tabPanel('Documentation',
             h2('Documentation'),
             h3('What does VEP Finder stand for?'),
             p('VEP Finder stands for Variant Effect Predictor Finder.'),
             h3('Aim of VEP Finder:'),
             p('VEP Finder aims to facilitate the search for appropriate databases and tools based on your specific needs for variant types (e.g. SNV, CNV, SV) and functional impacts (pathogenicity, misense variant, regulatory variant). The website features a table, comprising the included databases and tools, along with the particular variant types and functional impacts they cover. Users can efficiently query this table using Sequence Ontology (SO) terms relevant to both variant types and functional impacts. Upon executing a query, the website displays only those tools and databases that correspond to the queried terms.'),
             h3('How to use VEP Finder?'),
             h4('Filter VEP Finder using Sequence Ontology terms.'),
             p("1. Select the 'Variant Type' from the dropdown menu. Sequence Ontology terms are used whenever possible."),
             p("2. Select the 'Functional Impact' from the dropdown menu. Sequence Ontology terms are used whenever possible."),
             p("3. Click 'Download' to download the list of tools meeting the criteria for Variant Type and Functional Impact."),
             p('The underlying CSV table contains columns for Variant Types, Functional Impacts, and other metadata.'),
             tags$ul(
               
               tags$li('PMID: Unique identifier for the research paper in the PubMed database.'),
               tags$li('Tool name: Name of the computational tool or database discussed in the paper.'),
               tags$li('Variant types: Types of genetic variants, such as SNV, deletion, insertion.'),
               tags$li('Number of variant types: number of variant types accepted by the VEP.'),
               tags$li('Number of functional impacts: number of functional impacts output by the VEP.'),
               tags$li('Functional Impacts: List of functional impacts predicted by the VEP.'),
               tags$li('Website: link to the website where the VEP can be used.'),
               tags$li('GNU/Linux: can the tool be used on a GNU/Linux operating system?.'),
               tags$li('macOS: can the tool be used on a macOS operating system?.'),
               tags$li('Windows: can the tool be used on a Windows operating system?.'),
               tags$li('Note: Personal note on the VEP.'),
               tags$li('Title: Title of the research paper.'),
               tags$li('Authors: List of authors of the research paper.'),
               tags$li('Citation: citation of the publication.'),
               tags$li('First author: first author of the publication.'),
               tags$li('Journal/Book: Journal where the paper is published.'),
               tags$li('Publication Year: Year of publication.'),
               tags$li('Create Date: Date of creation of the PubMed entry.'),
               tags$li('PMCID: PubMed Central ID.'),
               tags$li('NIHMS ID: NIH Manuscript Submission Identifier.'),
               tags$li('DOI: Digital Object Identifier.')
             ),
             h4('Maximize coverage.'),
             p("This option lets you input a number of tools that you would like to use. VEP Finder then displays a list of VEPs that maximize the number of predicted functional impacts."),
             h4('Website'),
             p('For VEPs that can be used interactively online, the column "Website" contains the URL of the website where the tool can be used.'),
             h4('Operating system'),
             p("The table indicates whether the tool can be installed on the three major operating systems: GNU/Linux, macOS, Windows. Some tools are clear with regard to their OS requirements, while others less so. Please, always carefully check if your tool of interest is available on your operating system."),
             h4('"works on a personal computer"'),
             p("This column specifies whether the VEP can be used on a personal computer, as opposed to a high-performance computer (HPC). This column serves users with no access to an HPC to exclude VEPs that require one, such as SparkINFERNO."),
    ),
    tabPanel('Explore VEPs',
             h2('Explore VEPs'),
             h3('Number of variant types and functional impacts of VEPs'),
             # plotOutput('vepPlot'),
             echarts4rOutput("vepPlot"),
             h3('Year of publication and number of functional impacts of VEPs'),
             # plotOutput('vepYears'),
             echarts4rOutput("vepYears"),
             h3('Top variant types'),
             fluidRow(
               column(width = 12, align = "center",

                      sliderInput("sliderTopVariantTypes", "Choose top",
                                  min = 1,
                                  max = nrow(top_variation_types),
                                  value = nrow(top_variation_types),
                                  step = 1
                      )
               ),
               column(width = 12,
                      # plotOutput('topVariantTypes'),
                      echarts4rOutput("topVariantTypes"),
               )
             ),
             h3('Top functional impacts'),
             fluidRow(
               column(width = 12, align = "center",
                      sliderInput("sliderTopFunctionalImpacts", "Choose top",
                                  min = 1,
                                  max = 10,
                                  value = 10,
                                  step = 1
                      )
               ),
               column(width = 12,
                      # plotOutput('topFunctionalImpacts'),
                      echarts4rOutput('topFunctionalImpacts'),
               )
             ),

             #h3('Date of first support for each variant type'),
             # plotOutput('dateFirstSupport')
    ),
    tabPanel('Release Notes',
             h2('Release Notes'),
             p('VEP Finder is being kept up to date thanks to our regular reading of the literature on VEPs and our work in the field of genomics. Updates will be carried out on a need basis. We also welcome updates from users of VEPs. Send us an email at ', tags$a(href = 'mailto:info@cardio-care.ch', 'info@cardio-care.ch'), ' containing the entry to be updated along with links to the evidence supporting the update.'),
             h4('Version 1.0.15 - 13th May 2024'),
             tags$ul(
               tags$li('VEP Finder has been published in the journal "Human Genetics". We therefore updated the "Citation" tab.'),
             ),
             h4('Version 1.0.14 - 16th February 2024'),
             tags$ul(
               tags$li('Added documentation on how to interpret the columns on website, operating system and computational requirements.'),
             ),
             h4('Version 1.0.13 - 14th February 2024'),
             tags$ul(
               tags$li('For the tool RSAT, the column "Website" showed "FALSE". To make it consistent with other tools, "FALSE" was changed to "Online version not available.'),
             ),
             h4('Version 1.0.12 - 14th February 2024'),
             tags$ul(
               tags$li('The name of the tool "MoBiDic" was corrected to "MoBiDic Prioritization Algorithm (MPA)". Read the abstract of the associated publication for the evidence supporting this correction.'),
             ),
             h4('Version 1.0.11 - 7th February 2024'),
             tags$ul(
               tags$li('Users can now filter VEPs by supported operating system and the availability of an online version of the tool.'),
             ),
             h4('Version 1.0.10 - 7th February 2024'),
             tags$ul(
               tags$li('Added links to websites for VEPs that can be used online.'),
               tags$li('Added operating system requirements for all the tools.'),
               tags$li('Added if tool can be used on a personal computer, as opposed to a high-performance computer.'),
             ),
             h4('Version 1.0.9 - 1st February 2024'),
             tags$ul(
               tags$li('Added a benchmarking table from Livesey et al. (2023) displaying the rank of 55 tools.'),
             ),
             h4('Version 1.0.8 - 31st January 2024'),
             tags$ul(
               tags$li('Added a bibliography of review and benchmarking studies.'),
               tags$li('Added a benchmarking table from Ghosh et al. (2017) displaying the sensitivity, specificity, true predictive value, and true negative value of 25 tools.'),
             ),
             h4('Version 1.0.7 - 17th January 2024'),
             tags$ul(
               tags$li('Adjusted the logo so that it scales to different screen sizes.'),
               tags$li('Updated the citation to reflect that the paper is in peer review.'),
               tags$li('Removed the "News" tab as it contained redundant information.'),
             ),
             h4('Version 1.0.6 - 11th December 2023'),
             tags$ul(
               tags$li('Added another VEP: SnpEff'),
             ),
             h4('Version 1.0.5 - 4th December 2023'),
             tags$ul(
               tags$li('Added option to select tools based on the number of VEPs that maximize coverage.'),
             ),
             h4('Version 1.0.4 - 27th November 2023'),
             tags$ul(
               tags$li('Updated the list of VEPs.'),
               tags$li('Changed the term "Consequence" to "Functional Impact".'),
             ),
             h4('Version 1.0.3 - 1st November 2023'),
             tags$ul(
               tags$li('Changed the name from FINDABLE to VEP Finder.'),
               tags$li('Changed the logo to reflect the new name'),
             ),
             h4('Version 1.0.2 - 24th October 2023'),
             tags$ul(
               tags$li('Extended the main table to include the number of variant types and functional impacts of each tool.'),
             ),
             h4('Version 1.0.1 - 24th October 2023'),
             tags$ul(
               tags$li('Added information about the update process in the tab "Release Notes".'),
             ),
             h4('Version 1.0.0 - 23rd October 2023'),
             p('The first release of VEP Finder includes the following features:'),
             tags$ul(
               tags$li('94 Variant Effect Predictors'),
               tags$li('30 Variation Types'),
               tags$li('130 Predicted Consequences'),
               tags$li('Support for Sequence Ontology controlled vocabulary'),
               tags$li('Support for filtering tools on Variation Type and Consequence'),
               tags$li('Downloadable list of Variant Effect Predictors in CSV format.')
             )
    ),
    tabPanel('Citation',
             h2('Citation'),
             p('When using VEP Finder in your work, please use the following citation:'),
             p('Riccio C, Jansen ML, Guo L, Ziegler A. Variant effect predictors: a systematic review and practical guide. Hum Genet. Published online April 4, 2024. doi:10.1007/s00439-024-02670-5'),
             p(tags$a(href = 'https://pubmed.ncbi.nlm.nih.gov/38573379/', 'Link to PubMed entry'))
    ),
    shiny::tabPanel('Reviews',
             p('Reviews offer additional guidance to select appropriate tools.'),
             DT::dataTableOutput('table_reviews')
    ),
    tabPanel('Benchmarking studies',
             h2('List of benchmarking studies'),
             DT::dataTableOutput('table_benchmarks'),
             h2('Results from the benchmarking study by Ghosh et al, 2017'),
             tags$footer(
               style = "margin-top: 20px;", # Adds some space between the table and the citation
               HTML("Adapted from: Ghosh, R., Oak, N. & Plon, S.E. Evaluation of in silico algorithms for use with ACMG/AMP clinical variant interpretation guidelines. "),
               tags$i("Genome Biol"),
               HTML(" 18, 225 (2017). "),
               tags$a(href = "https://doi.org/10.1186/s13059-017-1353-5", target = "_blank", "https://doi.org/10.1186/s13059-017-1353-5")
             ),
             DT::dataTableOutput('table_benchmark_ghosh'),
             h2('Results from the benchmarking study by Livesey et al, 2023'),
             tags$footer(
               style = "margin-top: 20px;", # Adds some space between the table and the citation
               HTML("Adapted from: Livesey, B.J. & Marsh, J.A. Updated benchmarking of variant effect predictors using deep mutational scanning. "),
               tags$i("Mol Syst Biol"),
               HTML(" (2023) 19: e11474. "),
               tags$a(href = "https://doi.org/10.15252/msb.202211474", target = "_blank", "https://doi.org/10.15252/msb.202211474")
             ),
             DT::dataTableOutput('table_benchmark_livesey'),
    ),
    shiny::tabPanel('Terms of Use',
             h2('Terms of Use'),
             p('All data in VEP Finder are released openly and publicly for the benefit of the broad biomedical and health science community. It is distributed under the terms of MIT license. Users may freely download, search the data and are encouraged to use and publish results generated from these data. There are no restrictions or embargoes on the publication of results derived from VEP Finder.'),
             p('This data set has been subjected to extensive quality control, but there is still the potential for errors. Please email us at ', tags$a(href = 'mailto:info@cardio-care.ch', 'info@cardio-care.ch'), ', in the event that any dubious values are encountered so that we may address them.'),
    ),
    tags$hr(class = 'thick-hr'),
    tags$div(
      class = 'footer',
      tags$b('Contact', style = 'font-size: 20px;'),
      tags$br(),
      tags$br(),
      tags$img(src = 'logo_company.png', width = 400),
      tags$br(),
      tags$br(),
      'Cardio-CARE AG',
      tags$br(),
      'Herman-Burchard-Strasse 3',
      tags$br(),
      '7625 Davos Wolfgang, Switzerland',
      tags$br(),
      tags$a(href = 'mailto:info@cardio-care.ch', 'info@cardio-care.ch'),
      tags$br(),
      '+41 81 410 18 01'
    )
  )
)
