# A Version Bumper for dart

Just add this package to your dev_dependencies and execute the following command:

```shell
flutter pub run version_bmp
```

This will increase the version of your dart project in the `pubspec.yaml` and also increase the version code if set.

## Options:

- p: set the path of the `pubspec.yaml` file
- t: set the type of the version bump (major,minor,patch)
- g: commit and tag the version bump
