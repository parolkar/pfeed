Pfeed
======

You need Pfeed when you want to automagically create fancy logs / activity updates in your rails app, asynchronously. 


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

Now lets add two lines at bottom of model definition 

<pre>
<code>
 emits_pfeeds :on => [:buy,:sell,:find_friends,:update_attribute] , :for => [:itself , :friends]   # Note: if feed needs to be received by all users , you could use :for => [:all_in_its_class]
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
 parolkar sold item about 6 minutes ago
 parolkar bought item about 4 minutes ago
 foo found friends about 2 minutes ago
 foo updated attribute nick name about 2 minutes ago
 alice bought item about 2 minutes ago
</code></pre>

Isn't it magical? that it guesses the identity of model object (parolkar or foo in this case) and methods being called are treated as verbs to form a simple past tense.  

Even more, each feed can be customized and skinned the way you want. You can easily extend the functionality to suit your requirements.  

If all this excites you, check out the tutorials [here](http://wiki.github.com/parolkar/pfeed "pfeed's Wiki") or explore some more advanced techniques [here](http://wiki.github.com/parolkar/pfeed/customizing-the-pfeed-item "pfeed customisation techniques")            


## Performance

*How efficient is feed generation and delivery?* 

  If your app has mechanisms for asynchronous processing, like delayed_job , pfeed plugin will automatically figure out  how to schedule the delivery in the queue so that your request loop remains efficient and workers can perform deliveries. [Find out more](http://wiki.github.com/parolkar/pfeed/pfeed-delivery-as-background-job "pfeed delivery as background job")  

## More Details

*What is feed?*
Feed is the collection of activity logs which is generated while you perform actions on model objects.

*Whats so special?, Why should I bother about it?*  

Imagine you want to create admin console for your app to monitor functional activities in your web apps ,i.e how users are using different parts of application. You will need to think of mechanism to capture the logs and then display in some logical manner.  

OR  

Imagine you are building an app like facebook and you want to capture all activity user is performing and display it to her friends/group member/admin , Its a whole new feature whose implementation will force you to dig into design of your app and see where all the logs get generated and then to whom all the logs are going to be published.  

What if I give you a generalized information model which will allow you to create such feature by keeping it completely isolated from your existing logic? and What if it is really scalable enough?  

(more content to come here...)  


## Installation

<pre>
<code>	
 $ rails plugin install git://github.com/parolkar/pfeed.git # or use script/plugin for older version of rails
 $ rake pfeed:setup 
</code>
</pre> 



Copyright (c) 2009 [Abhishek Parolkar] abhishek[at]parolkar.com , released under the MIT license
