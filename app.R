install.packages("shiny", repos = "http://cran.us.r-project.org")
install.packages("jsonlite", repos = "http://cran.us.r-project.org")
install.packages("dplyr", repos = "http://cran.us.r-project.org")
library(dplyr)
library(shiny)
library(jsonlite)
uto_url <- "https://utopia-game.com/wol/game/%20kingdoms_dump_v2/"
json_data <- fromJSON(uto_url)
uto_data <- as.data.frame(json_data)
Kds <- select(uto_data, 12,6,7,4,10,5,11, 8, 13)
Kds$Location <- paste(Kds$kingdoms.kingdomNumber, Kds$kingdoms.kingdomIsland, sep = ":")
Kds$Wars <- paste(Kds$kingdoms.warsWon, Kds$kingdoms.warsConcluded, sep = "/")
Kds <- select(Kds, 1,10,8,7,5,11,9)
colnames(Kds) <- c("Name", "Location", "Provinces", "Land", "Networth", "Wars", "Honor")
Kds <- Kds[order(Kds$Networth, decreasing = TRUE),]

Maxland <- max(Kds$Land)
Minland <- min(Kds$Land)
Maxnw <- max(Kds$Networth)
Minnw <- min(Kds$Networth)
Minprov <- min(Kds$Provinces)
Maxprov <- max(Kds$Provinces)

# sets up ui object
ui <- fluidPage(
  theme = bslib::bs_theme(bootswatch = "darkly"),
  titlePanel(
    # app title/description
    "War Target Finder"
  ),
  sidebarLayout(
    sidebarPanel(
      h2("Criteria"),
      fluidRow(
        column(width = 6, sliderInput("land", "Land", value = c(Minland,Maxland), min = Minland, max = Maxland)),
      ),
      fluidRow(
        column(width = 6, sliderInput("nw", "Networth", value = c(Minnw,Maxnw), min = Minnw, max = Maxnw)),
      ),
      fluidRow(
        column(width = 6, sliderInput("prov", "Provinces", value = c(Minprov,Maxprov), min = Minprov, max = Maxprov, step = 1)),
      ),
      width = 6),
    mainPanel(
      h2("Kingdoms"),
      br(),
      tableOutput("Kingdoms"),
      br(),
    )
  )
)
  
#setup server object
server <- function(input, output) {

  output$Kingdoms <- renderTable({
    RKD <- Kds[Kds$Land >= input$land[1] & Kds$Land <= input$land[2],]
    RKD <- RKD[RKD$Networth >= input$nw[1] & RKD$Networth <= input$nw[2],]
    RKD <- RKD[RKD$Provinces >= input$prov[1] & RKD$Provinces <= input$prov[2],]
    }
  )
}

#use shiny to bring two together
shinyApp(ui = ui, server = server)


