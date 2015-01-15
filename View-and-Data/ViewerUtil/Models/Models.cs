using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ViewerUtil.Models
{

    public class AccessToken
    {
        public string token_type { get; set; }
        public int expires_in { get; set; }
        public string access_token { get; set; }

    }




}
