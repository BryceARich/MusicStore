<%-- //[START all]--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>

<%-- //[START imports]--%>
<%@ page import="com.example.genre.SongInfo" %>
<%@ page import="com.example.genre.Genre" %>
<%@ page import="com.example.genre.ShoppingCart" %>
<%@ page import="com.example.genre.UserData" %>
<%@ page import="com.googlecode.objectify.Key" %>
<%@ page import="com.googlecode.objectify.ObjectifyService" %>
<%-- //[END imports]--%>

<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<html>
<head>
    <link type="text/css" rel="stylesheet" href="/stylesheets/main.css"/>
</head>

<body>

<%
    String error = request.getParameter("error");
    UserService userService = UserServiceFactory.getUserService();
    User user = userService.getCurrentUser();
    Key<UserData> user_key = Key.create(UserData.class, user.getNickname());
    if (user != null) {
        pageContext.setAttribute("user", user);
    }
%>

<%-- //[START datastore]--%>
<%
    // Create the correct Ancestor key

    // Run an ancestor query to ensure we see the most up-to-date
    // view of the SongInfos belonging to the selected Genre.
      List<ShoppingCart> scs = ObjectifyService.ofy()
          .load()
          .type(ShoppingCart.class) // We want only SongInfos
          .ancestor(user_key)    // Anyone in this book
          .order("-date")       // Most recent first - date is indexed.
          .limit(1)
          .list();

    if (scs == null || scs.isEmpty() ||scs.get(0).songs_in_cart == null) {
%>
<p>User '${fn:escapeXml(user.nickname)}' has no songs in shopping cart.</p>
<%
    } else {
    ShoppingCart sc = scs.get(0);
    pageContext.setAttribute("totalPrice", sc.string_price);
%>
<p>Songs in shopping cart for '${fn:escapeXml(user.nickname)}'.</p>
<form action="Cart" method="post">
<%

      // Look at all of our SongInfos
        int i = 0;
        for (SongInfo SongInfo : sc.songs_in_cart) {
            pageContext.setAttribute("SongInfo_artist", SongInfo.artist);
            pageContext.setAttribute("SongInfo_title", SongInfo.title);
            pageContext.setAttribute("SongInfo_album", SongInfo.album);
            pageContext.setAttribute("SongInfo_price", SongInfo.price);
            pageContext.setAttribute("index", i);
            String author;
    %>
    <input type ="checkbox" name="id" value="${fn:escapeXml(index)}${fn:escapeXml(genreName)}"> ${fn:escapeXml(SongInfo_artist)}, <i>${fn:escapeXml(SongInfo_title)}</i>, ${fn:escapeXml(SongInfo_album)} - <b id ="b1">$${fn:escapeXml(SongInfo_price)}</b><BR>
    <%
        ++i;
        }
    %>
    <a> Total Price of Cart is $${fn:escapeXml(totalPrice)}</a><br>
    <div class = "Button">
        <Button type="submit" name="remove" value="remove"> Remove Selected Songs From Cart</Button>
        <Button type="submit" name="purchase" value="purchase"> Purchase All Items</Button>
    </div>
</form>
    <%
    }


    if(error != null){
%>
<p><b>An invalid Artist, Title or Price was submitted. Please try again.</b></p>    
<%    
    }

%>
<a href="main.jsp"> Back to Main </a>

</body>
</html>
<%-- //[END all]--%>
