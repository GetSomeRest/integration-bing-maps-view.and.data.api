<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="OpenAuthProviders.ascx.cs" Inherits="View_and_Data.Account.OpenAuthProviders" %>

<fieldset class="open-auth-providers">
    <legend>別のサービスを使用してログインします</legend>
    
    <asp:ListView runat="server" ID="providerDetails" ItemType="Microsoft.AspNet.Membership.OpenAuth.ProviderDetails"
        SelectMethod="GetProviderNames" ViewStateMode="Disabled">
        <ItemTemplate>
            <button type="submit" name="provider" value="<%#: Item.ProviderName %>"
                title="アカウントを使用して <%#: Item.ProviderDisplayName %> ログインします。">
                <%#: Item.ProviderDisplayName %>
            </button>
        </ItemTemplate>
    
        <EmptyDataTemplate>
            <div class="message-info">
                <p>構成されている外部認証サービスがありません。外部サービスを介してログインをサポートするようこの ASP.NET アプリケーションを設定する方法の詳細については、<a href="http://go.microsoft.com/fwlink/?LinkId=252803">この資料</a>を参照してください。</p>
            </div>
        </EmptyDataTemplate>
    </asp:ListView>
</fieldset>