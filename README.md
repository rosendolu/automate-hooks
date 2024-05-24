# automate-hooks

> Collection of webhooks for my daily work.
> Powered by [webhook](https://github.com/adnanh/webhook?tab=readme-ov-file), based on `ubuntu` server


## Quick start
```sh
curl -o- https://raw.githubusercontent.com/rosendolu/automate-hooks/main/install.sh | bash
```

## Sept by step setup


```sh
git clone https://github.com/rosendolu/automate-hooks.git
```

Set env conf


```sh
cp .env .env.local
```
Update as you desired
```sh
SECRET=secret
TOKEN=token
```

Run install 
```sh
bash install.sh
```