using log4net;
using RestSharp;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using ViewerUtil.Models;

namespace ViewerUtil
{
    public class Util
    {
        private static readonly ILog logger = LogManager.GetLogger(typeof(Util));

        string baseUrl = "";
        RestClient m_client;

        public Util(string baseUrl)
        {
            this.baseUrl = baseUrl;
            m_client = new RestClient(baseUrl);
        }

        public AccessToken GetAccessToken(string clientId, string clientSecret)
        {
            AccessToken token = null;

            RestRequest req = new RestRequest();
            req.Resource = "authentication/v1/authenticate";
            req.Method = Method.POST;
            req.AddHeader("Content-Type", "application/x-www-form-urlencoded");
            req.AddParameter("client_id", clientId);
            req.AddParameter("client_secret", clientSecret);
            req.AddParameter("grant_type", "client_credentials");

            IRestResponse<AccessToken> resp = m_client.Execute<AccessToken>(req);
            logger.Debug(resp.Content);

            if (resp.StatusCode == System.Net.HttpStatusCode.OK)
            {
                AccessToken ar = resp.Data;
                if (ar != null)
                {
                    token = ar;

                }
            }
            return token;
        }



    }
}
