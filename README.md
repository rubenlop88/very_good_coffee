# very_good_coffee

Very Good Coffee App

In this app you can get a random coffee image and add it to your list 
of favorite coffee images. You can also remove the coffee image from your list
by tapping on the image and selecting the remove option.

The app supports dark mode and light mode. The colors of the app change based on
the selected coffee image.

The app works offline by using the packages `hydrated_cubit`, which saves te list of favorite images and the current
image to local storage, and `cached_network_image`, which caches the downloaded images on the device.

## Run app

```bash
flutter run lib/main.dart
```

## Run tests
```bash
flutter test integration_test
```