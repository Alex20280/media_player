class TrackModel {
  final double duration;
  final List<dynamic>? dateRanges;
  final String filename;
  final String artist;
  final String source;
  final String sk;
  final String pk;
  final String playlistSk;
  final String title;
  final String type;
  final String? campaignSk;
  final Map<String, dynamic>? dateRangeDetails;

  TrackModel({
    required this.duration,
    this.dateRanges,
    required this.filename,
    required this.artist,
    required this.source,
    required this.sk,
    required this.pk,
    required this.playlistSk,
    required this.title,
    required this.type,
    this.dateRangeDetails,
    this.campaignSk
  });

  factory TrackModel.fromJson(Map<String, dynamic> json, Map<String, dynamic> dateRange) {
    return TrackModel(
      duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
      dateRanges: json['date_ranges'] as List<dynamic>?,
      filename: json['filename']?.toString() ?? '',
      artist: json['artist']?.toString() ?? '',
      source: json['source_filename']?.toString() ?? '',
      sk: json['SK']?.toString() ?? '',
      pk: json['PK']?.toString() ?? '',
      playlistSk: json['playlist_sk']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      dateRangeDetails: dateRange.isNotEmpty ? dateRange : null,
      campaignSk: json['campaign_sk']?.toString(),
    );
  }
  
  @override
  String toString() {
    return 'TrackModel(filename: $filename, artist: $artist, type: $type, duration: $duration)';
  }
}