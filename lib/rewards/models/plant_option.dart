class PlantOption {
  final String id;
  final String name;
  final String tamilName;
  final String description;
  final String emoji;
  final bool isCustom;

  const PlantOption({
    required this.id,
    required this.name,
    required this.tamilName,
    required this.description,
    required this.emoji,
    this.isCustom = false,
  });

  static List<PlantOption> defaultPlants() {
    return const [
      PlantOption(
        id: 'sembaruthi',
        name: 'Sembaruthi',
        tamilName: 'செம்பருத்தி',
        description: 'Hibiscus is excellent for heart health, herbal teas, and haircare. Rich in vitamin C and antioxidants.',
        emoji: '🌺',
      ),
      PlantOption(
        id: 'sevanthi',
        name: 'Sevanthi',
        tamilName: 'செவந்தி',
        description: 'Chrysanthemums symbolize joy, optimization, and purity. Highly effective at purifying indoor air.',
        emoji: '🌼',
      ),
      PlantOption(
        id: 'rose',
        name: 'Rose',
        tamilName: 'ரோஜா',
        description: 'Rose plants are beautiful, soothing, and produce cooling petals widely used in traditional remedies.',
        emoji: '🌹',
      ),
      PlantOption(
        id: 'tulsi',
        name: 'Tulsi',
        tamilName: 'துளசி',
        description: 'Holy Basil is a sacred home plant with powerful immunity-boosting, stress-relief, and air-purifying properties.',
        emoji: '🌿',
      ),
    ];
  }
}
