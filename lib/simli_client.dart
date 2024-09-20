import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:simli_client/utils/logger.dart';

/// Represents a client for interacting with the Simli API and managing WebRTC
/// connections, including video rendering, peer connections, and data channels.
class SimliClient {
  /// Creates a new [SimliClient] instance.
  ///
  /// [apiKey] is the key used for authenticating API requests.
  /// [faceId] identifies the face to use for the session.
  /// [handleSilence] is optional and determines whether
  /// silence handling is enabled.
  SimliClient({
    required this.apiKey,
    required this.faceId,
    this.handleSilence = true,
  }) {
    videoRenderer = RTCVideoRenderer();
    videoRenderer!.initialize();
    initializeLogger();
  }

  /// The API key used for authentication.
  final String apiKey;

  /// The face ID for the Simli session.
  final String faceId;

  /// A flag indicating whether silence is handled.
  final bool handleSilence;

  /// The WebRTC peer connection.
  RTCPeerConnection? peerConnection;

  /// The video renderer used for displaying video streams.
  RTCVideoRenderer? videoRenderer;

  /// The data channel for sending and receiving data.
  RTCDataChannel? dataChannel;

  /// Timer for sending periodic data over the data channel.
  Timer? dataChannelTimer;

  /// Timer for monitoring audio levels.
  Timer? audioLEvelTimer;

  /// The number of ICE candidates found.
  int candidateCount = 0;

  /// Tracks the previous ICE candidate count.
  int prevCandidateCount = -1;

  /// Notifies listeners of changes to the client's state.
  ValueNotifier<SimliState> stateNotifier = ValueNotifier(SimliState.ideal);

  /// Notifies listeners of changes in whether the user is speaking.
  ValueNotifier<bool> isSpeakingNotifier = ValueNotifier(false);

  /// A callback for handling connection events.
  VoidCallback? onConnection;

  /// A callback for handling connection failed events.
  void Function(SimliError error)? onFailed;

  /// A callback for handling disconnection events.
  VoidCallback? onDisconnected;

  /// Gets whether the user is currently speaking.
  bool get isSpeaking => isSpeakingNotifier.value;

  /// Sets whether the user is currently speaking.
  set isSpeaking(bool value) {
    isSpeakingNotifier.value = value;
  }

  /// Gets current state of the client.
  SimliState get state => stateNotifier.value;

  /// Gets current state of the client.
  set state(SimliState state) {
    stateNotifier.value = state;
  }

  /// Notifies listeners with audio level of the avatar.
  ValueNotifier<double> audioLevelNotifier = ValueNotifier(0);

  /// Creates a WebRTC peer connection and sets up listeners.
  Future<void> createRTCPeerConnection() async {
    final configuration = <String, dynamic>{
      'sdpSemantics': 'unified-plan',
      'iceServers': <Map<String, List<String>>>[
        <String, List<String>>{
          'urls': <String>['stun:stun.l.google.com:19302'],
        }
      ],
    };

    peerConnection = await createPeerConnection(configuration);
    if (peerConnection != null) {
      logSuccess('Peer connection created');
      setupPeerConnectionListener();
    }
  }

