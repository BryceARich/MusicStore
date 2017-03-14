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
import com.googlecode.objectify.annotation.Parent;
import com.googlecode.objectify.annotation.Index;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;


import java.util.Date;
/**
 * The @Entity tells Objectify about our entity.  We also register it in
 * OfyHelper.java -- very important.
 *
 * This is never actually created, but gives a hint to Objectify about our Ancestor key.
 */
@Entity
public class Genre {
  @Parent Key<Music> theMusic;
  @Id public Long id;

  public String genreName;
  @Index public Date date;

  public Genre() {
    date = new Date();
  }

  Genre(String music, String genreName){
    this.genreName = genreName;

    if(music != null) {
      theMusic = Key.create(Music.class, music);
    } else {
      theMusic = Key.create(Music.class, "default");
    }
  }
}
//[END all]
