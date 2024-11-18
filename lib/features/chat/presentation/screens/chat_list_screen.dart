import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_on_final/features/chat/presentation/screens/search/guide_search_screen.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:travel_on_final/features/chat/presentation/providers/chat_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:travel_on_final/core/providers/navigation_provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isGuideSearch = false;
  String _searchText = '';
  late NavigationProvider navigationProvider;

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      setState(() {});
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.startListeningToUnreadCounts(authProvider.currentUser!.id);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    navigationProvider.addListener(_checkForReset);
    _checkForReset();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    navigationProvider.removeListener(_checkForReset);
    super.dispose();
  }

  void _checkForReset() {
    if (!mounted) return;
    if (navigationProvider.shouldResetChatListScreen) {
      _searchController.clear();
      _searchText = '';
      _clearFocus();
      navigationProvider.confirmChatListReset();
      setState(() {});
    }
  }

  void _clearFocus() {
    if (mounted) {
      FocusScope.of(context).unfocus();
    }
  }

  void _applySearchFilter() {
    setState(() {
      _searchText = _searchController.text.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          elevation: 0,
          centerTitle: true,
          title: const Text('채팅 목록'),
        ),
        body: const Center(child: Text('로그인이 필요합니다')),
      );
    }

    return GestureDetector(
      onTap: _clearFocus,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          elevation: 0,
          centerTitle: true,
          title: const Text('채팅 목록'),
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        labelText: '검색',
                        labelStyle: TextStyle(color: Colors.blue, fontSize: 14.sp),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.blue),
                    onPressed: _applySearchFilter,
                  ),
                ],
              ),
            ),
            if (_focusNode.hasFocus || _searchController.text.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      _clearFocus();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const GuideSearchScreen(),
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    ),
                    child: const Text(
                      '가이드 검색',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .orderBy('lastActivityTime', descending: true)
                    .snapshots(),
                builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
                  if (chatSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (chatSnapshot.hasError) {
                    return const Center(child: Text('오류가 발생했습니다.'));
                  }

                  if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('채팅방이 없습니다.'));
                  }

                  final chatDocs = chatSnapshot.data!.docs.where((doc) {
                    final participants = List<String>.from(doc['participants'] ?? []);
                    final chatData = doc.data() as Map<String, dynamic>? ?? {};

                    final isInChat = chatData['lastMessage']?.toLowerCase().contains(_searchText) ?? false;
                    final isGuideName = (chatData['usernames']?.values ?? [])
                        .any((name) => name.toLowerCase().contains(_searchText) &&
                              (name != authProvider.currentUser!.name || _isGuideSearch));
                    
                    return participants.contains(authProvider.currentUser!.id) &&
                        (_searchText.isEmpty || isInChat || isGuideName);
                  }).toList();

                  if (chatDocs.isEmpty) {
                    return const Center(child: Text('조건에 맞는 채팅방이 없습니다.'));
                  }

                  return ListView.builder(
                    itemCount: chatDocs.length,
                    itemBuilder: (ctx, index) {
                      final chatData = chatDocs[index].data() as Map<String, dynamic>? ?? {};
                      final chatId = chatDocs[index].id;

                      final participants = chatData['participants'] as List<dynamic>? ?? [];
                      final otherUserId = authProvider.currentUser!.id == participants[0]
                          ? participants[1]
                          : participants[0];

                      final unreadCount = chatData['unreadCount']?[authProvider.currentUser!.id] ?? 0;

                      chatProvider.updateOtherUserInfo(chatId, otherUserId);

                      return Column(
                        children: [
                          Dismissible(
                            key: Key(chatId),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red[200],
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              alignment: Alignment.centerRight,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (direction) async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('${chatData['usernames'][otherUserId] ?? 'Unknown'}님과의 대화방을 나가시겠습니까?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: const Text('취소'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      child: const Text('나가기'),
                                    ),
                                  ],
                                ),
                              );
                              return confirm ?? false;
                            },
                            onDismissed: (direction) async {
                              await chatProvider.leaveChatRoom(chatId, authProvider.currentUser!.id);
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundImage: (chatData['userProfileImages']?[otherUserId] == null ||
                                        chatData['userProfileImages'][otherUserId].isEmpty)
                                    ? const AssetImage('assets/images/default_profile.png')
                                    : null,
                                child: (chatData['userProfileImages']?[otherUserId] != null &&
                                        chatData['userProfileImages'][otherUserId].isNotEmpty)
                                    ? CachedNetworkImage(
                                        imageUrl: chatData['userProfileImages'][otherUserId],
                                        placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                        imageBuilder: (context, imageProvider) => CircleAvatar(
                                          backgroundImage: imageProvider,
                                          radius: 20,
                                        ),
                                      )
                                    : null,
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      chatData['usernames'][otherUserId]?.substring(
                                              0,
                                              chatData['usernames'][otherUserId].length > 15
                                                  ? 15
                                                  : chatData['usernames'][otherUserId].length) ??
                                          'Unknown User',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (unreadCount > 0)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        unreadCount > 999 ? "+999" : "$unreadCount",
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Text(
                                (chatData['lastMessage'] != null && chatData['lastMessage'].length > 65)
                                    ? '${chatData['lastMessage'].substring(0, 65)}...'
                                    : chatData['lastMessage'] ?? '',
                              ),
                              onTap: () {
                                _clearFocus();
                                chatProvider.resetUnreadCount(chatId, authProvider.currentUser!.id);
                                chatProvider.startListeningToMessages(chatId);
                                GoRouter.of(context).push('/chat/$chatId');
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    offset: Offset(0, 1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
