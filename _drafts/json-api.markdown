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
      "id": 1,
      "type": "articles",
      "attributes": {
        "title": "Ohai, JSON API!"
      },
      "relationships": {
        "author": {
          "links": {
            "self": "/articles/1/relationships/author",
            "related": "/articles/1/author"
          },
          "data": { "type": "people", "id": 2 }
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
    "id": 1,
    "type": "articles",
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

## But wait, there's more!


[json-api]: http://jsonapi.org/
[doc-structure]: http://jsonapi.org/format/#document-structure
[json-api-type]: http://www.iana.org/assignments/media-types/application/vnd.api+json
[resource-obj]: http://jsonapi.org/format/#document-resource-objects
[attributes-obj]: http://jsonapi.org/format/#document-resource-object-attributes
[relationships-obj]: http://jsonapi.org/format/#document-resource-object-relationships
