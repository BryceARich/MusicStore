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
    String artistName = request.getParameter("artist");
    String error = request.getParameter("error");
    if (genreName == null) {
        genreName = "Country";
    }
    if(artistName == null){
        artistName = "";
    }
    pageContext.setAttribute("genreName", genreName);
    pageContext.setAttribute("artist", artistName);
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
          .list();

    if (SongInfos.isEmpty()) {
%>
<p>Genre '${fn:escapeXml(genreName)}' has no songs.</p>
<%
    } else {
        if(artistName != ""){
%>
<p>Songs in Genre '${fn:escapeXml(genreName)}' matching your search "${fn:escapeXml(artist)}".</p>
<%
        } else {
%>
<p>All Songs in Genre '${fn:escapeXml(genreName)}'. Specify your search below!</p>
<%
    }
%>
<form action="selectedCheckboxes" method="post">
<%

      // Look at all of our SongInfos
      boolean found = false;
      int i = 0;
        for (SongInfo SongInfo : SongInfos) {
            pageContext.setAttribute("SongInfo_artist", SongInfo.artist);
            pageContext.setAttribute("SongInfo_title", SongInfo.title);
            pageContext.setAttribute("SongInfo_album", SongInfo.album);
            pageContext.setAttribute("SongInfo_price", SongInfo.price);
            pageContext.setAttribute("index", i);
            if(SongInfo.artist.toLowerCase().contains(artistName.toLowerCase())){
            found = true;
    %>
    <input type ="checkbox" name="id" value="${fn:escapeXml(index)}${fn:escapeXml(genreName)}"> ${fn:escapeXml(SongInfo_artist)}, <i>${fn:escapeXml(SongInfo_title)}</i>, ${fn:escapeXml(SongInfo_album)} - <b id ="b1">$${fn:escapeXml(SongInfo_price)}</b><BR>
    <%
            ++i;
            }
        }
%>
    <div class = "Button">
        <Button type="submit"> Add Selected Songs to Cart</Button>
    </div>
</form>
<%

        if(!found){
%> 
<p>Sorry no results were found matching your search "${fn:escapeXml(artist)}"</p>
<%
        }
    }

    if(error != null){
%>
<p><b>Sorry No Artists Were Found For Your Search</b></p>    
<%    
    }

%>



<form action="/searchSong" method="post">
    <p> Search for an Artist in ${fn:escapeXml(genreName)} </p>
    <div id="artist" align = "center">
        <label>Artist to search for:</label>
        <input type = "text" name="Artist" rows="1" cols="60"> </textarea>
    </div>
    <div class = "Button">
        <Button type="submit"> Search For Artist</Button>
    </div>
    <input type="hidden" name="genreName" value="${fn:escapeXml(genreName)}"/>
</form>
<%-- //[END datastore]--%>
<form action="/search.jsp" method="get">
    <div><input type="text" name="genreName" value="${fn:escapeXml(genreName)}"/></div>
    <div><Button type="submit">Switch Genre</Button></div>
</form>

<a href="main.jsp"> View Current Genres Here </a>

</body>
</html>
<%-- //[END all]--%>
