using System;


public class IcesArea
{
    public string type { get; set; }
    public List<Feature> features { get; set; }
}

public class Feature
{
    public string type { get; set; }
    public Geometry geometry { get; set; }
    public Properties properties { get; set; }
}

public class Geometry
{
    public string type { get; set; }
    public object[][][] coordinates { get; set; }
}

public class Properties
{
    public int OBJECTID_1 { get; set; }
    public int OBJECTID { get; set; }
    public string Major_FA { get; set; }
    public string SubArea { get; set; }
    public string Division { get; set; }
    public string SubDivisio { get; set; }
    public string Unit { get; set; }
    public string Area_Full { get; set; }
    public string Area_27 { get; set; }
    public float Area_km2 { get; set; }
}
