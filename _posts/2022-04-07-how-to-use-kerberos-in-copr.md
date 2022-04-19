---
title: How to use Kerberos in Copr
author: Silvie Chlupova
layout: post


During the last release, a new authentication option was added to Copr. Now users can also log in using a Kerberos ticket.
We use GSSAPI to implement this mechanism.
The GSSAPI (Generic Security Services API) is a common interface for accessing the Kerberos security system.
Enabling GSSAPI authentication in Copr CLI or API will allow authentication without using  the API token for clients that have a Fedora account.
To use GSSAPI login in WebUI, click on `gssapi-login`  (negotiate needs to be allowed for the .fedorainfracloud.org domain in the browser, [see browser configuration](https://fedoraproject.org/wiki/Infrastructure/Kerberos#Firefox)).
It will log you in if you have a Kerberos ticket for `username@FEDORAPROJECT.ORG`.
To enable GSSAPI, you need to obtain a Kerberos ticket first. If you want to work with Fedora Copr, you can just do:

```shell
$ fkinit # optionally with "-u username"
Enter your password and OTP concatenated. (Ignore that the prompt is for only the token)
Enter OTP Token Value: <your password + OTP token>
$ copr whoami
your_username
```
You can also find here [how to use Kerberos auth with Fedora Infrastructure](https://fedoraproject.org/wiki/Infrastructure/Kerberos).
To work with another (non-Fedora Copr) instance, you need to obtain the Kerberos ticket differently, and you need to have a configuration file containing the appropriate copr_url:

```shell
$ kinit username@EXAMPLE.COM
$ cat ~/.config/copr
[copr-cli]
copr_url = https://copr.example.com/
```

## API key vs. Kerberos
If you have an API key set up and have a Kerberos ticket, then the API key has a higher priority and will be used.
By default, we enable the use of GSSAPI in the CLI. This means that if you have a properly configured API key, it will be used, but if not, we try to use GSSAPI to get the necessary information.
Be careful, in this case, CLI will use the `copr_url` set up in the configuration file to get the information, and if you don't have the configuration file at all, it will use the default URL,
which is `https://copr.fedorainfracloud.org`. If you want to use another instance of Copr, set `copr_url` to the preferred instance.
You can disable the use of GSSAPI by setting `gssapi` to False in the configuration file.

```shell
[copr-cli]
gssapi = False
```
Unlike CLI, this behavior is disabled by default in the API. However, you can still use the method `create_from_config_file`.

```python
from copr.v3 import Client
client = Client.create_from_config_file()
print(client.config)
```
```python
{'username': None, 'login': None, 'token': None, 'copr_url': 'https://copr.fedorainfracloud.org', 'gssapi': None, 'encrypted': True}
```
You can see that `gssapi` is not set so anything you do now using the API and requires authentication will fail and throw an exception
`CoprAuthException`. You can solve this by setting:

```python
client.config["gssapi"] = True
```

## Switch primary ticket cache

If you obtain a ticket, e.g., for `username@EXAMPLE.COM`, and then you obtain a ticket for `username@FEDORAPROJECT.ORG`, everything works
well. However, if you obtain a ticket first for `FEDORAPROJECT.ORG` and then for `EXAMPLE.COM`,
it will not be possible to log in to the WebUI or use CLI and API. You can solve this issue by using `kswitch`.

```shell
kswitch -p username@FEDORAPROJECT.ORG
```
it makes the specified credential cache the primary cache for the collection if a cache collection is available.
No matter the order in which you get the ticket now, when you list cached Kerberos tickets using `klist`

```shell
klist -A
```
you can see that the Kerberos ticket for `username@FEDORAPROJECT.ORG` is now listed as first.

## New users
If you are a new user and want to start using Copr or if your group membership changed, and you want to use this new group in Copr,
you will first need to log in to the WebUI using the `log in` link.
We are currently unable to retrieve group membership and your email from FAS when you log in using Kerberos. Behind the `log in` link is `openid`, which can do this.
We need this information about new users in order to use Copr.

## Logic behind it
![Logic behind it](/assets/img/posts/state_machine.jpg)
