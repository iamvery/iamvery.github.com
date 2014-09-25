---
author: Jay Hayes
date: 2014-04-16 22:18:44+00:00
excerpt: 'When you create an application programming interface (API), you’re establishing
  a contract with everyone who uses it. This too is true for web service APIs. As
  soon as someone begins using an API, changes require coordination between all clients
  in order to prevent breakage, costing precious time and money.


  Rails API versioning to the rescue: In order to allow breaking changes to an interface,
  we can version it so that clients may specify exactly what representation they expect
  for their requests. Then they are able to decide for themselves when it is time-
  and cost-effective to upgrade their dependency.'
layout: post
title: Adding Versions to a Rails API
wordpress_id: 4733
categories:
- Ruby on Rails
---

Originally posted on the [Big Nerd Ranch Blog](http://www.bignerdranch.com/blog/adding-versions-rails-api).

---

When you create an [application programming interface](http://en.wikipedia.org/wiki/Application_programming_interface) (API), you’re establishing a contract with everyone who uses it. This too is true for [web service](http://en.wikipedia.org/wiki/Web_service) APIs. As soon as someone begins using an API, changes require coordination between all clients in order to prevent breakage, costing precious time and money.

Rails API versioning to the rescue: In order to allow breaking changes to an interface, we can version it so that clients may specify exactly what representation they expect for their requests. Then they are able to decide for themselves when it is time- and cost-effective to upgrade their dependency.


### An Example API


**Note**: Each heading in this walkthrough will have one or more accompanying commits. You can work through it yourself or [follow along on Github](https://github.com/iamvery/rails-api-example).

As a baseline for this post, we’ll consider a very simple, contrived API. This API has only one resource: `/articles`. You can grab a copy of the example by cloning it from Github and setting up as follows.

Clone the repo:

{% highlight bash %}
$ git clone git@github.com:iamvery/rails-api-example.git
$ cd rails-api-example
{% endhighlight %}


Checkout the repo in its “initial” state, before versions are implemented:

{% highlight bash %}
$ git checkout -b starting-point initial-api-implementation
{% endhighlight %}


Install dependencies, watch specs pass:

{% highlight bash %}
$ bundle install
$ bin/rspec
... 0 failures
{% endhighlight %}

Once you’ve got the project set up, let’s run the local server and see what the [article](https://github.com/iamvery/rails-api-example/blob/7b664c797e1e896f84abcc377e5c507a161f4d31/app/controllers/articles_controller.rb) response looks like.

Run the local rails server:

{% highlight bash %}
# Do this in a separate window so you can keep it around
$ bin/rails server
{% endhighlight %}


Make a request for the articles’ JSON representation:

{% highlight bash %}
$ curl http://localhost:3000/articles.json
[{"id":123,"name":"The Things"}]
{% endhighlight %}




### Versioning is a Thing


At this point, our API has a single, unversioned articles resource. As a first step, we’ll introduce versioning as an [internet media type](http://en.wikipedia.org/wiki/Internet_media_type) parameter.


#### Namespaces (commit [`b21a0a91`](https://github.com/iamvery/rails-api-example/commit/b21a0a918c65892376ccbebaf96057051795afc0))


Namespacing is a great way to keep code organized. We’ll wrap our existing controller in a `V1` module to establish our “version 1.”

Move `app/controllers/articles_controller.rb` to `app/controllers/v1/articles_controller.rb` and wrap the class in a module.

<script src="https://gist.github.com/iamvery/10328874.js"></script>

Since we don’t want to affect our URI structure for the resource, we can use the `:module` scope to namespace the controller and not the URI.

<script src="https://gist.github.com/iamvery/10328982.js"></script>


#### Route Constraint (commits [`5d304f19`](https://github.com/iamvery/rails-api-example/commit/5d304f1983107c4cb609d83a5b6b209ba4064287) and [`0ec91c6c`](https://github.com/iamvery/rails-api-example/commit/0ec91c6c6cce5113b7f9e1d9484a3f2d94936ad5))


Next we need to tell Rails how to route requests for different versioned representations. We can do this effectively by using a [route constraint](http://guides.rubyonrails.org/routing.html#advanced-constraints) that checks for a version specified in the request’s `accept` header.

<script src="https://gist.github.com/iamvery/10329040.js"></script>

We can use this constraint to route requests based on the version specified in the request’s `accept` header.

<script src="https://gist.github.com/iamvery/10329098.js"></script>

With this change, we now must specify the desired version in the request’s headers to get the desired response. If your development server is still running at this point, it will probably need to be restarted.

{% highlight bash %}
$ curl -H "accept: application/json; version=1" http://localhost:3000/articles
[{"id":123,"name":"The Things"}]
{% endhighlight %}




#### Version 2 (commit [`5bd29d0b`](https://github.com/iamvery/rails-api-example/commit/5bd29d0bb92c10c3884b1f5aa8fac0886e1f0205))


Now that we have namespaces for our versioned controllers and constraints for routing, we can introduce a version 2 articles representation. Version 2 will wrap the response in a root node. This representation is not backwards compatible with the version 1 representation, thus requiring a new versioned representation.

<script src="https://gist.github.com/iamvery/10329142.js"></script>

<script src="https://gist.github.com/iamvery/10329174.js"></script>

We can request the version 2 representation as well as version 1:llows.

{% highlight bash %}
$ curl -H "accept: application/json; version=2" http://localhost:3000/articles
{"articles":[{"id":123,"name":"The Things"}]}

$ curl -H "accept: application/json; version=1" http://localhost:3000/articles
[{"id":123,"name":"The Things"}]
{% endhighlight %}




### Version Representations, Not Locations


I was first tuned to this idea by a [post from Steve Klabnik](http://blog.steveklabnik.com/posts/2011-07-03-nobody-understands-rest-or-http#i_want_my_api_to_be_versioned) about REST and HTTP. Later I dug a little deeper and found a [long answer](http://stackoverflow.com/a/398564) on StackOverflow that goes into more detail. The prevaling sentiment is:


> resource URIs that API users depend on should be permalinks


This cannot be true if the version is included in the URI, which changes over time. Using Klabnik’s suggestion, we push this knowledge into the request headers and keep URIs permanent for all future representations of our resources.


### Internet Media Types


The above example deals only in the `application/json` media type. The idea of “versioning” doesn’t apply very well to the generic “json” type. That is, it doesn’t make good sense to say, “Here you’re seeing version 1 json, and over here we have version 2 json.” For that reaso,n it may be desirable to create a custom [vendor media type](http://en.wikipedia.org/wiki/Internet_media_type#Vendor_tree) to represent our app’s responses.


#### The Type (commit [`dbbf6ea7`](https://github.com/iamvery/rails-api-example/commit/dbbf6ea77c433937da41e466b6bf2266a0d8cfd1))


First we register a new type with Rails and give it a name.

<script src="https://gist.github.com/iamvery/10435700.js"></script>


#### Responding (commit [`17b85059`](https://github.com/iamvery/rails-api-example/commit/17b850599f2546600475b3a525e71c3afff0abbe))


Now we can adjust our resource to respond to our custom type.

<script src="https://gist.github.com/iamvery/10435853.js"></script>

With this change we can now make requests of our custom type.

{% highlight bash %}
$ curl -H "accept: application/vnd.articles+json; version=2" http://localhost:3000/articles
{"articles":[{"id":123,"name":"The Things"}]}

$ curl -H "accept: application/vnd.articles+json; version=1" http://localhost:3000/articles
[{"id":123,"name":"The Things"}]
{% endhighlight %}




#### Bonus: URI Format Suffixes (commit [`323fe034`](https://github.com/iamvery/rails-api-example/commit/323fe034d4135a9a2aaa5b801509eb7c6fc38b7b))


You may have noticed that I stopped using format suffixes for requests early in the post (e.g., `/articles.json`). This was done intentionally so that we could arrive at custom media types. It is, however, somewhat common to include such suffixes for requested resources. Unfortunately, Rails becomes confused into thinking that we’re requesting pure JSON rather than our “articles flavored JSON.” We can address this by responding to both formats.

<script src="https://gist.github.com/iamvery/10436242.js"></script>

Now we can make request including the suffix.

{% highlight bash %}
$ curl -H "accept: application/vnd.articles+json; version=2" http://localhost:3000/articles.json
{"articles":[{"id":123,"name":"The Things"}]}

$ curl -H "accept: application/vnd.articles+json; version=1" http://localhost:3000/articles.json
[{"id":123,"name":"The Things"}]
{% endhighlight %}


There is one caveat. The content type of the response will be `application/json` rather than our custom type. I provide a little more information in my [commit notes](https://github.com/iamvery/rails-api-example/commit/323fe034d4135a9a2aaa5b801509eb7c6fc38b7b).


### Conclusion


Versioning code is a Good Thing™. It allows us to continue to extend our APIs without breaking compatibility for existing users. Introducing API versions after a release may be a little painful, but it’s doable.
