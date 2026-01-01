class Cookbook {
  final String id;
  final String title;
  final String image;
  final int recipesCount;
  final int membersCount;

  const Cookbook({
    required this.id,
    required this.title,
    required this.image,
    required this.recipesCount,
    required this.membersCount,
  });

  static List<Cookbook> get dummyData {
    return [
      const Cookbook(
        id: '1',
        title: 'Ukrainian cuisine',
        image:
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1760&q=80',
        recipesCount: 5,
        membersCount: 5,
      ),
      const Cookbook(
        id: '2',
        title: 'Pasta',
        image:
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1760&q=80', // Placeholder
        recipesCount: 3,
        membersCount: 0,
      ),
      const Cookbook(
        id: '3',
        title: 'Desserts',
        image:
            'https://images.unsplash.com/photo-1563729768-6afa84d84028?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1760&q=80',
        recipesCount: 12,
        membersCount: 2,
      ),
      const Cookbook(
        id: '4',
        title: 'Healthy Breakfast',
        image:
            'https://images.unsplash.com/photo-1511690656952-34342d5cca24?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1760&q=80',
        recipesCount: 8,
        membersCount: 1,
      ),
    ];
  }
}
