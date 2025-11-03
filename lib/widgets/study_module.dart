import 'package:flutter/material.dart';
import 'study_models.dart';
import 'study_tiles.dart';

class StudyModule extends StatefulWidget {
  const StudyModule({super.key});

  @override
  State<StudyModule> createState() => _StudyModuleState();
}

class _StudyModuleState extends State<StudyModule> {
  late final List<StudyTopic> _topics;
  StudyTopic? _currentTopic;
  StudySubtopic? _currentSubtopic;
  int _lectureIndex = 0;

  @override
  void initState(){
    super.initState();
    _topics = buildDefaultStudyTopics();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentTopic == null) {
      return _buildTopicsGrid();
    }
    if (_currentSubtopic == null) {
      return _buildSubtopicsGrid(_currentTopic!);
    }
    return _buildLectureView(_currentSubtopic!);
  }

  Widget _buildTopicsGrid(){
    final size = 150.0;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1),
        itemCount: _topics.length,
        itemBuilder: (_, i){
          final t = _topics[i];
          return SquareTile(title: t.title, color: t.color, size: size, emoji: t.emoji, onTap: (){ setState(()=> _currentTopic = t); });
        },
      ),
    );
  }

  Widget _buildSubtopicsGrid(StudyTopic topic){
    final size = 120.0;
    return Column(children:[
      _buildHeader('${topic.emoji} ${topic.title}', onBack: ()=> setState(()=> _currentTopic = null)),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1),
            itemCount: topic.subtopics.length,
            itemBuilder: (_, i){
              final s = topic.subtopics[i];
              return SquareTile(title: s.title, color: topic.color, size: size, onTap: (){ setState(()=> _currentSubtopic = s); });
            },
          ),
        ),
      ),
    ]);
  }

  Widget _buildLectureView(StudySubtopic s){
    final lectures = s.lectures;
    final lecture = lectures[_lectureIndex.clamp(0, lectures.length-1)];
    return Column(children:[
      _buildHeader(lecture.title, onBack: ()=> setState(()=> _currentSubtopic = null)),
      Expanded(
        child: PageView.builder(
          controller: PageController(initialPage: _lectureIndex),
          onPageChanged: (i)=> setState(()=> _lectureIndex = i),
          itemCount: lectures.length,
          itemBuilder: (_, i){
            final l = lectures[i];
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                Text(l.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...l.sections.map((sec)=> Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(sec, style: const TextStyle(fontSize: 16, height: 1.6)))).toList(),
              ]),
            );
          },
        ),
      ),
    ]);
  }

  Widget _buildHeader(String title, {VoidCallback? onBack}){
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(color: Colors.grey[100], border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
      child: Row(children:[
        if (onBack!=null) IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}


