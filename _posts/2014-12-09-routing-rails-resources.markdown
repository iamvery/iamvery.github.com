---
layout: post
title: Routing Rails Resources
---

Recently I had a conversation with a coworker about the routes in their app. It
turns out that they (an experienced Rails dev) had not seen nested resources
on collections rather than members. (If you don't know what that means, stay
tuned.) During our discussion I quickly realized I had some serious gaps in
my knowledge of Rails routing as well!.. TO THE INTERNET

![](/img/blog/2014/12/batman-spinning.gif)

## A Basic Resource

One of the simplest routes in a Rails app is a resource. A plural resource
generates 8 routes.

{% highlight diff %}
# in config/rountes.rb
resources :foos

# output of bin/rake routes:
Prefix Verb   URI Pattern              Controller#Action
    foos GET    /foos(.:format)          foos#index
         POST   /foos(.:format)          foos#create
 new_foo GET    /foos/new(.:format)      foos#new
edit_foo GET    /foos/:id/edit(.:format) foos#edit
     foo GET    /foos/:id(.:format)      foos#show
         PATCH  /foos/:id(.:format)      foos#update
         PUT    /foos/:id(.:format)      foos#update
         DELETE /foos/:id(.:format)      foos#destroy
{% endhighlight %}

You can restrict the generated routes by `:only` defining particular actions.
Let's use that option for the following examples to keep outputs to a minimum.

{% highlight diff %}
# in config/routes.rb
- resources :foos
+ resources :foos, only: :index

# output of bin/rake routes:
Prefix Verb   URI Pattern              Controller#Action
    foos GET    /foos(.:format)          foos#index
-          POST   /foos(.:format)          foos#create
-  new_foo GET    /foos/new(.:format)      foos#new
- edit_foo GET    /foos/:id/edit(.:format) foos#edit
-      foo GET    /foos/:id(.:format)      foos#show
-          PATCH  /foos/:id(.:format)      foos#update
-          PUT    /foos/:id(.:format)      foos#update
-          DELETE /foos/:id(.:format)      foos#destroy
{% endhighlight %}

## As

