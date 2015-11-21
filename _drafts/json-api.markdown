---
layout: post
title: JSON API
excerpt: JSON API is a specification for building APIs on the web.
description: JSON API is a specification for building APIs on the web.
---

[JSON API][json-api] is a specification for building APIs on the web.
When designing an API that communicates via JSON, developers often get tangled in the minutia of how requests and responses with be formed.
Significant time may be spend belaboring precisely how the JSON will be formed and even then minor discrepancies may crop up between contributions from different people.
JSON API addresses these issues by establishing a format and semantic specification that everyone can agree on.

## Beyond Serialization

At this point, you may think of JSON API as nothing more than a data format for your requests.
It goes beyond that to define additional semantics about your APIs, such as:

* HTTP status codes
* Filtering
* Sorting
* Pagination
* Eager-Loading Relationships
* MOAR?

By ensuring these additional semantics, consumers of JSON API can quickly navigate and discover behavior.
Actually, for GET requests it's quite a breeze to navigate in your browser by simply following relationship links!

## Format

JSON API defines a [document structure][doc-structure] to be used in all requests and responses.

The top-level **MUST** be a JSON object. i.e. `{...}`. No arrays!
Generally speaking, arrays limit the extensibility of the response.
This means if you were to respond with an array now, you would break any existing clients later if you needed to include additional information.
Here's a basic JSON API response you might receive from a GET request to a theoretical resource `/articles`.
The specification requires that you make all requests with the JSON API media type [`application/vnd.api+json`][json-api-type].


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

#### Collection

```
{% highlight json %}
{
  "data": [...]
}
{% endhighlight %}
```

The request returns a collection of articles.
This makes good sense given that the request was to a collection resource, namely `/articles`.

#### Resource Object

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

#### Attributes Object

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

#### Relationship Object

```
{% highlight json %}
    "relationships": {
      ...
    }
{% endhighlight %}
```

Finally, this is a ["relationship object"][relationship-obj].
Generally speaking, these are associations between resources.
They many be one-to-one or one-to-many.
Our `author` relationship is one-to-one as an article may only have one author.

There are many other types of objects specified in the [document structure][doc-structure].
You should definitely read through it closely in training for _The Great Shedding War at Bikes Place_.

## Semantics

Semantics are a very important part of JSON API.
Without them, all you have is a JSON format.
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

You may notice that all eager-loaded resources are stowed away in the `included` member.
This is done to minimize duplication in the relationship objects.
If a record is loaded more than once, its reference (id and type) might appear several times, but it would only be included one time.

### Sort

Maybe you detect a pattern here.
GET `/articles?sort=title` responds with a collection of articles sorted by their title.
Boom.

### Extensions

You should know, the standard is meant to be extended.
It's written as a baseline, but at a certain point your API may need additional semantics.
You might create your own media type based on JSON API for your needs.
Check out some of the existing [extensions][extensions].

## Other things...

### Caching

Caching is a complex subject, but you should know that JSON API was designed with cachability in mind.
For example, links are modeled as resource types and ids.
As such one may cache responses containing links to other resources even when those reference resources attributes themselves change (the id would never change).

### Documentation

Documenting APIs can be pretty tough.
The tooling isn't always great, and it's a quite laborious in general.
The great thing about adopting a standard such as JSON API is that you only need to document _your semantics_.
For a simple API that might mean noting attributes and relationships.
Everything else is just a simple link to [the specification][format].

## But wait, there's more!

This is a brief overview of a very large subject.
There is a ton of good there, and maybe even room for you to improve it!
So what are you waiting for?


[json-api]: http://jsonapi.org/
[doc-structure]: http://jsonapi.org/format/#document-structure
[json-api-type]: http://www.iana.org/assignments/media-types/application/vnd.api+json
[resource-obj]: http://jsonapi.org/format/#document-resource-objects
[attributes-obj]: http://jsonapi.org/format/#document-resource-object-attributes
[relationship-obj]: http://jsonapi.org/format/#document-resource-object-relationships
[filtering]: http://jsonapi.org/format/#fetching-filtering
[format]: http://jsonapi.org/format/
[extensions]: http://jsonapi.org/extensions/
