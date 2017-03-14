/**
 * Copyright 2014-2015 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//[START all]
package com.example.genre;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

import java.io.IOException;
import java.util.Date;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.googlecode.objectify.ObjectifyService;
//import com.googlecode.objectify.Key;
import java.util.List;

/**
 * Form Handling Servlet
 * Most of the action for this sample is in webapp/genre.jsp, which displays the
 * {@link SongInfo}'s. This servlet has one method
 * {@link #doPost(<#HttpServletRequest req#>, <#HttpServletResponse resp#>)} which takes the form
 * data and saves it.
 */
public class AddToCartServlet extends HttpServlet {

  // Process the http POST of the form
  @Override
  public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
    SongInfo songInfo;
    Genre genre;

    UserService userService = UserServiceFactory.getUserService();
    User user = userService.getCurrentUser();  // Find out who the user is.
    if(user != null){

      com.googlecode.objectify.Key<UserData> user_key = com.googlecode.objectify.Key.create(UserData.class, user.getNickname());

      List<ShoppingCart> shoppingcarts = ObjectifyService.ofy()
            .load()
            .type(ShoppingCart.class) // We want only SongInfos
            .ancestor(user_key)    // Anyone in this book
            .order("-date")       // Most recent first - date is indexed.
            .limit(1)
            .list();
      ShoppingCart shoppingcart;
      if(shoppingcarts.isEmpty()){
        shoppingcart = new ShoppingCart(user.getNickname());
      } else {
        shoppingcart = shoppingcarts.get(0);
      }

      String select[] = req.getParameterValues("id");
      
      if(select != null && select.length > 0){
        String genreName = select[0].substring(1);
        com.googlecode.objectify.Key<Genre> theGenre = com.googlecode.objectify.Key.create(Genre.class, genreName);
        List<SongInfo> songList = ObjectifyService.ofy()
            .load()
            .type(SongInfo.class) // We want only SongInfos
            .ancestor(theGenre)    // Anyone in this book
            .order("-date")       // Most recent first - date is indexed.
            .list();

        int i = select.length - 1;

        while(i >= 0){
          SongInfo song = songList.get(Integer.parseInt(select[i].substring(0,1)));
          boolean add = true;
          if(shoppingcart.songs_in_cart != null){
            for(SongInfo song_in_cart : shoppingcart.songs_in_cart){
              if(song.equals(song_in_cart)){
                add = false;
              }
            }
          }
          if(add){
            shoppingcart.addSong(song);
          }
          i--;
        }
        ObjectifyService.ofy().save().entity(shoppingcart).now();
        resp.sendRedirect("/shoppingCart.jsp");
      } else {
        resp.sendRedirect("/main.jsp?error=true");
      }
    } else {
      resp.sendRedirect("/main.jsp?error=true");
    }
  }
}
//[END all]
