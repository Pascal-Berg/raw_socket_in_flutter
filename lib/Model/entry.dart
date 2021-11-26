class Entry {
  final String username;
  final String entry;

  Entry(this.username, this.entry);

  Entry.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        entry = json['entry'];

  Map<String, dynamic> toJson() => {
    'username': username,
    'entry': entry,
  };
}


