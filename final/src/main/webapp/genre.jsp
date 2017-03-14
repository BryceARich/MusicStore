<%-- //[START all]--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>

<%-- //[START imports]--%>
<%@ page import="com.example.genre.SongInfo" %>
<%@ page import="com.example.genre.Genre" %>
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
    String genreName = request.getParameter("genreName");
    String error = request.getParameter("error");
    if (genreName == null) {
        genreName = "Country";
    }
    pageContext.setAttribute("genreName", genreName);
    UserService userService = UserServiceFactory.getUserService();
    User user = userService.getCurrentUser();
%>

<%-- //[START datastore]--%>
<%
    // Create the correct Ancestor key
      Key<Genre> theGenre = Key.create(Genre.class, genreName);

    // Run an ancestor query to ensure we see the most up-to-date
    // view of the SongInfos belonging to the selected Genre.
      List<SongInfo> SongInfos = ObjectifyService.ofy()
          .load()
          .type(SongInfo.class) // We want only SongInfos
          .ancestor(theGenre)    // Anyone in this book
          .order("-date")       // Most recent first - date is indexed.
          .limit(5)             // Only show 5 of them.
          .list();

    if (SongInfos.isEmpty()) {
%>
<p>Genre '${fn:escapeXml(genreName)}' has no songs.</p>
<%
    } else {
%>
<p>Songs in Genre '${fn:escapeXml(genreName)}'.</p>
<%

      // Look at all of our SongInfos
        for (SongInfo SongInfo : SongInfos) {
            pageContext.setAttribute("SongInfo_artist", SongInfo.artist);
            pageContext.setAttribute("SongInfo_title", SongInfo.title);
            pageContext.setAttribute("SongInfo_album", SongInfo.album);
            pageContext.setAttribute("SongInfo_price", SongInfo.price);
            String author;
%>
<p>${fn:escapeXml(SongInfo_artist)}, <i>${fn:escapeXml(SongInfo_title)}</i>, ${fn:escapeXml(SongInfo_album)} - <b id ="b1">$${fn:escapeXml(SongInfo_price)}</b></p>
<%
        }
    }

    if(error != null){
%>
<p><b>An invalid Artist, Title or Price was submitted. Please try again.</b></p>    
<%    
    }

%>



<form action="/addSong" method="post">
    <div id="artist" align = "center">
        <label>Artist:</label>
        <input type = "text" name="Artist" rows="1" cols="60"> </textarea>
    </div>
    <div id="title" align = "center">
        <label>Title:</label>
        <input type = "text" name="Title" rows="3" cols="60"> </textarea>
    </div>
    <div id="album" align = "center">
        <label>Album (optional):</label>
        <input type = "text" name="Album" rows="1" cols="60"> </textarea>
    </div>
    <div id="price" align = "center">
        <label>Price:</label>
        <input type = "number" step=".01" value="1.00" name="Price" rows="1" cols="60"> </input>
    </div>
    <div class = "Button">
        <Button type="submit"> Post New Song</Button>
    </div>
    <input type="hidden" name="genreName" value="${fn:escapeXml(genreName)}"/>
</form>
<%-- //[END datastore]--%>
<form action="/genre.jsp" method="get">
    <div><input type="text" name="genreName" value="${fn:escapeXml(genreName)}"/></div>
    <div><Button type="submit">Switch Genre</Button></div>
</form>

<a href="main.jsp"> Back to Main </a>

</body>
</html>
<%-- //[END all]--%>
