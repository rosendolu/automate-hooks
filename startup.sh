chmod +x ./hooks/*
webhook -hooks ./hook.yaml -verbose -hotreload -header 'Access-Control-Allow-Origin=*' -header 'Access-Control-Allow-Methods=GET,POST,OPTIONS' -header 'Access-Control-Allow-Headers=Origin,X-Requested-With,Content-Type,Accept,Authorization'
