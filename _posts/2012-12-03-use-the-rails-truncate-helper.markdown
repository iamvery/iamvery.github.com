---
layout: post
title: Use Rails' truncate helper!
---

> **TL;DR**: Ever wanted to cut a long string down to something like "This is the song that n..."? Use Rails' `truncate` helper!

_Warning_: This is my first blog! Exciting, yes! But you'll have to bear with my rambling as I get used to
the process. :)

The other day I ran into the mundane issue of having a record's `title` attribute exceed the width that a
[Twitter Bootstrap](http://twitter.github.com/bootstrap/) tooltip could display. I quickly threw together 
some helper methods that would trim excessive `title`s down to size:

{% highlight ruby %}
class Article
  MAX_SHORT_TITLE_LENGTH = 10
  SHORT_TITLE_SUFFIX = '...'

  def title
    'The longest title imaginable.'
  end

  def short_title
    if long_title?
      "#{title[0...short_title_length]}#{SHORT_TITLE_SUFFIX}"
    else
      title
    end
  end

  def long_title?
    title.length > MAX_SHORT_TITLE_LENGTH
  end

  def short_title_length
    MAX_SHORT_TITLE_LENGTH - SHORT_TITLE_SUFFIX.length
  end
end
{% endhighlight %}

Along with it's specs, I was quite pleased with my solution. So much so I thought to myself "Ah hah! I
should write a small gem to easily add this functionality to other projects!" Then it hit me. Such a 
common problem is likely already solved...

And there it was [`ActiveView::Helpers::TextHelper#truncate`](http://api.rubyonrails.org/classes/ActionView/Helpers/TextHelper.html#method-i-truncate).
The exact functionality I was (re)implementing. Don't miss out on this little helper! Its simple:

{% highlight ruby %}
# In your view or helper
truncate(article.title, :length => 10) # => 'The lon...'
{% endhighlight %}
