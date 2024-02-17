# Setup
### Project
https://github.com/GoogleCloudPlatform/functions-framework-nodejs/blob/main/docs/typescript.md

### Debug
https://github.com/GoogleCloudPlatform/functions-framework-nodejs/blob/main/docs/debugging.md

```
npm install ts-node typescript --save-dev

{
  "compilerOptions": {
    "sourceMap": true,
    ...
  }
}

```

```
{
  "scripts": {
    "start": "node --inspect -r ts-node/register node_modules/.bin/functions-framework --target=TypescriptFunction"
  }
}
```

## Deploy
https://cloud.google.com/sdk/docs/install-sdk#mac
```
export PATH="$PATH":"$HOME/google-cloud-sdk/bin"
gcloud init
gcloud functions deploy TypescriptFunction --gen2 --region asia-east2 --trigger-http --runtime nodejs20 

```

### Get all available runtimes
```
gcloud functions runtimes list 
```

## Issue
1. Your client does not have permission to get URL /TypescriptFunction from this server.
   https://stackoverflow.com/a/69059010/5588637
