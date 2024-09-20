// import 'dart:typed_data';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:example/src/core/services/deepgram_service.dart';
// import 'package:example/src/core/services/groq_service.dart';
// import 'package:example/src/core/utils/api_keys.dart';
// import 'package:example/src/pages/simli_avatar_view.dart';
// import 'package:example/src/widgets/simli_avatar_selector.dart';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:example/src/core/extensions/context_extension.dart';

// import 'package:simli_client/simli_client.dart';
// import 'package:transparent_image/transparent_image.dart';

// class Homepage extends StatefulWidget {
//   const Homepage({super.key});

//   @override
//   State<Homepage> createState() => _HomepageState();
// }

// class _HomepageState extends State<Homepage> {
//   bool showChatView = false;
//   String faceId = 'tmp9i8bbq7c';
//   late SimliClient simliClient;

//   DeepgramService deepgramService = DeepgramService();
//   GroqService groqService = GroqService();

//   ValueNotifier<bool> isRecording = ValueNotifier(false);
//   @override
//   void initState() {
//     simliClient = SimliClient(apiKey: ApiKeys.simliApiKey, faceId: faceId);
//     super.initState();

//     deepgramService.initialize();
//   }

//   @override
//   void dispose() {
//     simliClient.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         body: Row(
//           children: [
//             Expanded(
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: AnimatedContainer(
//                       decoration: const BoxDecoration(
//                           image: DecorationImage(
//                               fit: BoxFit.cover,
//                               image: CachedNetworkImageProvider(
//                                   'https://ideogram.ai/assets/image/lossless/response/Yw8OrVRkS02k57zhEpbRmg'))),
//                       duration: const Duration(milliseconds: 100),
//                       curve: Curves.easeIn,
//                       child: Container(
//                         margin: const EdgeInsets.all(8),
//                         // decoration: BoxDecoration(color: context.secondary),
//                         child: Center(
//                           child: SimliAvatarView(
//                             size: 512,
//                             simliClient: simliClient,
//                             placeholder:  FadeInImage(
//                         placeholder: MemoryImage(kTransparentImage),
//                         image:   CachedNetworkImageProvider(imageUrl: ,),
//                       )),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   CallFooter(
//                     isRecording: isRecording,
//                     onMicTap: onMicTap,
//                     showChat: showChat,
//                     onCamera: sendData,
//                     endCall: endCall,
//                     onMore: () {
//                       connect();
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             if (showChatView,)
//               SizedBox(
//                 width = 256,
//                 height = MediaQuery.sizeOf(context).height,
//                 child = SimliAvatarSelector(
//                   onSelect: (faceID) {
//                     onFaceIdSelect(faceID);
//                   },
//                 ),
//               ),
//           ],
//         ),
//       );

//   void showChat() {
//     setState(() {
//       showChatView = !showChatView;
//       if (showChatView) {
//         groqService.sendMsg();
//       }
//     });
//   }

//   void connect() {
//     simliClient.start();
//   }

//   void sendData() {
//     var audioData = Uint8List.fromList(List.filled(6000, 255));
//     simliClient.sendAudioData(audioData);
//   }

//   void endCall() {
//     simliClient.close();
//   }

//   void onMicTap() {
//     if (deepgramService.isTranscribing.value) {
//       deepgramService.stopStt();
//     } else {
//       deepgramService.startStt();
//     }
//   }

//   void onFaceIdSelect(String faceId) {
//     this.faceId = faceId;
//     setState(() {
//       showChatView = false;
//     });
//     simliClient.faceId = faceId;
//     connect();
//   }
// }

// class CallFooter extends StatelessWidget {
//   const CallFooter(
//       {required this.isRecording,
//       super.key,
//       this.onMicTap,
//       this.showChat,
//       this.onMore,
//       this.onCamera,
//       this.endCall});
//   final VoidCallback? showChat, onMore, onCamera, endCall, onMicTap;
//   final ValueNotifier<bool> isRecording;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 80,
//       color: context.secondary,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           ValueListenableBuilder(
//               valueListenable: isRecording,
//               builder: (context, isRecordig, child) {
//                 return RoundedButton(
//                   iconData: Icons.mic,
//                   onTap: onMicTap,
//                 );
//               }),
//           const Gap(16),
//           RoundedButton(
//             iconData: Icons.video_call,
//             onTap: onCamera,
//           ),
//           const Gap(16),
//           RoundedButton(
//             iconData: Icons.chat,
//             onTap: showChat,
//           ),
//           const Gap(16),
//           RoundedButton(
//             iconData: Icons.more_horiz_outlined,
//             onTap: onMore,
//           ),
//           const Gap(16),
//           RoundedButton(
//             iconData: Icons.call_end,
//             onTap: endCall,
//             color: Colors.redAccent,
//             activeColor: Colors.red,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class RoundedButton extends StatefulWidget {
//   const RoundedButton(
//       {required this.iconData,
//       super.key,
//       this.onTap,
//       this.size = 45,
//       this.color,
//       this.activeColor,
//       this.isActive = false});
//   final IconData iconData;
//   final VoidCallback? onTap;
//   final double size;
//   final Color? color;
//   final Color? activeColor;
//   final bool isActive;
//   @override
//   State<RoundedButton> createState() => _RoundedButtonState();
// }

// class _RoundedButtonState extends State<RoundedButton> {
//   bool hovered = false;
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         widget.onTap?.call();
//       },
//       child: MouseRegion(
//         cursor: SystemMouseCursors.click,
//         onEnter: (event) {
//           setState(() {
//             hovered = true;
//           });
//         },
//         onExit: (event) {
//           setState(() {
//             hovered = false;
//           });
//         },
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 100),
//           curve: Curves.easeIn,
//           width: widget.size,
//           height: widget.size,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: (hovered || widget.isActive
//                 ? (widget.activeColor ?? context.primary)
//                 : (widget.color ?? context.primary.withOpacity(0.5))),
//           ),
//           child: Icon(
//             widget.iconData,
//           ),
//         ),
//       ),
//     );
//   }
// }
