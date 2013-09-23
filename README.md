# Penpal

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'penpal'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install penpal

## Sending Email

Sending an email is easy. A minimal email might look like this.

```ruby
Penpal::Mail.new('welcome_email', email: "mal@mal.co.nz").deliver!
```
The first param `Penpal::Mail` expects is the template slug, and the second is a hash of mail information.

### Adding data

You can assign any data you want, and it will be passed to the API for hydrating your template. If you had a template that required `{{username}}`, you could send them like this:

```ruby
mail = Penpal::Mail.new('welcome_email', email: 'mal@mal.co.nz', username: 'Snikch').deliver!
```

You can also set any data directly on the mail object.

```ruby
mail = Penpal::Mail.new('welcome_email')
mail.email = 'mal@mal.co.nz'
mail.username = 'Snikch'
mail.deliver!
```

### Setting name

In addition to the email, you can provide the name to be used in the `to` field of the email.

```ruby
Penpal::Mail.new('welcome_email', email: "mal@mal.co.nz", name: "Mal Curtis").deliver!
# Sends email with "to: Mal Curtis <mal@mal.co.nz>"
```

### Setting from address

Although the `from` address is set up in your template, you can override that for any individual email, or provide a reply to address.

```ruby
mail.from = 'support@example.com'
mail.reply_to = 'noreply@example.com'
```


### Additional Headers

You can provide custom headers to be sent with your email via `#header`.

```ruby
mail.header 'X-Some-Header', 'my custom header'
mail.header 'X-Some-Header'
=> "my custom header"
```

## Sending Multiple Emails

To speed up processing, you can send more than one email at a time.

```ruby
queue = Penpal::Queue.new

3.times do |count|
	queue << Penpal::Mail.new("welcome_email", email: "user#{count}@example.com")
end

queue.deliver!
```

If any of the emails are invalid this will raise an exception and no emails will be sent; i.e. missing a template slug, or delivery address.

You can either catch `Penpal::DeliveryError`, or call the safer `#deliver`, then access a hash of results on the queue via `#results`.

```ruby
queue = Penpal::Queue.new

queue << Penpal::Mail.new("welcome_email", email: "mal@mal.co.nz")
queue << Penpal::Mail.new("welcome_email")

queue.deliver
=> false

queue.results
=> {
	:valid=>[#<Penpal::Mail:0x007fcee5ab2550>],
	:invalid=>[#<Penpal::Mail:0x007fcee5ab23c0>]
}
queue.results[:invalid].first._exception
=> #<Penpal::DeliveryError @message="No recipient provided">
```

### Helpers

You have access to `size` and `clear` on the queue. You can use this to group requests.

```
users.each do |user|
	queue << Penpan::Mail.new('welcome', email: user.email)
	if queue.size == 1000
		queue.deliver
		queue.clear
	end
end
```

Or use the helper method `flush`, which does exactly this, calls `deliver` then `clear` if delivery succeeds.

```
users.each do |user|
	queue << Penpan::Mail.new('welcome', email: user.email)
	if queue.size == 1000
		queue.flush
	end
end
```

## Delivery Failure

If delivery to Penpal fails, an exception will be raised. There are various events that could cause a failure:

* `Penpal::Unauthorized`: The app key was not provided, or valid
* `Penpal::UnprocessableEntity`: The server returned a 422 response. Check the content of the message for more details, but this will likely be a validation / content error.
* `Penpal::ServerError`: Something went wrong at the Penpal API, you should try again with exponential backoff
* `Penpal::Forbidden`: The server returned a 403 response. This should not occur on the delivery API
* `Penpal::DeliveryError`: Anything which isn't covered by the above exceptions

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