Depending on how familiar you are with Rails, you may not know what "Prefix"
means in the context of routing. These names correspond to Rails generated
[path helpers](http://guides.rubyonrails.org/routing.html#path-and-url-helpers).
So what if you want to customize the name of these helper methods?

{% highlight diff %}
# in config/routes.rb
- resources :foos, only: :index
+ resources :foos, only: :index, as: :bar

# output of bin/rake routes:
Prefix Verb   URI Pattern              Controller#Action
-     foos GET    /foos(.:format)          foos#index
+ bar_index GET    /foos(.:format)          foos#index
{% endhighlight %}

You'll notice that the prefix is now named after "bar" rather than "foo". One
tricky little detail is that the "index" path is no longer pluralized. Instead
it has an "\_index" suffix.

## Path

What if instead you want to change the URI for a particular resource without
affecting the generated path helpers and associated controller? CAN DO!

{% highlight diff %}
# in config/routes.rb
- resources :foos, only: :index
+ resources :foos, only: :index, path: :bar

# output of bin/rake routes:
Prefix Verb   URI Pattern              Controller#Action
-     foos GET    /foos(.:format)          foos#index
+     foos GET    /bar(.:format)           foos#index
{% endhighlight %}

Now the resource is accessed from "outside" the app by the URI `/bar`, but
internally it is still referred to as `foo`. Don't miss that the value of
`:path` is used exactly as the resource's path. It isn't pluralized for a
plural route.

## Controller

You can also customize the name the controller name of your resource.

{% highlight diff %}
# in config/routes.rb
- resources :foos, only: :index
+ resources :foos, only: :index, controller: :bar

# output of bin/rake routes:
Prefix Verb   URI Pattern              Controller#Action
-     foos GET    /foos(.:format)          foos#index
+     foos GET    /foos(.:format)          bar#index
{% endhighlight %}

You can see that this defines a route which expects a `BarController` to be
defined. It's also worth nothing that while the controller is (as always)
suffixed with "Controller", it does _not_ pluralize the given name for
plural resources.

## Module

Ruby programmers commonly use Ruby `Module` to namespace objects. By default all
resources are defined at the top level. You may still want to take advantage of
code organization by modules for your objects.

{% highlight diff %}
# in config/routes.rb
- resources :foos, only: :index
+ resources :foos, only: :index, module: :bar

# output of bin/rake routes:
Prefix Verb   URI Pattern              Controller#Action
-     foos GET    /foos(.:format)          foos#index
+     foos GET    /foos(.:format)          bar/foos#index
{% endhighlight %}

If you're not familiar with the output of the Rails `routes` rake task, it may
not be immediately obvious what's going on here. But the short of it is that
the controller must now we "namespaced" by a `Bar` Module. So the relevant
controller would be `Bar::FoosController`. Conveniently the URI pattern and
"prefix" (which corresponds to [path helpers](http://guides.rubyonrails.org/routing.html#path-and-url-helpers))
are not affected by this option. Sweet.

## Namespace

Commonly enough it is desirable to "prefix" path helpers, URI, and the
controller with an identifier. One example of such might be "nesting" a number
of resources in an "admin" namespace.

{% highlight diff %}
# in config/routes.rb
- resources :foos, only: :index
+ namespace :bar do
+   resources :foos, only: :index
+ end

# output of bin/rake routes:
Prefix Verb   URI Pattern              Controller#Action
-     foos GET    /foos(.:format)          foos#index
+ bar_foos GET    /bar/foos(.:format)      bar/foos#index
{% endhighlight %}

This is the first "block style" routing directive that you're seeing. Route
namespaces are specified by calling the `namespace` method with a block
defining the namespaced resources. If you only wish to namespace a single
resource, it might be tempting to pass a `:namespace` option to your resource.
Be warned! It doesn't work as you might expect.

# Nested Resources

It is often desirable to design routes based on the relations that exist
in your model. For example, if you wanted to get all comments made by a user
you might expect the route for this resource to exist at `/users/jay/comments`.

## A Basic Nested Resource

As a baseline here is the most basic nested resource. Much like the basic
resource, a suite of routes is defined for each resource.

{% highlight diff %}
# in config/routes.rb
resources :foos do
  resources :bars
end

# output of bin/rake routes:
      Prefix Verb   URI Pattern                           Controller#Action
    foo_bars GET    /foos/:foo_id/bars(.:format)          bars#index
             POST   /foos/:foo_id/bars(.:format)          bars#create
 new_foo_bar GET    /foos/:foo_id/bars/new(.:format)      bars#new
edit_foo_bar GET    /foos/:foo_id/bars/:id/edit(.:format) bars#edit
     foo_bar GET    /foos/:foo_id/bars/:id(.:format)      bars#show
             PATCH  /foos/:foo_id/bars/:id(.:format)      bars#update
             PUT    /foos/:foo_id/bars/:id(.:format)      bars#update
             DELETE /foos/:foo_id/bars/:id(.:format)      bars#destroy
        foos GET    /foos(.:format)                       foos#index
             POST   /foos(.:format)                       foos#create
     new_foo GET    /foos/new(.:format)                   foos#new
    edit_foo GET    /foos/:id/edit(.:format)              foos#edit
         foo GET    /foos/:id(.:format)                   foos#show
             PATCH  /foos/:id(.:format)                   foos#update
             PUT    /foos/:id(.:format)                   foos#update
             DELETE /foos/:id(.:format)                   foos#destroy
{% endhighlight %}

That's a ton of routes for 3 lines. You will notice that the "nested" resource
establishes routes "beneath" individual "parent" resources. Also as you might
have expected, you get 16 routes. 8 for each resource. In effort to keep noise
to a minimum, you will use the `only: :index` option from here on.

## Module

You may not have caught the detail that "bars", while indeed nested in the path
helper and URI, were _not_ namespaced at the controller. Grab the familiar
`module` option to nest the controller.

{% highlight diff %}
# in config/routes.rb
resources :foos, only: :index do
-  resources :bars, only: :index
+  resources :bars, only: :index, module: :baz
end

# output of bin/rake routes:
      Prefix Verb   URI Pattern                           Controller#Action
-    foo_bars GET    /foos/:foo_id/bars(.:format)          bars#index
+    foo_bars GET    /foos/:foo_id/bars(.:format)          baz/bars#index
        foos GET    /foos(.:format)                       foos#index
{% endhighlight %}

Perhaps the contrived nature of the example doesn't do the behavior justice,
but you may run into a case for this eventually.

## Collection

Above I mentioned that the nested resource is under an individual "member"
(instance) of the parent resource. So what if we wanted to nest under the
"collection"?

{% highlight diff %}
# in config/routes.rb
resources :foos, only: :index do
-  resources :bars, only: :index
+  controller do
+    resources :bars, only: :index
+  end
end

# output of bin/rake routes:
      Prefix Verb   URI Pattern                           Controller#Action
-    foo_bars GET    /foos/:foo_id/bars(.:format)          bars#index
+    foo_bars GET    /foos/bars(.:format)                  bars#index
        foos GET    /foos(.:format)                       foos#index
{% endhighlight %}

Now the resource is nested beneath the Foos' index action as opposed to an
individual Foo record. Similar to the `namespace` method, `collection` _only_
works as expected in the block form. Confusingly, you may specify an `on:
:collection` option for the nested resource, but the behavior is not as
expected.

## Other Options

Additional resource options, such as `:path` and `:as`, also work with nested
resources. You should note, however, that Rails still prefixes paths and
helpers with the parent resource.

{% highlight diff %}
# in config/routes.rb
resources :foos, only: :index do
-  resources :bars, only: :index
+  resources :bars, only: :index, as: :baz, path: qux
end

# output of bin/rake routes:
      Prefix Verb   URI Pattern                           Controller#Action
-    foo_bars GET    /foos/:foo_id/bars(.:format)          bars#index
+    foo_baz  GET    /foos/:foo_id/qux(.:format)           bars#index
        foos GET    /foos(.:format)                       foos#index
{% endhighlight %}

# But wait, there's more!

There's always more. Routing can be very complicated. There are a lot of
options, so covering all their possible combinations would be exhausting. We
didn't even talk about [constraints](http://guides.rubyonrails.org/routing.html#specifying-constraints).
Take some time to explore the options and be creative when defining routes.
You will likely run into cases where you want to model them in a specific way.
Chances are you are able to accomplish what you want to. If you have to much
difficulty your design may be smelling. Seek some advise from a peer!

Good luck routing! Let me know if the comments if anything is unclear or
glaringly missing.
