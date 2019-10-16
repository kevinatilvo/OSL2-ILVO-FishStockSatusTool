# -----------------------------------------------------------------------------
# Functions to get ICES Stock  http://standardgraphs.ices.dk/StandardGraphsWebServices.asmx
# -----------------------------------------------------------------------------

#load package
library(RODBC)
library(httr)
library(XML)
library(data.table)


# Get stock list
getListStocks <- function(){ 
  xmldata <- GET("http://standardgraphs.ices.dk/StandardGraphsWebServices.asmx/getListStocks?year=0",config = httr::config(ssl_verifypeer = FALSE),query = list())
  ds <- xmlToDataFrame(xmlParse(xmldata))
  return(ds)}


# Get stock download data 
getStockDownloadData  <- function(AssessmentKey){ 
  xmldata <- GET(paste("http://standardgraphs.ices.dk/StandardGraphsWebServices.asmx/getStockDownloadData?AssessmentKey=",AssessmentKey),config = httr::config(ssl_verifypeer = FALSE),query = list())
  ds <- xmlToDataFrame(xmlParse(xmldata))
  return(ds)}

# Get stock summary table 
getSummaryTable  <- function(AssessmentKey){ 
  xmldata <- GET(paste("http://standardgraphs.ices.dk/StandardGraphsWebServices.asmx/getSummaryTable?AssessmentKey=",AssessmentKey),config = httr::config(ssl_verifypeer = FALSE),query = list())
  ds <- xmlToDataFrame(xmlParse(xmldata))
  return(ds)}

# Get landings graph 
getLandingsGraph  <- function(AssessmentKey){ 
  xmldata <- GET(paste("http://standardgraphs.ices.dk/StandardGraphsWebServices.asmx/getLandingsGraph?AssessmentKey=",AssessmentKey),config = httr::config(ssl_verifypeer = FALSE),query = list())
  url_xml <- xmlParse(xmldata)
  return(xmlValue(xmlRoot(url_xml)))}

# Get recruitment graph 
getRecruitmentGraph  <- function(AssessmentKey){ 
  xmldata <- GET(paste("http://standardgraphs.ices.dk/StandardGraphsWebServices.asmx/getRecruitmentGraph?AssessmentKey=",AssessmentKey),config = httr::config(ssl_verifypeer = FALSE),query = list())
  url_xml <- xmlParse(xmldata)
  return(xmlValue(xmlRoot(url_xml)))}

# Get FishingMortality Graph
getFishingMortalityGraph  <- function(AssessmentKey){ 
  xmldata <- GET(paste("http://standardgraphs.ices.dk/StandardGraphsWebServices.asmx/getFishingMortalityGraph?AssessmentKey=",AssessmentKey),config = httr::config(ssl_verifypeer = FALSE),query = list())
  url_xml <- xmlParse(xmldata)
  return(xmlValue(xmlRoot(url_xml)))}

# Get SpawningStock Biomass Graph
getSpawningStockBiomassGraph  <- function(AssessmentKey){ 
  xmldata <- GET(paste("http://standardgraphs.ices.dk/StandardGraphsWebServices.asmx/getSpawningStockBiomassGraph?AssessmentKey=",AssessmentKey),config = httr::config(ssl_verifypeer = FALSE),query = list())
  url_xml <- xmlParse(xmldata)
  return(xmlValue(xmlRoot(url_xml)))}

# Get Stock Status Table image
getStockStatusTable  <- function(AssessmentKey){ 
  xmldata <- GET(paste("http://standardgraphs.ices.dk/StandardGraphsWebServices.asmx/getStockStatusTable?AssessmentKey=",AssessmentKey),config = httr::config(ssl_verifypeer = FALSE),query = list())
  url_xml <- xmlParse(xmldata)
  return(xmlValue(xmlRoot(url_xml)))}


# Get Stock Status Values
getStockStatusValues  <- function(AssessmentKey){ 
  xmldata <- GET(paste("http://standardgraphs.ices.dk/StandardGraphsWebServices.asmx/getStockStatusValues?AssessmentKey=",AssessmentKey),config = httr::config(ssl_verifypeer = FALSE),query = list())
  ds <- xmlToDataFrame(xmlParse(xmldata))
  return(ds)}

# Get species code
getSpeciesCode  <- function(species){ 
  speciesCode <- switch (species,
          'Pleuronectes platessa' = 'PLE',
          'Gadus morhua' = 'COD',
          'Nephrops norvegicus' = 'NEP',
          'Solea solea' = 'SOL',
          'Lophius piscatorius' = 'MON',
          'Lophius budegassa' ='ANK',
          '')
  return(speciesCode)}
  
  
# Get Stock Status ColorCode
getStockStatusColorcode  <- function(AssessmentKey){ 
  
  # Get stock status values
  stockStatus <- getStockStatusValues(assessmentKey) %>%
    filter(lineNumber == 1)
  stockStatus <- data.frame(stockStatus)
  
  fishingPressureStatus <- as.character(stockStatus[1,'fishingPressureStatus']) 
  stockSizeStatus <- as.character(stockStatus[1,'stockSizeStatus'])
  
  # TODO: add logic depending on stockstatus values
  if((fishingPressureStatus == "Below" || fishingPressureStatus == "Appropriate") && stockSizeStatus == "Above trigger"){
    colorcode <- '#98e600' # darkgreen: Fishingpressure and Stocksize are OK
  } else if((fishingPressureStatus == "Below" || fishingPressureStatus == "Appropriate") || stockSizeStatus == "Above trigger"){
    colorcode <- '#ffaa00' # orange: Fishingpressure or Stocksize is OK 
  } else if((fishingPressureStatus == "Above") && stockSizeStatus == "Below trigger"){
    colorcode <- '#e64c00' # red: Fishingpressure and Stocksize are NOK 
  }else if(stockSizeStatus == "Above proxy"){
    colorcode <- '#d1ff73' # lightgreen: Trend Stocksize is positive
  }else if(stockSizeStatus == "Below proxy"){
    colorcode <- '#ffa77f' # pink: Trend Stocksize is negative  
  }else{
    colorcode <- '#ffffff' # white: unknown  
  }
  
  return(colorcode)}
