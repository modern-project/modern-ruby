# What and Why? #
Modern is an API framework for Ruby web applications, built on top of Rack.

Which, by itself, isn't that much. There are a billion of these. You've got
Rails, Grape, Sinatra, and plenty more. And most of them are great! So, why then
did I feel compelled to write a new one?

A few reasons come to mind, and in describing them I hope to explain why Modern
exists and why you should use it.

### You Shouldn't Need To Be An Expert To Do The Right Thing ###
You could call this "the right thing should be easy," too, but I feel like it's
important to dig into that a little more. Modern provides facilities to replace
a lot of the boilerplate and drudgery of other API frameworks with clean
tooling.

Modern cares about correctness. Unlike most frameworks, which have rolled their
own validation libraries (some of which are good--others of which, not so much),
Modern leverages the fantastic [dry-struct] and [dry-types] libraries to handle
easy and full-featured type declarations throughout its API. It'll test
validation of parameters and request bodies, doing the right thing (400 or 422,
as appropriate) when a problem arises--and, in development, it'll test your
response bodies against the return values you've specified, and alert you if
they don't match up.

Modern cares about security, too, and exposes to the user a simple mechanism for
securing APIs. It handles the plumbing work of pulling HTTP authorizations or
API keys out of various parameters, then hands them off to your code for proper
validation.

And Modern cares about how you're actually going to put it into production. Most
systems and frameworks are agnostic about things like request tracing or how
logging should be structured. Modern instead asserts that, yeah, you're going to
want to trace along requests to make sure everything's okay, so of course we'll
define a unique request ID (or use one if it's passed in via a HTTP request from
another service, allowing you to trace requests across many services). And
Modern also asserts that good, detailed logging is important, so its primary
logger emits structured, searchable logs courtesy of [Ougai].

### Your Framework Shouldn't Obfuscate What You're Doing ###
A huge part of Ruby is how easy it is to build domain-specific languages to
describe the problems you're tackling. And that's fine, as far as it goes. But
the interplay between frameworks and libraries can make _what that DSL is doing_
more difficult than it needs to be to understand how your application works.

Modern is designed so that you don't _need_ a DSL. That isn't to say that a DSL
isn't useful (and `modern-dsl` is a project I'm working on as I go), but instead
that a simple, declarative object model doesn't have to be obfuscated by a
complex, sometimes even stateful (lookin' at you, Grape--carrying options
_forward_ onto the next route you declare is silly!) DSL.

Simple is good. Modern tries to be simple, and any DSL that wraps it will have
to reflect that.

### OpenAPI Should Be First-Class ###
[OpenAPI] is awesome. I got the bug with Swagger 2.0 (now OpenAPI 2.0--the
naming is not why all of this is great) and realized that I'd wasted way too
much time building clients from scratch to talk to an API I'd knocked together
on the other end. Its tooling is great and getting better, with self-documenting
API tools and a number of generators to create clients in both dynamically typed
and statically typed languages.

Personally, I prefer to dynamically generate clients in dynamically typed
languages; [swagger-js] is kind of my thing. But reasonable people can differ.

The important thing here, though, is that Modern is designed around OpenAPI and
speaks its conventions "natively". The core object model of Modern (described in
detail later) maps easily to OpenAPI 3.0 and so an API designed along Modern's
"happy path" makes it easy to interconnect it with other systems you might run
across. You fire up your Modern app, it generates and serves an OpenAPI spec,
and you're off to the races.

### Modern Should Be Portable ###
Obviously, I don't mean you're going to fire up Node and run `modern.rb`. But
Modern is intended to describe a fairly straightforward and _simple_ set of
behaviors that are OpenAPI-specific much more than they are Ruby-specific. It
should be eminently possible to do a side-by-side port of Modern to Node or to
Kotlin or to other languages in a way that provides baseline OpenAPI server
capabilities wherever you happen to be.

## How Modern Works ##
Modern is a standard Rack-based application, run through a config.ru` file like
any other. There's plenty of great Rack documentation out there. Instead, let's
talk briefly about how Modern is structured, at the level you're likely to need
to know it.

The heart of your application is the **descriptor**. This object, and its children,
are an immutable declaration of "how this application runs". Routes, security
declarations, input/output converters--all of these are defined strictly by the
descriptor, which you can find in `Modern::Descriptor::Core`.

You'll also create a **configuration**, which should be an instance of type
`Modern::Configuration` or a subtype thereof if you'd like to incorporate your
own configuration data into the same object. These are operational concerns that
Modern needs to know about--whether or not to show backtraces in errors, whether
or not to validate response bodies on their way out the door, that sort of thing.

Lastly, you'll (optionally) define a set of **services**, which should be an
instance of `Modern::Services` or a subtype thereof. Here's where you'll provide
to your application the links to external "stuff", whether it's a logger or your
database or a client for a remote service. These services will be injected into
the scope of every route you write, making it easy to avoid global state or
unexpected side effects within your application.

Once you've got your descriptor, your configuration, and your services, you'll
pass them all to a constructor for `Modern::App`, which is the Rack interface
that handles your requests. It'll generate your OpenAPI documentation from your
descriptor and handle serving it, while also accepting incoming requests from
clients and dispatching them to the functional aspects of your descriptor.

[dry-struct]: http://dry-rb.org/gems/dry-struct
[dry-types]: http://dry-rb.org/gems/dry-types
[Ougai]: https://github.com/tilfin/ougai
[OpenAPI]: https://www.openapis.org
[swagger-js]: https://github.com/swagger-api/swagger-js