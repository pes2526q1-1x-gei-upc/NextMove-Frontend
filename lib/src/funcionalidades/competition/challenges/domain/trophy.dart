class Trophy {
  final int id;
  final String imagePath;

  const Trophy(this.id, this.imagePath);
  Trophy.fromChallengeName(String challengeName)
    : id = challengeName.hashCode % numTrophies + 1,
      imagePath =
          'assets/trophies/${(challengeName.hashCode % numTrophies) + 1}.png';

  static const int numTrophies = 15;

  static final List<Trophy> allLoop = List.generate(
    numTrophies,
    (index) => Trophy(index + 1, 'assets/trophies/${index + 1}.png'),
  );

  static List<Trophy> get all => allLoop;

  static Trophy getById(int id) {
    return all.firstWhere((trophy) => trophy.id == id);
  }
}
