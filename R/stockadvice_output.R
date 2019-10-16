# -----------------------------------------------------------------------------
# Create  ICES Stock dataset for GeoFish stockadvice layer
# -----------------------------------------------------------------------------

# Load Library
library(dplyr)
library(tidyr)


# Load files
source(paste(getwd(),"/R/stockadvice_functions.R",sep=""))

# Set var
startYear <- 2016
#SpeciesList <- list('Pleuronectes platessa','Gadus morhua','Nephrops norvegicus','Solea solea','Lophius piscatorius','Lophius budegassa')
SpeciesList <- list('Pleuronectes platessa')
OutputPath <- paste(getwd(),"/OUTPUT/", sep="")        # Set OUTPUT path

# Get stocklist
stockList <- getListStocks()
stockList <- data.frame(stockList)

# Loop over all species
for(x in SpeciesList)
{
    # Set Species
    speciesName <- x
      
    # Filter stocklist on species and startyear
    stockListGeoFish <- stockList %>%
      mutate(AssessmentKey = as.character(AssessmentKey)) %>% 
      mutate(AssessmentYear = as.integer(as.character(AssessmentYear))) %>%
      mutate(StockKeyLabel = as.character(StockKeyLabel)) %>%   
      mutate(StockDescription = as.character(StockDescription)) %>% 
      mutate(SpeciesName = as.character(SpeciesName)) %>% 
      filter(SpeciesName == speciesName) %>%
      filter(AssessmentYear >= startYear) %>%
      select(StockKeyLabel, StockDescription, SpeciesName, AssessmentKey, AssessmentYear) %>%
      arrange(AssessmentYear, StockKeyLabel)
    
    # Select most recent assessment (you can have multiple assessments for one stock in a single year)
    stockListGeoFish <- stockListGeoFish %>%
      group_by(AssessmentYear, StockKeyLabel, StockDescription, SpeciesName) %>% 
      filter(as.integer(AssessmentKey) == max(as.integer(AssessmentKey))) 
    
    # Convert into data.frame
    stockListGeoFish  <- data.frame(stockListGeoFish)
    
    # Get & set speciescode
    speciesCode <- getSpeciesCode(speciesName)
    stockListGeoFish$Species <- speciesCode
    
    # Add extra properties
    stockListGeoFish$ICES_Areas <- ""
    stockListGeoFish$Fishingpressure <- "" 
    stockListGeoFish$Fishingpressure_Status <- "" 
    stockListGeoFish$Stocksize <- ""
    stockListGeoFish$Stocksize_Status <- ""
    stockListGeoFish$Report <- "" 
    stockListGeoFish$Graph_Landings <- "" 
    stockListGeoFish$Graph_Recruitment <- "" 
    stockListGeoFish$Graph_Fishing_Mortality <- "" 
    stockListGeoFish$Graph_Spawning_Stockbiomass <- "" 
    stockListGeoFish$Colorcode <- ""
    
    # loop over all records and set other props
    for(i in 1:nrow(stockListGeoFish))
    {
      # Set assessmentKey 
      assessmentKey <- as.integer(stockListGeoFish[i,'AssessmentKey'])
      
      # Get ICES Division & report - select first row
      stockDownloadData <- getStockDownloadData(assessmentKey) %>%
        slice(1:1) # IcesDiv & Report are similar for all records
        
      stockDownloadData <- data.frame(stockDownloadData)

      # Get other props
      if(nrow(stockDownloadData) > 0)
      {
        stockListGeoFish[i,'ICES_Areas'] <- as.character(stockDownloadData[1,'ICES_Areas']) # IcesDiv is similar for all records in dataset
        stockListGeoFish[i,'Report'] <- as.character(stockDownloadData[1,'Report'])         # Report is similar for all records in dataset
      
        # Get graph data for assessmentKey
        stockListGeoFish[i,'Graph_Landings'] <- getLandingsGraph(assessmentKey)
        stockListGeoFish[i,'Graph_Recruitment'] <- getRecruitmentGraph(assessmentKey) 
        stockListGeoFish[i,'Graph_Fishing_Mortality'] <- getFishingMortalityGraph(assessmentKey)   
        stockListGeoFish[i,'Graph_Spawning_Stockbiomass'] <- getSpawningStockBiomassGraph(assessmentKey) 
      
        # Get stock status data
        stockStatus <- getStockStatusValues(assessmentKey) %>%
          filter(lineNumber == 1) # select row 1 (= Maximum sustainable yield)
         
        stockStatus <- data.frame(stockStatus) 
       
        if(nrow(stockStatus) > 0)
        {
          stockListGeoFish[i,'Fishingpressure'] <- as.character(stockStatus[1,'fishingPressure'])
          stockListGeoFish[i,'Fishingpressure_Status'] <- as.character(stockStatus[1,'fishingPressureStatus']) 
          stockListGeoFish[i,'Stocksize'] <- as.character(stockStatus[1,'stockSize'])
          stockListGeoFish[i,'Stocksize_Status'] <- as.character(stockStatus[1,'stockSizeStatus'])
         
          # Get stock status ColorCode
          stockListGeoFish[i,'Colorcode'] <- getStockStatusColorcode(assessmentKey)
        }
      }
    }
    
    # set property order
    stockListGeoFish <- stockListGeoFish %>%
      filter(Fishingpressure_Status != '') %>%
      filter(ICES_Areas != '') %>%
      # TODO: filter on relevant ICES_Areas
      select(StockKeyLabel, StockDescription, AssessmentYear, SpeciesName, Species, ICES_Areas, Fishingpressure, Fishingpressure_Status, Stocksize, Stocksize_Status, Report, Graph_Landings, Graph_Recruitment, Graph_Fishing_Mortality, Graph_Spawning_Stockbiomass, Colorcode)
    
    # Export 
    write.table(stockListGeoFish, paste(OutputPath,"StockData_",speciesCode,".csv",sep=""), sep=";",row.names=FALSE, col.names = TRUE, quote = FALSE)

}


