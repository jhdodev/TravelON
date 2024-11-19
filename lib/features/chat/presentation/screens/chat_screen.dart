import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:travel_on_final/features/chat/presentation/providers/chat_provider.dart';
import 'package:travel_on_final/features/chat/presentation/widgets/message_bubble_widget.dart';
import 'package:travel_on_final/features/chat/presentation/widgets/bottom_sheet_widget.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final BottomSheetWidget _bottomSheetWidget = BottomSheetWidget();
  ChatProvider? chatProvider;
  String? otherUserId;
  String otherUserName = "Chat";
  bool isMessageEntered = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    setState(() {
      isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      chatProvider = Provider.of<ChatProvider>(context, listen: false);

      final userIds = widget.chatId.split('_');
      otherUserId = userIds.first == authProvider.currentUser!.id
          ? userIds.last
          : userIds.first;

      await chatProvider!.ensureChatRoomExists(widget.chatId, context, otherUserId!);
      chatProvider!.startListeningToMessages(widget.chatId);
      await chatProvider!.resetUnreadCount(widget.chatId, authProvider.currentUser!.id);
      otherUserName = await chatProvider!.fetchOtherUserInfo(otherUserId!);

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("초기화 중 오류 발생: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    chatProvider?.stopListeningToMessages(); // 스트림 해제
    chatProvider = null; // Provider 참조 해제
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("로딩 중...")),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "$otherUserName ",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              TextSpan(
                text: "님과의 대화",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: chatProvider.messages.length,
                cacheExtent: 500.0,
                itemBuilder: (ctx, index) {
                  final message = chatProvider.messages[index];
                  final isMe = message.uId ==
                      Provider.of<AuthProvider>(context, listen: false).currentUser!.id;
                  final showTime = index == 0;

                  return MessageBubble(
                    key: ValueKey(message.id),
                    message: message,
                    isMe: isMe,
                    otherUserName: otherUserName,
                    currentUserId: Provider.of<AuthProvider>(context, listen: false)
                        .currentUser!
                        .id,
                    showTime: showTime,
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 1.5.w),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.add, color: Colors.blue, size: 24.w),
                            onPressed: () {
                              _bottomSheetWidget.showBottomSheetMenu(
                                parentContext: context,
                                chatId: widget.chatId,
                                userId: Provider.of<AuthProvider>(context, listen: false).currentUser!.id,
                                otherUserId: otherUserId!,
                                currentUserProfileImage: Provider.of<AuthProvider>(context, listen: false)
                                        .currentUser!
                                        .profileImageUrl ?? '',
                                username: Provider.of<AuthProvider>(context, listen: false).currentUser!.name,
                              );
                            },
                          ),
                          Expanded(
                            child: TextField(
                              controller: messageController,
                              onChanged: (value) {
                                setState(() {
                                  isMessageEntered = value.isNotEmpty;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: '메시지를 입력하세요...',
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 0.w, vertical: 10.h),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    decoration: BoxDecoration(
                      color: isMessageEntered ? Colors.blue : Colors.white,
                      border: Border.all(color: Colors.blue, width: 1.5.w),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: IconButton(
                      icon: Transform.rotate(
                        angle: 0,
                        child: Icon(
                          Icons.airplanemode_active,
                          color: isMessageEntered ? Colors.white : Colors.grey,
                          size: 27.w,
                        ),
                      ),
                      onPressed: isMessageEntered
                          ? () {
                              chatProvider.sendMessageToChat(
                                chatId: widget.chatId,
                                text: messageController.text,
                                otherUserId: otherUserId!,
                                context: context,
                              );
                              messageController.clear();
                              setState(() {
                                isMessageEntered = false;
                              });
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
