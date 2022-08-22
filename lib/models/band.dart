class Band {
  String id;
  String name;
  int votes;

  Band({
    required this.id,
    required this.name,
    this.votes = 0,
  });

  factory Band.fromMap(Map<String, dynamic> map) => Band(
        id: map["id"],
        name: map["name"],
        votes: map["votes"],
      );
}
