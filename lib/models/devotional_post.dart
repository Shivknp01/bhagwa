enum PostContentType {
  wallpaper,
  bhajan,
  music,
  ringtone,
  mantra,
  stuti,
  horoscope,
  status,
}

enum PostActionType {
  setWallpaper,
  playMusic,
  playBhajan,
  setRingtone,
  readMantra,
  readStuti,
  readHoroscope,
  shareStatus,
}

class DevotionalPost {
  final String id;
  final PostContentType contentType;
  final String title;
  final String? titleHi;
  final String description;
  final String? descriptionHi;
  final String? imageUrl;
  final String? audioUrl;
  final String? videoUrl;
  final int likes;
  final int commentsCount;
  final int views;
  final bool isLiked;
  final bool isSaved;
  final PostActionType actionType;
  final String actionLabel;
  final String? actionLabelHi;
  final String deity;
  final String language;
  final String? mantraText;
  final String? mantraMeaning;
  final String? mantraMeaningHi;
  final String authorName;
  final String? durationText;

  const DevotionalPost({
    required this.id,
    required this.contentType,
    required this.title,
    this.titleHi,
    required this.description,
    this.descriptionHi,
    this.imageUrl,
    this.audioUrl,
    this.videoUrl,
    required this.likes,
    required this.commentsCount,
    required this.views,
    this.isLiked = false,
    this.isSaved = false,
    required this.actionType,
    required this.actionLabel,
    this.actionLabelHi,
    required this.deity,
    this.language = 'Hindi',
    this.mantraText,
    this.mantraMeaning,
    this.mantraMeaningHi,
    this.authorName = 'Bhakti Media',
    this.durationText,
  });

  String localizedTitle(String lang) {
    if (lang == 'hi' && titleHi != null && titleHi!.isNotEmpty) {
      return titleHi!;
    }
    return title;
  }

  String localizedDescription(String lang) {
    if (lang == 'hi' && descriptionHi != null && descriptionHi!.isNotEmpty) {
      return descriptionHi!;
    }
    return description;
  }

  String localizedActionLabel(String lang) {
    if (lang == 'hi' && actionLabelHi != null && actionLabelHi!.isNotEmpty) {
      return actionLabelHi!;
    }
    return actionLabel;
  }

  String? localizedMantraMeaning(String lang) {
    if (lang == 'hi' && mantraMeaningHi != null && mantraMeaningHi!.isNotEmpty) {
      return mantraMeaningHi;
    }
    return mantraMeaning;
  }

  DevotionalPost copyWith({
    String? id,
    PostContentType? contentType,
    String? title,
    String? titleHi,
    String? description,
    String? descriptionHi,
    String? imageUrl,
    String? audioUrl,
    String? videoUrl,
    int? likes,
    int? commentsCount,
    int? views,
    bool? isLiked,
    bool? isSaved,
    PostActionType? actionType,
    String? actionLabel,
    String? actionLabelHi,
    String? deity,
    String? language,
    String? mantraText,
    String? mantraMeaning,
    String? mantraMeaningHi,
    String? authorName,
    String? durationText,
  }) {
    return DevotionalPost(
      id: id ?? this.id,
      contentType: contentType ?? this.contentType,
      title: title ?? this.title,
      titleHi: titleHi ?? this.titleHi,
      description: description ?? this.description,
      descriptionHi: descriptionHi ?? this.descriptionHi,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      likes: likes ?? this.likes,
      commentsCount: commentsCount ?? this.commentsCount,
      views: views ?? this.views,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      actionType: actionType ?? this.actionType,
      actionLabel: actionLabel ?? this.actionLabel,
      actionLabelHi: actionLabelHi ?? this.actionLabelHi,
      deity: deity ?? this.deity,
      language: language ?? this.language,
      mantraText: mantraText ?? this.mantraText,
      mantraMeaning: mantraMeaning ?? this.mantraMeaning,
      mantraMeaningHi: mantraMeaningHi ?? this.mantraMeaningHi,
      authorName: authorName ?? this.authorName,
      durationText: durationText ?? this.durationText,
    );
  }
}
