---
layout: post
title: JSON API
excerpt: JSON API is a specification for building APIs on the web.
description: JSON API is a specification for building APIs on the web.
---

[JSON API][json-api] is a specification for building APIs on the web.
When designing an API that communicates via JSON, developers often get tangled in the minutia of how responses with be formed.
Significant time and resources may be spend belaboring precisely how the JSON will be formed and even then minor discrepancies may crop up between contributions from different people.
JSON API addresses these issues by establishing a specification that everyone can agree on.
The JSON API team likes to call it an "anti-bikeshedding weapon".

## Beyond Serialization

At this point, you may think of JSON API as nothing more than a data format for your requests.
It goes beyond that to define additional semantics about your APIs, such as:

* HTTP status codes
* Filtering
* Sorting
* Pagination
* Eager-Loading Relationships
* MOAR?

By ensuring these additional semantics users of a JSON API can quickly navigate the API and discover behavior.
Actually, for GET requests it's quite a breeze to navigate in your browser by simply following relationship links!

## Format

JSON API defines a [document structure][doc-structure] to be used in all requests and responses.

The top-level **MUST** be a JSON object. i.e. `{...}`. No arrays!
Generally speaking, arrays limit the extensibility of the response.
This means if you were to respond with an array now, you would break any existing clients later if you needed to include additional information.
Here's a basic JSON API response you might receive from a GET request to a theoretical resource `/articles`\*:

```json
{% highlight json %}
{
  "data": [
    {
      "type": "articles",
      "id": "1",
      "attributes": {
        "title": "Ohai, JSON API!"
      },
      "relationships": {
        "author": {
          "links": {
            "self": "/articles/1/relationships/author",
            "related": "/articles/1/author"
          },
          "data": { "type": "people", "id": "2" }
        }
      }
    }
  ]
}
{% endhighlight %}
```

Let's break this down.

```
{% highlight json %}
{
  "data": [...]
}
{% endhighlight %}
```

The request returns a collection of articles.
This makes good sense given that the request was to a collection resource, namely `/articles`.

```
{% highlight json %}
  {
    "type": "articles",
    "id": "1",
    ...
  }
{% endhighlight %}
```

As it turns out, this section is called a ["resource object"][resource-obj], and `id` and `type` are the two **required** members.

```
{% highlight json %}
    "attributes": {
      ...
    }
{% endhighlight %}
```

This is an ["attributes object"][attributes-obj].
Simply put, this is the data for a resource (excluding relationships).
Our articles have a single `title` field.

```
{% highlight json %}
    "relationships": {
      ...
    }
{% endhighlight %}
```

Finally, this is a ["relationships object"][relationships-obj].
Generally speaking, these are associations between resources.
They many be one-to-one or one-to-many.
Our `author` relationship is one-to-one as an article may only have one author.

There are many other types of objects specified in the [document structure][doc-structure].
You should definitely read through it closely in training for _The Great Shedding War at Bikes Place_.

\***Note**: The specification requires that you make all requests with the JSON API media type [`application/vnd.api+json`][json-api-type].

## Semantics

Semantics are a very important part of JSON API.
Without them, all you have is a JSON format.
That isn't very interesting!
The various semantics of JSON API are too many to mention here, but here are some good ones that'll keep you out of the shed.

### Filter

The specification is intentionally vague on this, but it reserves the `filter` query parameter for [filtering requested resources][filtering].
Your service's implementation might allow you to specify a filter to locate people by their age.
A GET request to `/people?filter[age]=20` would return all 20 year olds, but what does age have to do with anything?

### Include

To keep the number of requests being made to the API at a minimum, you might opt to eager-load resources in a single request.
Let's go back to our articles example.
If you wanted to request articles and their corresponding authors, you would set a GET request to `/articles?include=author`.
The response would look something like this.

```json
{% highlight json %}
{
  "data": [
    {
      "type": "articles",
      "id": "1",
      ...,
      "relationships": {
        "author": {
          ...,
          "data": { "type": "people", "id": "2" }
        }
      }
    }
  ],
  "included": [
    {
      "type": "people",
      "id": "2",
      "attributes": {
        "name": "Jay Hayes"
      }
    }
  ]
}
{% endhighlight %}
```

### Sort

Maybe you detect a pattern here. This is straightforward!
GET `/articles?sort=title` responds with a collection of articles sorted by their title.

## But wait, there's more!

So much more... You really should take time to get familiar with [the format][format].
There is a ton of good there, and maybe even room for you to improve it!
So what are you waiting for?


[json-api]: http://jsonapi.org/
[doc-structure]: http://jsonapi.org/format/#document-structure
[json-api-type]: http://www.iana.org/assignments/media-types/application/vnd.api+json
[resource-obj]: http://jsonapi.org/format/#document-resource-objects
[attributes-obj]: http://jsonapi.org/format/#document-resource-object-attributes
[relationships-obj]: http://jsonapi.org/format/#document-resource-object-relationships
[filtering]: http://jsonapi.org/format/#fetching-filtering
[format]: http://jsonapi.org/format/
