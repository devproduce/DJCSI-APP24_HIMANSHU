class Note {
  int? id;
  String title;
  String description = '';
  String tag;

  // Constructor without id (used when inserting a new note)
  Note({
    required this.title,
    required this.description,
    required this.tag,
  });

  // Named constructor with id (used when fetching notes from the database)
  Note.withId({
    required this.id,
    required this.title,
    required this.description,
    required this.tag,
  });

  // Convert a Note object to a Map object (for database insertion)
  Map<String, dynamic> noteToMap() {
    var map = <String, dynamic>{
      'title': title,
      'description': description,
      'tag': tag,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  // Convert a Map object to a Note object (for retrieving data from the database)
  factory Note.mapToNote(Map<String, dynamic> map) {
    return Note.withId(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      tag: map['tag'],
    );
  }
}
