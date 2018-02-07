# red-alert

# send notification

1. Create an account and an app on pusher.com
2. Get the app key on pusher dashboard

# Build the IOS 10 app
1. Copy RedAlert/key.json.sample into RedAlert/key.json and set the pusher key value
2. Build


# trigger notifications

1. Get the app id on pusher dashboard
2. Enter the following command:

```sh
$ pusher channels apps trigger --app-id YOUR_APP_ID --channel "test" --event "foo" --message '{"data": "Hello Beauty !"}'
```

