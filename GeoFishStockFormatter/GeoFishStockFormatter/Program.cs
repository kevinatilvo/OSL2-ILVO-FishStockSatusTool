using CsvHelper;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Dynamic;
using System.IO;
using System.Linq;
using System.Text;

namespace GeoFishStockFormatter
{
    class Program
    {
        static void Main(string[] args)
        {
            try
            {
                Console.WriteLine("Type or paste the folder location containing the csv-file...");
                var folder = Console.ReadLine();

                using (StreamReader nephropsReader = new StreamReader("Nephrops_FU.json"))
                using (StreamReader r = new StreamReader("ICES_areas_trimmed.json"))
                {
                    string json = r.ReadToEnd();
                    string nephropsJson = nephropsReader.ReadToEnd();

                    IcesArea icesAreas = JsonConvert.DeserializeObject<IcesArea>(json);
                    var features = icesAreas.features;

                    FunctionalUnit functionalUnits = JsonConvert.DeserializeObject<FunctionalUnit>(nephropsJson);
                    var nephropsFeatures = functionalUnits.features;

                    Dictionary<int, GeoJsonObject> speciesPerYear = new Dictionary<int, GeoJsonObject>();

                    var files = Directory.GetFiles("C:\\temp", "*.csv", SearchOption.TopDirectoryOnly);

                    foreach (var file in files)
                    {
                        bool isNephropsFile = file.Contains("NEP");
                        speciesPerYear = new Dictionary<int, GeoJsonObject>();
                        TextReader reader = new StreamReader(Path.Combine(folder, file));
                        var csvReader = new CsvReader(reader);
                        csvReader.Configuration.Delimiter = ";";
                        var records = csvReader.GetRecords<dynamic>().ToList();
                        int count = records.Count();
                        var species = records.First().Species;


                        //foreach line in the csv
                        foreach (var record in records)
                        {
                            Feature feature = new Feature();
                            int year = int.Parse(record.AssessmentYear);
                            string[] icesDivisionsOrFunctionalUnits;
                            if (isNephropsFile)
                            {
                                icesDivisionsOrFunctionalUnits = record.Functional_Unit.ToString().Split("-");
                            }
                            else
                            {
                                icesDivisionsOrFunctionalUnits = record.ICES_Areas.ToString().Split("~");
                            }
                            
                            feature.type = "Feature";
                            feature.properties = record;
                            feature.geometry = new Geometry();
                            feature.geometry.type = "MultiPolygon";
                            feature.geometry.coordinates = new List<List<List<object>>>();
                            //foreach icesdivision in the cell
                            for (int i = 0; i < icesDivisionsOrFunctionalUnits.Length; i++)
                            {
                                Feature f;
                                if (isNephropsFile)
                                {
                                    f = nephropsFeatures.FirstOrDefault(x => x.properties.FU.ToString().Contains(icesDivisionsOrFunctionalUnits[i].Trim()));
                                }
                                else
                                {
                                    f = features.FirstOrDefault(x => x.properties.Area_Full.ToString().Contains(icesDivisionsOrFunctionalUnits[i].Trim()));
                                }
                                
                                if (f == null) continue;
                                if (f.geometry.type == "MultiPolygon")
                                {
                                    foreach (var multipolygon in f.geometry.coordinates)
                                    {
                                        var mp = new List<List<object>>();
                                        foreach (var polygon in multipolygon)
                                        {
                                            var p = new List<object>();
                                            foreach (var coords in polygon)
                                            {
                                                p.Add(coords);
                                            }
                                            mp.Add(p);
                                        }
                                        feature.geometry.coordinates.Add(mp);
                                    }
                                    
                                }
                                else if (f.geometry.type == "Polygon")
                                {
                                    var mp = new List<List<object>>();
                                    foreach (var polygon in f.geometry.coordinates)
                                    {
                                        var p = new List<object>();
                                        foreach (var coords in polygon)
                                        {
                                            p.Add(coords);
                                        }
                                        mp.Add(p);
                                    }
                                    feature.geometry.coordinates.Add(mp);
                                }

                            }
                            //add the geoJson if it does not exist for the year
                            if (!speciesPerYear.ContainsKey(year))
                            {
                                GeoJsonObject geoJson = new GeoJsonObject();
                                geoJson.type = "FeatureCollection";
                                geoJson.features = new List<Feature>();
                                speciesPerYear[year] = geoJson;
                            }
                            if (((List<List<List<object>>>)feature.geometry.coordinates).Any())
                            {
                                speciesPerYear[year].features.Add(feature);
                            }
                        }

                        foreach (KeyValuePair<int, GeoJsonObject> entry in speciesPerYear)
                        {
                            var jsonString = JsonConvert.SerializeObject(entry.Value);
                            var filename = $@"{species}_{entry.Key}.geojson";
                            Console.WriteLine($@"Creating File {filename} ...");
                            File.WriteAllText(Path.Combine(folder, filename), jsonString, Encoding.UTF8);
                        }
                        reader.Close();
                    }
                }
                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine("All done!");
            }
            catch (Exception e)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("Error:");
                Console.WriteLine(e.Message);
            }
            finally
            {
                Console.ResetColor();
            }
        }
    }
}
