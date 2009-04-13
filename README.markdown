Pfeed
======

You need Pfeed when you want to automagically create fancy logs / activity updates in your rails app. 


### What's so magical here?
Lets assume you have a model that looks like

<pre>
<code>
 class User < ActiveRecord::Base
   has_many :friends
   has_one  :company
   def buy(x)
    ...
   end

   def sell(x)
    ...
   end
  
   def find_friends
    ...
   end  
 end
</code>
</pre>

Now lets add two lines 

<pre>
<code>
 emits_pfeeds :on => [:buy,:sell,:find_friends,:update_attribute] , :for => [:itself ,:all_in_its_class, :friends]
 receives_pfeed
</code>
</pre>

And you perform regular operations, like this

<pre>
<code>
 u1 = User.first
 u1.buy(10)
 u1.sell(5)
 u2 = User.last
 list = u2.find_friends
 u2.update_attribute(:nick_name, "alice")
 u2.buy (1)
</code>
</pre>

your application now emits feed without any other additional piece of code, and feed will look like this in view.

<pre><code>
 parolkar sold item at 2009-03-11 11:01:28 UTC 
 parolkar bought item at 2009-03-11 11:01:28 UTC
 foo found friends at 2009-03-11 11:01:28 UTC
 foo updated attribute nick name at 2009-03-11 11:01:29 UTC 
 alice bought item at 2009-03-11 11:02:28 UTC
</code></pre>

Isn't it magical? that it guesses the identity of model object (parolkar or foo in this case) and methods being called are treated as verbs to form a simple past tense.

Even more, each feed can be customized and skinned the way you want. You can easily extend the functionality to suit your requirements.

  


## More Details

What is feed?
Feed is the collection of activity logs which is generated while you perform actions on model objects.

Whats so special?, Why should I bother about it?

Imagine you want to create admin console for your app to monitor functional activities in your web apps ,i.e how users are using different parts of application. You will need to think of mechanism to capture the logs and then display in some logical manner.

OR 

Imagine you are building an app like facebook and you want to capture all activity user is performing and display it to her friends/group member/admin , Its a whole new feature whose implementation will force you to dig into design of your app and see where all the logs get generated and then to whom all the logs are going to be published.

What if I give you a generalized information model which will allow you to create such feature by keeping it completely isolated from your existing logic? and What if it is really scalable enough?


(more content to come here...)




## Installation
git submodule add git://github.com/parolkar/pfeed.git vendor/plugins/pfeed
rake pfeed:setup




Copyright (c) 2009 [Abhishek Parolkar] abhishek[at]parolkar.com , released under the MIT license