  /// Sets up listeners for WebRTC peer connection events.
  void setupPeerConnectionListener() {
    peerConnection?.onIceGatheringState = (RTCIceGatheringState value) {
      logInfo('ICE gathering state changed: $value');
    };
    peerConnection?.onIceConnectionState = (RTCIceConnectionState state) {
      logInfo('ICE connection state changed: $state');
      logInfo('ICE connection state changed: $state');
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        logSuccess(
          'WebRTC connection established and ready for communication.',
        );
        // this.state = SimliState.connected;
      }
    };
    peerConnection?.onSignalingState = (RTCSignalingState value) {
      logInfo('Signal state changed: $value');
    };
    peerConnection?.onAddStream = _addVideoStream;
    peerConnection?.onTrack = (RTCTrackEvent value) {
      logException('Track Kind: ${value.track.kind}');
      if (value.track.kind == 'video') {
        _addVideoStream(value.streams.first);
      } else {
        _startAudioLevelChecking(value.track);
      }
    };
    peerConnection?.onIceCandidate = (RTCIceCandidate value) async {
      if (value.candidate == null) {
        // logInfo(await peerConnection?.getLocalDescription());
      } else {
        // logInfo(value.candidate);
        candidateCount += 1;
      }
    };
    peerConnection!.onIceGatheringState = (RTCIceGatheringState value) {
      logSuccess('ICE gathering state: $value');
    };
  }

  /// Starts the WebRTC session by creating the peer connection, adding data
  /// channels, and negotiating.

  Future<void> start() async {
    state = SimliState.connecting;

    await createRTCPeerConnection();
    dataChannel =
        await peerConnection!.createDataChannel('chat', RTCDataChannelInit());
    setupDataChannelListener();
    unawaited(
      peerConnection?.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
        init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
      ),
    );
    unawaited(
      peerConnection?.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
        init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
      ),
    );
    await negotiate();
  }

  /// Sets up listeners for data channel events.
  void setupDataChannelListener() {
    if (dataChannel == null) return;
    logInfo('Data Channel created');
    dataChannel?.stateChangeStream.listen(_handleDataChannelState);
    dataChannel?.onMessage = (RTCDataChannelMessage value) {
      logInfo(
        'Received message: ${value.text}',
      );
    };
  }

  /// Handles the state of the RTCDataChannel and takes action based
  /// on the state. When the data channel is open, it initializes
  /// the session, sends an initial audio packet,
  /// and starts a periodic timer that sends "ping" messages every second.
  ///
  /// [state] represents the current state of the data channel.
  Future<void> _handleDataChannelState(RTCDataChannelState state) async {
    logInfo('Data Channel state: $state');
    switch (state) {
      case RTCDataChannelState.RTCDataChannelOpen:
        this.state = SimliState.connected;

        onConnection?.call();
        // Initialize the session when the data channel is open.
        await initializeSession();

        // Send initial audio data over the data channel.
        sendAudioData(Uint8List.fromList(List.filled(6000, 255)));

        _startDataChannelInterval();

      // Handle the other states, but take no specific action for now.
      case RTCDataChannelState.RTCDataChannelClosed:
      case RTCDataChannelState.RTCDataChannelConnecting:
      case RTCDataChannelState.RTCDataChannelClosing:
        break;
    }
  }

  /// Starts the data channel timer that sends a "ping" message every second.
  ///
  /// This method first ensures that any existing timer is stopped to
  /// avoid duplicate timers. It then creates a new periodic timer that sends
  /// a "ping" message through the data channel every second,
  /// including the current timestamp.
  void _startDataChannelInterval() {
    // Stop any existing timer before starting a new one.
    _stopDataChannelInterval();

    // Start a new timer that sends a "ping" message every second.
    dataChannelTimer = Timer.periodic(
      const Duration(milliseconds: 1000),
      (Timer timer) {
        _sendPingMessage();
      },
    );
  }

  /// Stops the data channel timer if it is running.
  ///
  /// This method cancels the periodic timer used to send "ping" messages
  /// and sets the timer reference to null.
  void _stopDataChannelInterval() {
    // Cancel the timer if it exists.
    dataChannelTimer?.cancel();
    dataChannelTimer = null;
  }

  void _sendPingMessage() {
    if (dataChannel != null &&
        dataChannel!.state == RTCDataChannelState.RTCDataChannelOpen) {
      try {
        dataChannel?.send(RTCDataChannelMessage('ping ${DateTime.now()}'));
      } catch (error) {
        logException('Failed to send message: $error');
        _stopDataChannelInterval();
      }
    } else {
      logException(
        'Data channel is not open. Current state: ${dataChannel?.state}',
      );
      _stopDataChannelInterval();
    }
  }

  /// Initializes a session by sending metadata to a remote API.
  ///
  /// This method sends a POST request to the Simli API to start an
  /// audio-to-video session. Upon success, it sends the session token over
  ///  the data channel.
  ///
  /// The metadata includes the reference video URL, face ID, API key, and other
  ///  parameters. Throws an exception if the session cannot be initialized.
  Future<void> initializeSession() async {
    const url = 'https://api.simli.ai/startAudioToVideoSession';

    // Metadata to send to the API for session initialization.
    final metadata = <String, dynamic>{
      'video_reference_url':
          'https://storage.googleapis.com/charactervideos/5514e24d-6086-46a3-ace4-6a7264e5cb7c/5514e24d-6086-46a3-ace4-6a7264e5cb7c.mp4',
      'isJPG': false,
      'faceId': faceId,
      'syncAudio': true,
      'apiKey': apiKey,
      'handleSilence': handleSilence,
    };

    try {
      // Send a POST request to the server with the metadata.
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(metadata),
      );

      // Check if the request was successful.
      if (response.statusCode == 200) {
        // Retrieve the session token from the response.
        final sessionToken =
            (jsonDecode(response.body) as Map)['session_token'].toString();

        if (dataChannel != null &&
            dataChannel!.state == RTCDataChannelState.RTCDataChannelOpen) {
          // Send the session token over the data channel.
          unawaited(dataChannel?.send(RTCDataChannelMessage(sessionToken)));
        } else {
          onFailed?.call(
            SimliError(
              message:
                  'Data channel not open when trying to send session token',
            ),
          );
          state = SimliState.failed;
        }

        logInfo('Session initialized successfully');
      } else {
        // Log an error if the request fails.
        logException('Failed to start session: ${response.statusCode}');
        logException('Response body: ${response.body}');
        onFailed?.call(
          SimliError(
            message: 'Failed to start session: ${response.statusCode}',
          ),
        );
        state = SimliState.failed;
      }
    } catch (error) {
      onFailed?.call(
        SimliError(
          message: 'Failed to initialize session: $error',
        ),
      );

      state = SimliState.failed;
    }
  }

  /// Negotiates a WebRTC connection by creating an offer, setting the local
  /// description, gathering ICE candidates, and exchanging session details
  /// with the server.
  ///
  /// Throws a [PlatformException] if the [peerConnection] is not initialized.
  Future<void> negotiate() async {
    if (peerConnection == null) {
      throw PlatformException(code: 'peer-connection-not-initialized');
    }

    try {
      // Create an offer for the peer connection.
      final description = await peerConnection?.createOffer();
      await peerConnection?.setLocalDescription(description!);

      // Wait for ICE gathering to complete before proceeding.
      await waitForIceGathering();

      // Retrieve the local description after ICE gathering.
      final localDescription = await peerConnection?.getLocalDescription();
      if (localDescription == null) {
        return;
      }

// Send the session details (SDP) to the server to start the WebRTC session.
      try {
        final response = await http.post(
          Uri.parse('https://api.simli.ai/StartWebRTCSession'),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, String?>{
            'sdp': localDescription.sdp,
            'type': localDescription.type,
            'video_transform': 'none',
          }),
        );

        if (response.statusCode == 200) {
          final answer = jsonDecode(response.body) as Map<String, dynamic>;

          await peerConnection!.setRemoteDescription(
            RTCSessionDescription(
              answer['sdp'].toString(),
              answer['type'].toString(),
            ),
          );
        } else {
          onFailed?.call(
            SimliError(
              message: 'Failed to start session: ${response.body}',
            ),
          );
          state = SimliState.failed;
        }
      } catch (error) {
        onFailed?.call(
          SimliError(
            message: 'An error occurred: $error',
          ),
        );
        state = SimliState.failed;
      }
    } catch (e) {
      // Handle any additional errors in offer creation or session negotiation.
      logException('Error during negotiation: $e');

      onFailed?.call(
        SimliError(
          message: 'Error during negotiation: $e',
        ),
      );
      state = SimliState.failed;
    }
  }

  /// Waits for the ICE gathering process to complete.
  ///
  /// This method completes once the ICE candidates have been gathered.
  Future<void> waitForIceGathering() async {
    if (peerConnection == null) {
      return;
    }
    // Check if the ICE gathering is already complete.
    if (peerConnection?.iceGatheringState ==
        RTCIceGatheringState.RTCIceGatheringStateComplete) {
      return;
    }

    // Create a completer to signal the completion of the ICE gathering process.
    final completer = Completer<void>();

    // Check the state and complete the completer if gathering is complete.
    void checkState(RTCIceGatheringState state) {
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
        peerConnection!.onIceGatheringState = null;
        completer.complete();
        logSuccess('ICE gathering completed');
      }
    }

    // Listen for changes to the ICE gathering state.
    peerConnection!.onIceGatheringState = checkState;

    return completer.future;
  }

  /// Sends audio data over the data channel.
  ///
  /// This method ensures that the data channel is open before sending
  /// audio data. If the channel is not open, it logs an exception.
  ///
  /// [audioData] is the binary audio data to be sent.
  void sendAudioData(Uint8List audioData) {
    if (dataChannel?.state != RTCDataChannelState.RTCDataChannelOpen) {
      logException('Data channel is not open: ${dataChannel?.state}');
    } else {
      dataChannel!
          .send(RTCDataChannelMessage.fromBinary(audioData))
          .then((value) {
        logSuccess('Audio data sent successfully');
      });
    }
  }

  /// Adds a video stream to the video renderer and sets up audio settings.
  ///
  /// This method configures the [videoRenderer] to display the incoming video
  /// stream. It also manages audio settings, such as enabling the speakerphone
  ///  on mobile devices. [stream] is the incoming media stream containing video and/or audio tracks.
  void _addVideoStream(MediaStream stream) {
    logSuccess('Video stream added');
    logSuccess(stream.getVideoTracks());

    // Set the source of the video renderer to the incoming media stream.
    videoRenderer?.srcObject = stream;

    // Log when the first video frame is rendered.
    videoRenderer?.onFirstFrameRendered = () {
      logSuccess('First video frame rendered');

      state = SimliState.rendering;
    };

    // Handle audio track settings based on the platform.
    if (kIsWeb) {
      stream.getAudioTracks().first.enabled = true;
    } else {
      stream.getAudioTracks().first.enabled = true;
      if (!Platform.isMacOS) {
        stream.getAudioTracks().first.enableSpeakerphone(true);
      }
    }
  }

  /// Closes the peer connection, data channels, and any active timers.
  ///
  /// This method ensures that all resources
  /// (e.g., data channels, peer connection,timers) are properly disposed
  /// of when the client is no longer needed.
  Future<void> close() async {
    onDisconnected?.call();
    _stopDataChannelInterval();
    // Close and clean up the data channel.
    await dataChannel?.close();
    dataChannel = null;
    if (peerConnection?.transceivers != null) {
      (await peerConnection?.getTransceivers())?.forEach(
        (transceiver) {
          transceiver.stop();
        },
      );
    }
    // Close local audio and video tracks.
    (await peerConnection?.senders)?.forEach((sender) {
      sender.track?.stop();
    });

    // Close the peer connection.
    await peerConnection?.close();
    peerConnection = null;

    _stopAudioLevelChecking();
  }

  void _startAudioLevelChecking(MediaStreamTrack track) {
    audioLEvelTimer =
        Timer.periodic(const Duration(milliseconds: 100), (Timer timer) async {
      final stats = await peerConnection?.getStats(track);
      if (stats != null) {
        for (final element in stats) {
          if (element.type == 'inbound-rtp' &&
              element.values['mediaType'].toString() == 'audio' &&
              element.values['audioLevel'] != null) {
            isSpeaking =
                double.parse(element.values['audioLevel'].toString()) != 0;

            audioLevelNotifier.value =
                double.parse(element.values['audioLevel'].toString());
          }
        }
      }
    });
  }

  void _stopAudioLevelChecking() {
    // Cancel any active timers.
    audioLEvelTimer?.cancel();
    audioLEvelTimer = null;
  }
}

/// Represents the various states the Simli client can be in.
enum SimliState {
  ///When app is not connected
  ideal,

  ///while app is trying to connect
  connecting,

  ///when app is connected
  connected,

  ///when app is rendering avatar
  rendering,

  ///when app failed to connect
  failed
}

///Represent error with associated error code and message
class SimliError {
  ///initialize with message and errorCode
  SimliError({required this.message, this.errorCode});

  /// error code of any error
  String? errorCode;

  ///error message for the error
  String message;
}
