import 'package:flutter/material.dart';
import 'package:neuro_learn/models/story_model.dart';
import 'package:neuro_learn/screens/story_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeuroLearn',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StoryScreen(story: sampleStory),
    );
  }
}
