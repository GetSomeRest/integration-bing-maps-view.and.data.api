using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Microsoft.AspNet.Membership.OpenAuth;

namespace View_and_Data
{
    internal static class AuthConfig
    {
        public static void RegisterOpenAuth()
        {
            // この ASP.NET の設定に関する詳細については、http://go.microsoft.com/fwlink/?LinkId=252803 を参照してください。
            // 外部サービス経由でのログインをサポートするためのアプリケーション。

            //OpenAuth.AuthenticationClients.AddTwitter(
            //    consumerKey: "Twitter のコンシューマー キー",
            //    consumerSecret: "Twitter のコンシューマー シークレット");

            //OpenAuth.AuthenticationClients.AddFacebook(
            //    appId: "Facebook アプリケーションの ID",
            //    appSecret: "Facebook アプリケーションのシークレット");

            //OpenAuth.AuthenticationClients.AddMicrosoft(
            //    clientId: "Microsoft アカウントのクライアント ID",
            //    clientSecret: "Microsoft アカウントのクライアント シークレット");

            //OpenAuth.AuthenticationClients.AddGoogle();
        }
    }
}