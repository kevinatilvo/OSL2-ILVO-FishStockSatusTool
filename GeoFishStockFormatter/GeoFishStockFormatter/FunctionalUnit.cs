using System;
using System.Collections.Generic;
using System.Text;

namespace GeoFishStockFormatter
{

    public class FunctionalUnit
    {
        public string type { get; set; }
        public Feature[] features { get; set; }
    }

    public class Properties
    {
        public string FU { get; set; }
        public int FID_1 { get; set; }
        public string FU_DESCRIP { get; set; }
        public int Id { get; set; }
    }

}
