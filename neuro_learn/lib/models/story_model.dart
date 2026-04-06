class Story {
  final String title;
  final String content;

  Story({
    required this.title,
    required this.content,
  });

  List<String> get words => content.split(RegExp(r'\s+'));
}

// Sample story for the app
final sampleStory = Story(
  title: "The Quick Brown Fox",
  content:
      "The quick brown fox jumps over the lazy dog. This pangram contains every letter of the alphabet.",
);
