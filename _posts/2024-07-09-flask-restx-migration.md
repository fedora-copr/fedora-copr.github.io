## Migration from Flask to Flask-RESTx for API documentation

Hey everyone! We recently decided to switch COPR's API from Flask to [Flask-RESTx](https://flask-restx.readthedocs.io/en/latest/), mainly to improve our API documentation since the documenting was non-existing.

Why Flask-RESTx?

First off, Flask-RESTx is an extension of Flask that makes building and documenting APIs easier. Here’s why we decided to use it:

- It's wrapper around Flask, so we could re-use much of our code-base for Flask.
- It generates a cool, interactive [Swagger](https://swagger.io/) UI Documentation for COPR API.
- Flask-RESTx supports OpenAPI 3.0.
- It ensures the data API handles is valid and correctly formatted.

## What it looks like

So, what does this all look like in practice? Let me give you a sneak peek.

Instead of static, hard-to-update documentation, you get an interactive interface where users can do these things:

- Explore Endpoints: Users can see all available API endpoints at a glance. Each endpoint is listed with a clear description of what it does.
![](/assets/img/posts/endpoint-explore.png)

- View Details: Clicking on an endpoint reveals detailed information about the parameters it accepts and the responses it returns. This makes it super easy for you to know exactly how to use each endpoint.
![](/assets/img/posts/endpoint-details.png)


- Try It Out: One of the coolest features is the ability to test endpoints directly from the documentation. You can fill in parameters and see real-time responses, which helps them understand how everything works without writing a single line of code. 
Imagine this: you have an endpoint /api_3/builds that returns a list of builds. With Flask-RESTx, you will see this endpoint listed, click on it, and immediately know what parameters they can pass (like page or limit) and what the response will look like (a list of items). Plus, you can test it out right there to see it in action.
You can find the docs at [copr.fedorainfracloud.org/api_3/docs](https://copr.fedorainfracloud.org/api_3/docs)
![](/assets/img/posts/try-it.png)

This interactive, user-friendly documentation not only makes life easier for your users but also cuts down on the support you need to provide.

## Migration Experience

Switching to Flask-RESTx was pretty lenghty process, and here’s what happened:

- We decided to migrate the endpoint gradually to test them in bulks in production.
- There were some differences between Flask and Flask-RESTx, so there was a lot of compatibility related code to create bridge between those two APIs.
- The Swagger documentation is taken from codebase which required a lot of coding to happen.
- Flask-RESTx has deprecated parsers, telling us to use something like [pydantic](https://docs.pydantic.dev/latest/) or [marshmallow](https://marshmallow.readthedocs.io/en/stable/) to use validation fully. We decided to skip this and write our own parsers.

Switching to Flask-RESTx was a great move for our project. The improved documentation made our API more accessible and user-friendly. If you’re using Flask and want to step up your API documentation game, I highly recommend giving Flask-RESTx a try. The benefits of automatic, interactive documentation and a cleaner codebase are definitely worth it.
