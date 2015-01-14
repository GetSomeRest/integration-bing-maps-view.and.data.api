<%@ Page Language="C#" Title="外部ログインとして登録します" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RegisterExternalLogin.aspx.cs" Inherits="View_and_Data.Account.RegisterExternalLogin" %>
<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <hgroup class="title">
        <h1><%: ProviderDisplayName %> アカウントに登録します</h1>
        <h2><%: ProviderUserName %>.</h2>
    </hgroup>

    
    <asp:ModelErrorMessage runat="server" ModelStateKey="Provider" CssClass="field-validation-error" />
    

    <asp:PlaceHolder runat="server" ID="userNameForm">
        <fieldset>
            <legend>関連付けフォーム</legend>
            <p>
                <strong><%: ProviderDisplayName %></strong> で
                <strong><%: ProviderUserName %></strong> として認証されました。以下で現在のサイトのユーザー名を入力し、
                [ログイン] ボタンをクリックしてください。
            </p>
            <ol>
                <li class="email">
                    <asp:Label runat="server" AssociatedControlID="userName">ユーザー名</asp:Label>
                    <asp:TextBox runat="server" ID="userName" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="userName"
                        Display="Dynamic" ErrorMessage="ユーザー名は必須です" ValidationGroup="NewUser" />
                    
                    <asp:ModelErrorMessage runat="server" ModelStateKey="UserName" CssClass="field-validation-error" />
                    
                </li>
            </ol>
            <asp:Button runat="server" Text="ログイン" ValidationGroup="NewUser" OnClick="logIn_Click" />
            <asp:Button runat="server" Text="キャンセル" CausesValidation="false" OnClick="cancel_Click" />
        </fieldset>
    </asp:PlaceHolder>
</asp:Content>
