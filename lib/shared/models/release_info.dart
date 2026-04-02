class ReleaseInfo {
  final String version;
  final String? apkUrl;

  const ReleaseInfo({required this.version, this.apkUrl});

  @override
  bool operator ==(Object other) => other is ReleaseInfo && other.version == version && other.apkUrl == apkUrl;

  @override
  int get hashCode => Object.hash(version, apkUrl);
}
