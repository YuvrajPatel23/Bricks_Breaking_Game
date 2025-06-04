class Level {
  final int number;
  final List<List<int>> brickLayout;
  final String description;

  Level({
    required this.number,
    required this.brickLayout,
    required this.description,
  });
}

class LevelManager {
  static List<Level> get levels => [
    Level(
      number: 1,
      description: "Basic Pattern",
      brickLayout: [
        [1, 1, 1, 1, 1, 1, 1, 1],
        [1, 2, 2, 2, 2, 2, 2, 1],
        [1, 2, 3, 3, 3, 3, 2, 1],
        [1, 2, 2, 2, 2, 2, 2, 1],
        [1, 1, 1, 1, 1, 1, 1, 1],
      ],
    ),
    Level(
      number: 2,
      description: "Diamond Formation",
      brickLayout: [
        [0, 0, 0, 3, 3, 0, 0, 0],
        [0, 0, 3, 2, 2, 3, 0, 0],
        [0, 3, 2, 1, 1, 2, 3, 0],
        [3, 2, 1, 0, 0, 1, 2, 3],
        [3, 2, 1, 0, 0, 1, 2, 3],
      ],
    ),
    Level(
      number: 3,
      description: "Hardcore Challenge",
      brickLayout: [
        [4, 4, 4, 4, 4, 4, 4, 4],
        [3, 0, 3, 0, 0, 3, 0, 3],
        [2, 2, 0, 2, 2, 0, 2, 2],
        [1, 0, 1, 0, 0, 1, 0, 1],
        [3, 3, 0, 3, 3, 0, 3, 3],
      ],
    ),
  ];
}