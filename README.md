# OSL2-ILVO-FishStockSatusTool
A tool to create GeoJSON-layers containing info regarding fish stocks.

Steps:
1) Use the R-scripts to generate CSV-files with data fetched from the ICES Web API.
2) Use the GeoFishStockFormatter to generate GeoJSON-layers using the CSV-files from step 1. This requires .NET Core 2.2.
