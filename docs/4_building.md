# 🛠️ Building from source

This page will guide you through building ReVanced Manager from source.

1\. Setup the Flutter environment for your [platform](https://docs.flutter.dev/get-started/install)

2\. Clone the repository

   ```sh
   git clone https://github.com/revanced/revanced-manager.git && cd revanced-manager
   ```
3\. Get dependencies

   ```sh
   flutter pub get
   ```

4\. Delete conflicting outputs

> [!TIP]
> Must be run every time you sync your local repository with the remote repository.

   ```sh
   dart run build_runner build --delete-conflicting-outputs
   ```



5\. Build the APK

   ```sh
   flutter build apk
   ```
