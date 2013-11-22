---
layout: post
title: Boolean Method Symmetry
---

Symmetry is beauty. This applies to lots of things, programming included.

Boolean methods answer a question with "yes" or "no". To adequately test such a
method, you must assert on the positive and negative cases. Chances are you'll
want the complementary method eventually, so let's start with symmetry and see
where it takes us.

## People, be active!

Let's say we have a `Person` class as follows:

{% highlight ruby %}
Person = Struct.new(:awake, :moving)
{% endhighlight %}

We're presented with a feature that states a `Person` should be able to report
if they are active. Let's start with a spec:

{% highlight ruby %}
describe Person do
  describe '#active?' do
    it 'is true when they are awake and moving' do
      person = described_class.new(true, true)

      expect(person).to be_active
    end
  end
end
{% endhighlight %}

And now for a _very_ high-value implementation:

{% highlight ruby %}
Person = Struct.new(:awake, :moving) do
  def active?
    true
  end
end
{% endhighlight %}

Yay! All green :). But, ahem, not exactly feature complete. Alright, so we
should probably test the negative case. At this point we're presented with
a choice. Do we test the negative cases of `active?` or introduce the
complementary method `inactive?`. We'll choose symmetry:

{% highlight ruby %}
describe Person do
  describe '#active?' do
    # ...
  end

  describe '#inactive?' do
    it 'is true when they are asleep' do
      person = described_class.new(false, true)

      expect(person).to be_inactive
    end

    it 'is true when they are still' do
      person = described_class.new(true, false)

      expect(person).to be_inactive
    end
  end
end
{% endhighlight %}

Cool, these new specs are erroring with a `NoMethodError`. We'll implement
this complementary method as a function of `active?`:

{% highlight ruby %}
Person = Struct.new(:awake, :moving) do
  def active?
    true
  end

  def inactive?
    !active?
  end
end
{% endhighlight %}

Nice, we see a properly failing spec. The final implementation is straight forward
(althrough if we're practicing TDD, we may get there in a couple steps):

{% highlight ruby %}
Person = Struct.new(:awake, :moving) do
  def active?
    awake && moving
  end

  def inactive?
    !active?
  end
end
{% endhighlight %}

Alright, so what have we accomplished? We have implemented a simple boolean method
along with its complement, and we done this with tests providing adequate coverage
for both methods. The complementary method could be argued YAGNI ("You ain't
gonna need it"), but in most cases you'll end up negating your method. Having a
complementary method feels symmetric... and beautiful. Further our specs
cover the implementation well without duplication.

## Wrapping up

Symmetry not only looks good, it makes logical sense to client developers and
makes your test suite more expressive. When you encounter a boolean method you
probably assume its logical complement is defined. Perhaps in this case YAGNI
may be set aside for expressiveness.

How do you feel about symmetry? How important is it to the interfaces you define?
