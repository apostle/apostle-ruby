# Apostle Ruby
[![Build Status](https://travis-ci.org/apostle/apostle-ruby.png?branch=master)](https://travis-ci.org/apostle/apostle-ruby)
[![Gem Version](https://badge.fury.io/rb/apostle.png)](http://badge.fury.io/rb/apostle)

Ruby bindings for [Apostle.io](http://apostle.io)

## Rails
If you're using Rails, you should know that [apostle-rails](https://github.com/apostle/apostle-rails) exists. Knowledge of this Gem is still important however, as `apostle-rails` will bring this gem along for the ride.

## Installation

Add this line to your application's Gemfile:

    gem 'apostle'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install apostle

## Domain Key

You will need to provide your apostle domain key to send emails. Apostle looks in `ENV['APOSTLE_DOMAIN_KEY']`, or you can set it manually.

```ruby
Apostle.configure do |config|
	config.domain_key = 'Your domain key'
end
```

## Sending Email

Sending an email is easy. A minimal email might look like this.

```ruby
Apostle::Mail.new('welcome_email', email: "mal@mal.co.nz").deliver!
```
The first param `Apostle::Mail` expects is the template slug, and the second is a hash of mail information.

### Adding data

You can assign any data you want, and it will be passed to the API for hydrating your template. If you had a template that required `{{username}}`, you could send them like this:

```ruby
mail = Apostle::Mail.new('welcome_email', email: 'mal@mal.co.nz', username: 'Snikch').deliver!
```

You can also set any data directly on the mail object.

```ruby
mail = Apostle::Mail.new('welcome_email')
mail.email = 'mal@mal.co.nz'
mail.username = 'Snikch'
mail.deliver!
```

### Setting name

In addition to the email, you can provide the name to be used in the `to` field of the email.

```ruby
Apostle::Mail.new('welcome_email', email: "mal@mal.co.nz", name: "Mal Curtis").deliver!
# Sends email with "to: Mal Curtis <mal@mal.co.nz>"
```

### Setting from address

Although the `from` address is set up in your template, you can override that for any individual email, or provide a reply to address.

```ruby
mail.from = 'support@example.com'
mail.reply_to = 'noreply@example.com'
```

### Adding Cc and Bcc

You can add Cc and Bcc with the Apostle mail object. 

```ruby
mail.cc = 'samplecc@example.com'
mail.bcc = 'samplebcc@example.com'
```

It also supports adding multiple emails to Cc and Bcc as an array, 

```ruby
mail.cc = ['email1@example.com', 'email2@example.com']
mail.bcc = ['sample1@example.com', 'sample2@example.com']
```

### Additional Headers

You can provide custom headers to be sent with your email via `#header`.

```ruby
# Set
mail.header 'X-Some-Header', 'my custom header'

# Get
mail.header 'X-Some-Header'
=> "my custom header"
```

### Attachments

You can send attachments by adding to attachments hash on the mail object.

```ruby
mail.attachments["invoice.pdf"] = File.read("invoices/12345.pdf")
```



## Sending Multiple Emails

To speed up processing, you can send more than one email at a time.

```ruby
queue = Apostle::Queue.new

3.times do |count|
	queue << Apostle::Mail.new("welcome_email", email: "user#{count}@example.com")
end

queue.deliver!
```

If any of the emails are invalid this will raise an exception and no emails will be sent; i.e. missing a template slug, or delivery address.

You can either catch `Apostle::DeliveryError`, or call the safer `#deliver`, then access a hash of results on the queue via `#results`.

```ruby
queue = Apostle::Queue.new

queue << Apostle::Mail.new("welcome_email", email: "mal@mal.co.nz")
queue << Apostle::Mail.new("welcome_email")

queue.deliver
=> false

queue.results
=> {
	:valid=>[#<Apostle::Mail:0x007fcee5ab2550>],
	:invalid=>[#<Apostle::Mail:0x007fcee5ab23c0>]
}
queue.results[:invalid].first._exception
=> #<Apostle::DeliveryError @message="No recipient provided">
```

### Helpers

You have access to `#size` and `#clear` on the queue. You can use this to group requests.

```ruby
users.each do |user|
	queue << Penpan::Mail.new('welcome', email: user.email)
	if queue.size == 1000
		queue.deliver
		queue.clear
	end
end
```

Or use the helper method `#flush`, which does exactly this, calls `#deliver` then `#clear` if delivery succeeds.

```ruby
users.each do |user|
	queue << Penpan::Mail.new('welcome', email: user.email)
	if queue.size == 1000
		queue.flush
	end
end
```

## Delivery Failure

If delivery to Apostle fails, an exception will be raised. There are various events that could cause a failure:

* `Apostle::Unauthorized`: The domain key was not provided, or valid
* `Apostle::UnprocessableEntity`: The server returned a 422 response. Check the content of the message for more details, but this will likely be a validation / content error
* `Apostle::ServerError`: Something went wrong at the Apostle API, you should try again with exponential backoff
* `Apostle::Forbidden`: The server returned a 403 response. This should not occur on the delivery API
* `Apostle::DeliveryError`: Anything which isn't covered by the above exceptions


## Who
Created with ♥ by [Mal Curtis](http://github.com/snikch) ([@snikchnz](http://twitter.com/snikchnz))


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
