using System;
using System.Collections.Generic;

public class GeoJsonObject
{
    public string type { get; set; }
    public List<Feature> features { get; set; }
}

public class Feature
{
    public string type { get; set; }
    public Geometry geometry { get; set; }
    public dynamic properties { get; set; }
}

public class Geometry
{
    public string type { get; set; }
    //public List<List<List<object>>> coordinates { get; set; }
    public dynamic coordinates { get; set; }
}

