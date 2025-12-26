// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:lottie/lottie.dart' as lottie;
// import 'package:kiliride/components/back_button.dart';
// import 'package:kiliride/shared/styles.shared.dart';
// import 'package:kiliride/provider/providers.dart';
// import 'package:kiliride/models/chatbot.model.dart';

// class ChatbotScreen extends ConsumerStatefulWidget {
//   const ChatbotScreen({super.key});

//   @override
//   ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
// }

// class _ChatbotScreenState extends ConsumerState<ChatbotScreen>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   bool _showWelcomeScreen = true;
//   bool _isFabVisible = true;

//   late AnimationController _animationController;
//   late Animation<Offset> _offsetAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _scrollController.addListener(_scrollListener);

//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );

//     _offsetAnimation =
//         Tween<Offset>(
//           begin: const Offset(2, 0), // Start from the right
//           end: Offset.zero, // End at the normal position
//         ).animate(
//           CurvedAnimation(
//             parent: _animationController,
//             curve: Curves.easeInOut,
//           ),
//         );

//     // Initially show the FAB
//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.removeListener(_scrollListener);
//     _scrollController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _scrollListener() {
//     // Handle FAB visibility based on scroll direction
//     if (_scrollController.position.userScrollDirection ==
//         ScrollDirection.reverse) {
//       if (_isFabVisible) {
//         setState(() {
//           _isFabVisible = false;
//           _animationController.reverse();
//         });
//       }
//     }

//     if (_scrollController.position.userScrollDirection ==
//         ScrollDirection.forward) {
//       if (!_isFabVisible) {
//         setState(() {
//           _isFabVisible = true;
//           _animationController.forward();
//         });
//       }
//     }
//   }

//   void _handleActionButton(String action) {
//     setState(() {
//       _showWelcomeScreen = false;
//     });

//     // Send message to chatbot
//     ref.read(chatbotProvider).sendMessage(action);
//     _scrollToBottom();
//   }

//   void _sendMessage() {
//     if (_messageController.text.trim().isEmpty) return;

//     final message = _messageController.text.trim();

//     setState(() {
//       if (_showWelcomeScreen) {
//         _showWelcomeScreen = false;
//       }
//     });

//     // Send message to chatbot
//     ref.read(chatbotProvider).sendMessage(message);
//     _messageController.clear();
//     _scrollToBottom();
//   }

//   void _scrollToBottom() {
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final chatbot = ref.watch(chatbotProvider);
//     final messages = chatbot.messages;

