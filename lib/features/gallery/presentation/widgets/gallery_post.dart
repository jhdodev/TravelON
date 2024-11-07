import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import '../providers/gallery_provider.dart';
import 'comment_bottom_sheet.dart';
import '../../domain/entities/comment_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class GalleryPost extends StatefulWidget {
  final String imgUrl;
  final String username;
  final String location;
  final String description;
  final String postId;
  final List<String> likedBy;
  final int likeCount;
  final List<Comment> comments;
  final String userId;

  const GalleryPost({
    super.key,
    required this.imgUrl,
    required this.username,
    required this.location,
    required this.description,
    required this.postId,
    required this.likedBy,
    required this.likeCount,
    required this.comments,
    required this.userId,
  });

  @override
  State<GalleryPost> createState() => _GalleryPostState();
}

class _GalleryPostState extends State<GalleryPost> {
  late bool isLiked;
  late int likeCount;
  bool isScrapped = false;

  @override
  void initState() {
    super.initState();
    _updateLikeStatus();
    _updateScrapStatus();
  }

  @override
  void didUpdateWidget(GalleryPost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.likedBy != widget.likedBy ||
        oldWidget.likeCount != widget.likeCount) {
      _updateLikeStatus();
    }
  }

  void _updateLikeStatus() {
    final user = context.read<AuthProvider>().currentUser;
    isLiked = user != null && widget.likedBy.contains(user.id);
    likeCount = widget.likeCount;
  }

  void _updateScrapStatus() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .get();
      final List<String> scrappedPosts =
          List<String>.from(userDoc.data()?['scrappedPosts'] ?? []);

      setState(() {
        isScrapped = scrappedPosts.contains(widget.postId);
      });
    }
  }

  Future<void> _handleLikePress() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      setState(() {
        isLiked = !isLiked;
        likeCount = isLiked ? likeCount + 1 : likeCount - 1;
      });

      try {
        await context.read<GalleryProvider>().toggleLike(
              widget.postId,
              user.id,
            );
      } catch (e) {
        setState(() {
          isLiked = !isLiked;
          likeCount = isLiked ? likeCount + 1 : likeCount - 1;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('좋아요 처리 중 오류가 발생했습니다')),
          );
        }
      }
    }
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => CommentBottomSheet(
        postId: widget.postId,
        comments: widget.comments,
      ),
    );
  }

  Future<void> _toggleScrap() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다')),
      );
      return;
    }

    setState(() {
      isScrapped = !isScrapped;
    });

    try {
      await context.read<GalleryProvider>().toggleScrap(widget.postId, user.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isScrapped ? '스크랩이 완료되었습니다' : '스크랩이 해제되었습니다'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isScrapped = !isScrapped;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('스크랩 처리 중 오류가 발생했습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().currentUser;
    final isOwner = currentUser?.id == widget.userId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(10.r),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundImage:
                    const AssetImage('assets/images/default_profile.png'),
                backgroundColor: Colors.grey[200],
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    Text(
                      widget.location,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isOwner)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      context.push('/edit-gallery-post', extra: {
                        'postId': widget.postId,
                        'location': widget.location,
                        'description': widget.description,
                        'imageUrl': widget.imgUrl,
                      });
                    } else if (value == 'delete') {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('게시물 삭제'),
                          content: const Text('이 게시물을 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                '삭제',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && context.mounted) {
                        try {
                          await context
                              .read<GalleryProvider>()
                              .deletePost(widget.postId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('게시물이 삭제되었습니다')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('삭제 실패: $e')),
                            );
                          }
                        }
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('수정'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('삭제', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Image.network(
          widget.imgUrl,
          height: 400.h,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Row(
          children: [
            IconButton(
              onPressed: _handleLikePress,
              icon: Icon(
                isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                color: isLiked ? Colors.red : null,
              ),
            ),
            IconButton(
              onPressed: _showComments,
              icon: const Icon(CupertinoIcons.chat_bubble),
            ),
            const Spacer(),
            IconButton(
              onPressed: _toggleScrap,
              icon: Icon(
                isScrapped
                    ? CupertinoIcons.bookmark_fill
                    : CupertinoIcons.bookmark,
              ),
            ),
          ],
        ),
        if (likeCount > 0)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              '좋아요 $likeCount개',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        Padding(
          padding: EdgeInsets.all(10.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.description),
              if (widget.comments.isNotEmpty)
                TextButton(
                  onPressed: _showComments,
                  child: Text(
                    '댓글 ${widget.comments.length}개 모두 보기',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14.sp,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Divider(height: 20.h),
      ],
    );
  }
}
