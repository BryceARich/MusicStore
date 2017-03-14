<%-- //[START all]--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>

<%-- //[START imports]--%>
<%@ page import="com.example.genre.SongInfo" %>
<%@ page import="com.example.genre.Genre" %>
<%@ page import="com.example.genre.Music" %>
<%@ page import="com.googlecode.objectify.Key" %>
<%@ page import="com.googlecode.objectify.ObjectifyService" %>
<%-- //[END imports]--%>

<%@ page import="java.util.List" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<html>
<head>
    <link type="text/css" rel="stylesheet" href="/stylesheets/main.css"/>
</head>

<body>

<%
    String musicName = request.getParameter("musicName");
    String error = request.getParameter("error");
    if (musicName == null) {
        musicName = "default";
    }
    pageContext.setAttribute("musicName", musicName);
    UserService userService = UserServiceFactory.getUserService();
    User user = userService.getCurrentUser();

    if(error != null){
%>
    <b> Sorry, You must be logged in to complete that action </b>
<%
    }
    
    if (user != null) {
        pageContext.setAttribute("user", user);
%>

<p>Hello, ${fn:escapeXml(user.nickname)}! (You can
    <a href="<%= userService.createLogoutURL(request.getRequestURI()) %>">sign out</a>.)</p>
<%
    } else {
%>
<p>Hello!
    <a href="<%= userService.createLoginURL(request.getRequestURI()) %>">Sign in</a>
    to Enable Shopping.</p>
<%
    }
%>

<%-- //[START datastore]--%>
<%
    // Create the correct Ancestor key
      Key<Music> theMusic = Key.create(Music.class, musicName);

    // Run an ancestor query to ensure we see the most up-to-date
    // view of the SongInfos belonging to the selected Genre.
      List<Genre> Genres = ObjectifyService.ofy()
          .load()
          .type(Genre.class) // We want only SongInfos
          .ancestor(theMusic)    // Anyone in this book
          .order("-date")       // Most recent first - date is indexed.
          .limit(5)             // Only show 5 of them.
          .list();

    if (Genres.isEmpty()) {
%>
<p>There are currently no Genres please add some!</p>
<%
    } else {
%>
<p>We have these Genres</p>
<%

      // Look at all of our SongInfos
        for (Genre Genre : Genres) {
            pageContext.setAttribute("Genre_name", Genre.genreName);
%>
<a href="/display.jsp?genreName=${fn:escapeXml(Genre_name)}">${fn:escapeXml(Genre_name)}</a>
<br></br>
<%
        }
    }


%>

<a href="genre.jsp"> Add a new song here</a>
<br></br>
<a href="search.jsp"> Search for a song here</a>
<%
if(user != null){
%>
    <br></br>
    <a href="shoppingCart.jsp"> Check What's In Your Cart</a>
    <br></br>
    <a href="purchasedItems.jsp"> Check What You've Already Purchased</a>
<%
}
%>


</body>
</html>
<%-- //[END all]--%>
