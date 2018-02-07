# red-alert

# Installation

You will need an IOS 10+ device, a mac with XCode 9+.

You also will need the excellent tool [ios-deploy](https://github.com/phonegap/ios-deploy)

```sh
$ npm install -g ios-deploy
```

# Notification

1. Create an account and an app on [pusher.com](https://pusher.com/), there is a free plan that will be enough for our needs.
2. Get the app key on pusher dashboard

# Build the IOS 10 app
1. Copy RedAlert/key.json.sample into RedAlert/key.json and set the pusher key value
2. Build the app and get the .app location on your mac
3. Push it on your connected device with ios-deploy:

```sh
$ ios-deploy --uninstall --bundle /Users/jtbonhomme/Library/Developer/Xcode/DerivedData/RedAlert-doavsqjkqiktfafxzvfpdhyunzho/Build/Products/Debug-iphoneos/RedAlert.app
```


# trigger notifications

1. Get the app id on pusher dashboard
2. Enter the following command:

```sh
$ pusher channels apps trigger --app-id YOUR_APP_ID --channel "test" --event "foo" --message '{"data": "Hello Beauty !"}'
```

