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

import com.googlecode.objectify.Key;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import com.googlecode.objectify.annotation.Index;
import com.googlecode.objectify.annotation.Parent;

import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

import java.util.ArrayList;
import java.util.List;

import java.lang.String;
import java.util.Date;
import java.util.List;
import java.text.DecimalFormat;

/**
 * The @Entity tells Objectify about our entity.  We also register it in {@link OfyHelper}
 * Our primary key @Id is set automatically by the Google Datastore for us.
 *
 * We add a @Parent to tell the object about its ancestor. We are doing this to support many
 * genres.  Objectify, unlike the AppEngine library requires that you specify the fields you
 * want to index using @Index.  Only indexing the fields you need can lead to substantial gains in
 * performance -- though if not indexing your data from the start will require indexing it later.
 *
 * NOTE - all the properties are PUBLIC so that we can keep the code simple.
 **/
@Entity
public class ShoppingCart {
  //Replace with TODO
  @Parent Key<UserData> theUserData;
  @Id public Long id;

  //My Additions
  public List<SongInfo> songs_in_cart;
  //End My Additions

  public String author_email;
  public String author_id;
  public String content;
  public Double total_price;
  public String string_price;
  @Index public Date date;

  /**
   * Simple constructor just sets the date
   **/
  public ShoppingCart() {
    date = new Date();
  }

  //replacement function
  public ShoppingCart(String user){
    this();
    if(user != null) {
      theUserData = Key.create(UserData.class, user);
    } else {
      theUserData = Key.create(UserData.class, "default");
    }
    total_price = 0.0;
  }

  public void addSong(SongInfo song){
    if(songs_in_cart == null){
      songs_in_cart = new ArrayList<SongInfo>();
    }
    if(!songs_in_cart.contains(song)){
      songs_in_cart.add(song);
      total_price += Double.parseDouble(song.price);
      string_price = new DecimalFormat("#.00").format(total_price);
    }
  }

  public void removeSong(int index){
    this.total_price -= Double.parseDouble(this.songs_in_cart.get(index).price);
    string_price = new DecimalFormat("#.00").format(total_price);
    this.songs_in_cart.remove(index);
  }

}
//[END all]
