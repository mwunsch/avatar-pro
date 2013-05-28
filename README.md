# Serious Business Random Avatar Generator

Very important business demands very important avatars.

## Requesting a Random Business Avatar

To request a random avatar hit the endpoint [`/avatar`](/avatar).

Optionally add a `size`, or `s`, parameter with a single pixel dimension (since the avatar is square). The default is 80.

    /avatar?s=500

That will get you a largish sized avatar, for your business.

## Requesting a Semi-random Business Gravatar

To request a semi-random avatar, you can append an [email hash](http://en.gravatar.com/site/implement/hash/) to the avatar path, [as Gravatar does](http://en.gravatar.com/site/implement/images/):

    /avatar/205e460b479e2e5b48aec07710c08d50?s=500

Like the `/avatar` endpoint, you can add a `size` parameter. They are *semi-random* because they will remain consistent until the avatar index is updated.

This works well with [Gravatar](http://en.gravatar.com/), as a default avatar.

What would you use these business avatars for? Well if you need to conduct yourself professionally on the Internet for instance. Or if you need some default avatars when developing a web-app with seed data for instance. The possibilities are nearly endless.

Thanks to:

* [http://realbusinessmen.tumblr.com](http://realbusinessmen.tumblr.com/) is where the images come from.
* [http://www.tumblr.com/docs/en/api/v1](http://www.tumblr.com/docs/en/api/v1) is what I use to request a random image.
* [http://images.weserv.nl/](http://images.weserv.nl/) is what I use to crop the image to a square.
* [http://www.sinatrarb.com/](http://www.sinatrarb.com/) is responding to your requests.
* [https://www.heroku.com/](https://www.heroku.com/) is responsible for transporting bits from place to place.

[Mark Wunsch](http://markwunsch.com/) wrote this glue code. Please use it responsibly.

