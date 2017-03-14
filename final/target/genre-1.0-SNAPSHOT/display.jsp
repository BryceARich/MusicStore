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
<%@ page import="java.text.DecimalFormat" %>
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
          .list();

    if (SongInfos.isEmpty()) {
%>
<p>Genre '${fn:escapeXml(genreName)}' has no songs.</p>
<%
    } else {
%>
<p>Songs in Genre '${fn:escapeXml(genreName)}'.</p>
<form action="selectedCheckboxes" method="post">
<%

      // Look at all of our SongInfos
        int i = 0;
        for (SongInfo SongInfo : SongInfos) {
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
    <div class = "Button">
        <Button type="submit"> Add Selected Songs to Cart</Button>
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
<a href="/genre.jsp?genreName=${fn:escapeXml(genreName)}"> Add Song to ${fn:escapeXml(genreName)} </a>
<br></br>
<a href="main.jsp"> Back to Main </a>

</body>
</html>
<%-- //[END all]--%>
