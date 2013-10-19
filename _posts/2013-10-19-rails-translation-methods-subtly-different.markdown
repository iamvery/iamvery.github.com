---
layout: post
title: Rails' `translate` methods are subtly different
---

**TL;DR** - `I18n.translate` and the `translate` view helper are not created equal.

Working on a Rails app this week, I discovered a subtle difference in the Rails
`translate` view helper method and `I18n.translate` proper. The tricky
difference is that the view helper method actually provides
[additional functionality](http://api.rubyonrails.org/classes/ActionView/Helpers/TranslationHelper.html#method-i-translate).

Check this out:

{% gist 7057588 %}

Notice the types for each returned value. Is that what you expected? As it
turns out, only the view helper method is able
to detect HTMLy translation keys. This is documented behavior, but admittedly
it's rather unexpected. Rather than proposing modifications to the API, I opted
to update the [Rails Guides](http://guides.rubyonrails.org/) to be a little more
explicit about this difference. [Check out my contribution](https://github.com/rails/docrails/commit/da1d2fb483b521419ce6c350bc6a5721266c0fc6#commitcomment-4375238)
and let me know what you think!
