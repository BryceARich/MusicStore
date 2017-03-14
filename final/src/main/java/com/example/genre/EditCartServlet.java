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
public class EditCartServlet extends HttpServlet {

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

      String remove = req.getParameter("remove");
      String purchase = req.getParameter("purchase");
      String select[] = req.getParameterValues("id");
      if(select == null && purchase == null){
        resp.sendRedirect("shoppingCart.jsp");
      }else if(remove!=null){
        for(int i = select.length - 1; i >=0 ; i--){
          int value = Integer.parseInt(select[i]);
          shoppingcart.removeSong(value);
        }
        ObjectifyService.ofy().save().entity(shoppingcart).now();
        resp.sendRedirect("/shoppingCart.jsp");
      } else if(purchase != null){
        List<PurchasedItems> pis = ObjectifyService.ofy()
            .load()
            .type(PurchasedItems.class) // We want only SongInfos
            .ancestor(user_key)    // Anyone in this book
            .order("-date")       // Most recent first - date is indexed.
            .limit(1)
            .list();
        PurchasedItems pi;
        if(pis.isEmpty()){
          pi = new PurchasedItems(user.getNickname());
        } else {
          pi = pis.get(0);
        }
        while(!shoppingcart.songs_in_cart.isEmpty()){
          pi.addSong(shoppingcart.songs_in_cart.get(0));
          shoppingcart.removeSong(0);
        }
        ObjectifyService.ofy().save().entity(pi).now();
        ObjectifyService.ofy().save().entity(shoppingcart).now();
        resp.sendRedirect("/purchasedItems.jsp");
      } else {
        resp.sendRedirect("/main.jsp?error=true");
      }
    }
    else{
      resp.sendRedirect("/main.jsp?error=true");
    }
    
  }
}
//[END all]
