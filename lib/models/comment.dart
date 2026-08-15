class Comment {
  final String id;
  final String postId;
  final String userName;
  final String userAvatar;
  final String commentText;
  final DateTime timestamp;
  final int likesCount;
  final bool isLiked;

  const Comment({
    required this.id,
    required this.postId,
    required this.userName,
    required this.userAvatar,
    required this.commentText,
    required this.timestamp,
    this.likesCount = 0,
    this.isLiked = false,
  });

  Comment copyWith({
    String? id,
    String? postId,
    String? userName,
    String? userAvatar,
    String? commentText,
    DateTime? timestamp,
    int? likesCount,
    bool? isLiked,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      commentText: commentText ?? this.commentText,
      timestamp: timestamp ?? this.timestamp,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
