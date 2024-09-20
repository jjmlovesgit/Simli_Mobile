
# Simli Client for Flutter

The Simli Client Flutter package integrates with the Simli API to deliver real-time, low-latency streaming avatars. These avatars can be used in various applications, such as customer service bots, virtual assistants, and more. This package leverages WebRTC technology for video rendering, peer connections, and data channels, ensuring a seamless, high-performance experience.

## Features

This package supports the following parameters and methods:

### Parameters

`SimliClient` supports the following parameters during initialization:

| Name          | Type   | Description                                                    |
| ------------- | ------ | -------------------------------------------------------------- |
| apiKey        | String | The API key used for authenticating API requests.              |
| faceId        | String | Identifies the face to use for the session.                    |
| handleSilence | bool   | Optional. Determines whether silence handling is enabled.       |

Visit the Simli website to obtain your API key and face ID. [simli.com](https://www.simli.com/)

## Getting Started

### Installing

1. Add the dependency to `pubspec.yaml`.

   Get the latest version from the 'Installing' tab
   on [pub.dev](https://pub.dev/packages/simli_client/install).

   ```yaml
   dependencies:
     simli_client: <latest-version>
   ```

2. Run the following command:

   ```shell
   flutter pub get
   ```

3. Import the package:

   ```dart
   import 'package:simli_client/simli_client.dart';
   ```

## Implementation

1. Initialize the Simli client:

   ```dart
   final SimliClient simliClient = SimliClient(apiKey: ApiKeys.simliApiKey, faceId: faceId);
   ```

2. Call the `start` function to establish a connection with the server and create a peer connection:

   ```dart
   simliClient.start();
   ```

3. Use `RTCVideoView` in the widget tree to display the live avatar:

   ```dart
   RTCVideoView(
     simliClient.videoRenderer!,
     mirror: false,
     placeholderBuilder: (context) => const Center(child: CircularProgressIndicator()),
   );
   ```

4. Once the connection is established, you can send custom PCM16 audio with a 16,000 sample rate to the server. The avatar will start speaking using the provided audio. The audio data must be in `Uint8List` format:

   ```dart
   simliClient.sendAudioData(data);
   ```

### Additional Methods and Parameters

This package also includes additional methods and parameters to help you build a robust application:

| Name               | Type                       | Description                                  |
| ------------------ | -------------------------- | -------------------------------------------- |
| state              | SimliState                 | Returns the current state of the client.     |
| stateNotifier      | ValueNotifier<SimliState>  | Notifies about the SimliState.               |
| onConnection       | VoidCallback               | Callback when the connection is established. |
| onFailed           | Function(SimliError error) | Callback when the connection fails.          |
| onDisconnected     | VoidCallback               | Callback when the connection is disconnected.|
| isSpeaking         | bool                       | Returns `true` if the avatar is speaking.    |
| isSpeakingNotifier | ValueNotifier<bool>        | Notifies about the speaking status.          |
| audioLevelNotifier | ValueNotifier<double>      | Notifies about the audio level of the avatar.|

## Preview

### Here is the few screenshot for the preview.


<table>
  <tr>
    <td align="center"><img src="https://raw.githubusercontent.com/jemisgoti/simli_flutter_client/master/preview/1.png" height="399" width="756" alt="Avatar Preview"/><br /><sub><b>Avatar</b></sub></td>
  </tr>
  <tr>
    <td align="center"><img src="https://raw.githubusercontent.com/jemisgoti/simli_flutter_client/master/preview/2.png" height="500px" alt="Conversation Preview"/><br /><sub><b>Conversation</b></sub></td>
  </tr>
  <tr>
    <td align="center"><img src="https://raw.githubusercontent.com/jemisgoti/simli_flutter_client/master/preview/1.gif" height="500px" alt="Demo Preview"/><br /><sub><b>Demo</b></sub></td>
  </tr>
</table>

## Main Contributors

<table>
  <tr>
    <td align="center"><a href="https://github.com/jemisgoti"><img src="https://avatars.githubusercontent.com/u/46031164" width="100px;" height="100px;" alt="Jemis Goti"/><br /><sub><b>Jemis Goti</b></sub></a></td>
  </tr>
</table>

## Thanks

Thank you for using this package! Your support for the open-source community is greatly appreciated.