//     // Auto-scroll when new messages arrive
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (messages.isNotEmpty) {
//         _scrollToBottom();
//       }
//     });

//     return Scaffold(
//       backgroundColor: AppStyle.appBackgroundColor(context),
//       body: SafeArea(
//         child: Container(
//           decoration: BoxDecoration(),
//           child: Column(
//             children: [
//               // Header with back button
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: AppStyle.appGap,
//                   vertical: AppStyle.appGap / 2,
//                 ),
//                 child: Row(
//                   children: [
//                     CustomBackButton(hasPadding: true),
//                     const Spacer(),
//                   ],
//                 ),
//               ),

//               // Messages list or welcome screen
//               Expanded(
//                 child: _showWelcomeScreen
//                     ? _buildWelcomeScreen()
//                     : ListView.builder(
//                         controller: _scrollController,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: AppStyle.appPadding,
//                           vertical: AppStyle.appGap,
//                         ),
//                         itemCount: messages.length,
//                         itemBuilder: (context, index) {
//                           final message = messages[index];
//                           return _buildMessageBubble(message);
//                         },
//                       ),
//               ),

//               // Input field
//               Container(
//                 padding: const EdgeInsets.all(AppStyle.appPadding),
//                 decoration: BoxDecoration(
//                   color: AppStyle.appColor(context),
//                   // border: Border(
//                   //   top: BorderSide(
//                   //     color: AppStyle.borderColor(context),
//                   //     width: 1,
//                   //   ),
//                   // ),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: AppStyle.inputBG(context),
//                           borderRadius: BorderRadius.circular(25),
//                           border: Border.all(
//                             color: AppStyle.borderColor(context),
//                             width: 1,
//                           ),
//                         ),
//                         child: TextField(
//                           controller: _messageController,
//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: AppStyle.appBackgroundColor(context),
//                             hintText: 'Ask Something',
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(
//                                 AppStyle.appRadiusLLG,
//                               ),
//                               borderSide: BorderSide.none,
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(
//                                 AppStyle.appRadiusLLG,
//                               ),
//                               borderSide: BorderSide.none,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(
//                                 AppStyle.appRadiusLLG,
//                               ),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: EdgeInsets.symmetric(
//                               horizontal: AppStyle.appPadding,
//                               vertical: AppStyle.appGap + 4,
//                             ),
//                           ),
//                           onSubmitted: (_) => _sendMessage(),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: AppStyle.appGap),
//                     GestureDetector(
//                       onTap: _sendMessage,
//                       child: Container(
//                         width: 48,
//                         height: 48,
//                         decoration: BoxDecoration(
//                           color: AppStyle.primaryColor(context),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(Icons.send, color: Colors.white, size: 22),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildWelcomeScreen() {
//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(AppStyle.appPadding),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Logo
//             Image.asset('assets/img/app_icon.png', height: 120, width: 120),
//             const SizedBox(height: AppStyle.appPadding * 2),
    
//             // Greeting text with gradient background
//             Column(
//               children: [
//                 Text(
//                   'Hey Liberatus!',
//                   style: TextStyle(
//                     fontSize: AppStyle.appFontSize,
//                     color: AppStyle.textColored(context),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: AppStyle.appGap),
//                 Text(
//                   'How can I help you today?',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: AppStyle.appFontSizeLG + 2,
//                     color: Color.fromRGBO(55, 73, 87, 1),
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(height: AppStyle.appGap / 2),
//                 Text(
//                   "Let's get started!",
//                   style: TextStyle(
//                     fontSize: AppStyle.appFontSizeLG + 2,
//                     color: Color.fromRGBO(55, 73, 87, 1),
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ],
//             ),
    
//             const SizedBox(height: AppStyle.appPadding * 2),
    
//             SizedBox(
//               width: MediaQuery.of(context).size.width,
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: _buildActionButton(
//                       icon: 'assets/icons/visit.svg',
//                       label: 'Check Claim Status',
//                       onTap: () => _handleActionButton('Check Claim Status'),
//                     ),
//                   ),
//                   const SizedBox(width: AppStyle.appGap),
    
//                   Expanded(
//                     child: _buildActionButton(
//                       icon: 'assets/icons/shield.svg',
//                       label: 'My Policy Coverage',
//                       onTap: () => _handleActionButton('My Policy Coverage'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: AppStyle.appGap),
//             SizedBox(
//               width: MediaQuery.of(context).size.width,
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: _buildActionButton(
//                       icon: 'assets/icons/wallet.svg',
//                       label: 'Pay My Premium',
//                       onTap: () => _handleActionButton('Pay My Premium'),
//                     ),
//                   ),
//                   const SizedBox(width: AppStyle.appGap),
//                   Expanded(
//                     child: _buildActionButton(
//                       icon: 'assets/icons/support.svg',
//                       label: 'Talk to Support',
//                       onTap: () => _handleActionButton('Talk to Support'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
    
//             // Action buttons
//             // GridView.count(
//             //   shrinkWrap: true,
//             //   crossAxisCount: 2,
//             //   mainAxisSpacing: AppStyle.appGap + 4,
//             //   crossAxisSpacing: AppStyle.appGap + 4,
//             //   childAspectRatio: 2.5,
//             //   physics: const NeverScrollableScrollPhysics(),
//             //   children: [
//             //     _buildActionButton(
//             //       icon: 'assets/icons/visit.svg',
//             //       label: 'Check Claim Status',
//             //       onTap: () => _handleActionButton('Check Claim Status'),
//             //     ),
//             //     _buildActionButton(
//             //       icon: 'assets/icons/shield.svg',
//             //       label: 'My Policy Coverage',
//             //       onTap: () => _handleActionButton('My Policy Coverage'),
//             //     ),
//             //     _buildActionButton(
//             //       icon: 'assets/icons/wallet.svg',
//             //       label: 'Pay My Premium',
//             //       onTap: () => _handleActionButton('Pay My Premium'),
//             //     ),
//             //     _buildActionButton(
//             //       icon: 'assets/icons/support.svg',
//             //       label: 'Talk to Support',
//             //       onTap: () => _handleActionButton('Talk to Support'),
//             //     ),
//             //   ],
//             // ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButton({
//     required String icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(
//           horizontal: AppStyle.appGap + 4,
//           vertical: AppStyle.appGap + 4,
//         ),
//         decoration: BoxDecoration(
//           color: AppStyle.appColor(context),
//           borderRadius: BorderRadius.circular(AppStyle.appRadiusMd),
//           border: Border.all(color: AppStyle.borderColor2(context), width: 1),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(AppStyle.appGap + 4),
//               decoration: BoxDecoration(
//                 color: Color.fromRGBO(217, 217, 217, 1),
//                 shape: BoxShape.circle,
//               ),
//               child: SvgPicture.asset(
//                 icon,
//                 height: 18,
//                 color: AppStyle.primaryColor(context),
//               ),
//             ),
//             const SizedBox(width: AppStyle.appGap),
//             Expanded(
//               child: Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: AppStyle.appFontSizeXSM,
//                   color: AppStyle.textColored(context),
//                   fontWeight: FontWeight.w500,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMessageBubble(ChatMessage message) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: AppStyle.appPadding),
//       child: Row(
//         mainAxisAlignment: message.isUser
//             ? MainAxisAlignment.end
//             : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (!message.isUser) ...[const SizedBox(width: AppStyle.appGap)],
//           Flexible(
//             child: Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: AppStyle.appPadding,
//                 vertical: AppStyle.appGap + 4,
//               ),
//               decoration: BoxDecoration(
//                 color: message.isUser
//                     ? AppStyle.primaryColor(context)
//                     : AppStyle.bubbleBgColorOther(context),
//                 borderRadius: BorderRadius.only(
//                   topLeft: const Radius.circular(AppStyle.appRadiusMd),
//                   topRight: const Radius.circular(AppStyle.appRadiusMd),
//                   bottomLeft: Radius.circular(
//                     message.isUser ? AppStyle.appRadiusMd : 4,
//                   ),
//                   bottomRight: Radius.circular(
//                     message.isUser ? 4 : AppStyle.appRadiusMd,
//                   ),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (message.text.isNotEmpty)
//                     Text(
//                       message.text,
//                       style: TextStyle(
//                         color: message.isUser
//                             ? AppStyle.textAppColor(context)
//                             : AppStyle.invertedTextAppColor(context),
//                         fontSize: AppStyle.appFontSizeSM,
//                         height: 1.4,
//                       ),
//                     ),
//                   if (message.isStreaming) ...[
//                     const SizedBox(height: 4),
//                     lottie.Lottie.asset(
//                       "assets/lottie/typing1.json",
//                       height: 35,
//                       width: 35,
//                       repeat: true,
//                       animate: true,
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//           if (message.isUser) ...[const SizedBox(width: AppStyle.appGap)],
//         ],
//       ),
//     );
//   }
// }
