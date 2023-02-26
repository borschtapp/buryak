class Recipe {
  String? url;
  String? name;
  String? description;
  String? language;
  List<ImageObject>? image;
  Person? author;
  String? text;
  int? prepTime;
  int? cookTime;
  int? totalTime;
  String? difficulty;
  String? cookingMethod;
  List<String>? suitableForDiet;
  List<String>? recipeCategory;
  List<String>? recipeCuisine;
  List<String>? keywords;
  int? recipeYield;
  List<String>? recipeIngredient;
  List<String>? recipeEquipment;
  List<HowToSection>? recipeInstructions;
  List<String>? notes;
  NutritionInformation? nutrition;
  AggregateRating? aggregateRating;
  int? commentCount;
  VideoObject? video;
  List<String>? links;
  Organization? publisher;
  String? dateModified;
  String? datePublished;

  Recipe({
    this.url,
    this.name,
    this.description,
    this.language,
    this.image,
    this.author,
    this.text,
    this.prepTime,
    this.cookTime,
    this.totalTime,
    this.difficulty,
    this.cookingMethod,
    this.suitableForDiet,
    this.recipeCategory,
    this.recipeCuisine,
    this.keywords,
    this.recipeYield,
    this.recipeIngredient,
    this.recipeEquipment,
    this.recipeInstructions,
    this.notes,
    this.nutrition,
    this.aggregateRating,
    this.commentCount,
    this.video,
    this.links,
    this.publisher,
    this.dateModified,
    this.datePublished,
  });

  Recipe.fromJson(Map<String, dynamic> json) {
    if (json['url'] != null) {
      url = json['url'];
    }
    if (json['name'] != null && json['name'].isNotEmpty) {
      name = json['name'];
    }
    description = json['description'];
    language = json['language'];
    if (json['image'] != null) {
      image = <ImageObject>[];
      json['image'].forEach((v) {
        image!.add(ImageObject.fromJson(v));
      });
    }
    if (json['author'] != null) {
      author = Person.fromJson(json['author']);
    }
    text = json['text'];
    prepTime = json['prepTime'];
    cookTime = json['cookTime'];
    totalTime = json['totalTime'];
    difficulty = json['difficulty'];
    cookingMethod = json['cookingMethod'];
    suitableForDiet = json['suitableForDiet'];
    recipeYield = json['recipeYield'];
    if (json['recipeCategory'] != null) {
      recipeCategory = json['recipeCategory'].cast<String>();
    }
    if (json['recipeCuisine'] != null) {
      recipeCuisine = json['recipeCuisine'].cast<String>();
    }
    if (json['keywords'] != null) {
      keywords = json['keywords'].cast<String>();
    }
    if (json['recipeIngredient'] != null) {
      recipeIngredient = json['recipeIngredient'].cast<String>();
    }
    if (json['recipeEquipment'] != null) {
      recipeEquipment = json['recipeEquipment'].cast<String>();
    }
    if (json['recipeInstructions'] != null) {
      recipeInstructions = <HowToSection>[];
      json['recipeInstructions'].forEach((v) {
        recipeInstructions!.add(HowToSection.fromJson(v));
      });
    }
    if (json['notes'] != null) {
      notes = json['notes'].cast<String>();
    }
    nutrition = json['nutrition'] != null ? NutritionInformation.fromJson(json['nutrition']) : null;
    aggregateRating = json['aggregateRating'] != null ? AggregateRating.fromJson(json['aggregateRating']) : null;
    commentCount = json['commentCount'];
    video = json['video'] != null ? VideoObject.fromJson(json['video']) : null;
    if (json['links'] != null) {
      links = json['links'].cast<String>();
    }
    publisher = json['publisher'] != null ? Organization.fromJson(json['publisher']) : null;
    dateModified = json['dateModified'];
    datePublished = json['datePublished'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['name'] = name;
    data['description'] = description;
    data['language'] = language;
    if (image != null) {
      data['image'] = image!.map((v) => v.toJson()).toList();
    }
    if (author != null) {
      data['author'] = author!.toJson();
    }
    data['text'] = text;
    data['prepTime'] = prepTime;
    data['cookTime'] = cookTime;
    data['totalTime'] = totalTime;
    data['difficulty'] = difficulty;
    data['cookingMethod'] = cookingMethod;
    data['suitableForDiet'] = suitableForDiet;
    data['recipeCategory'] = recipeCategory;
    data['recipeCuisine'] = recipeCuisine;
    data['keywords'] = keywords;
    data['recipeYield'] = recipeYield;
    data['recipeIngredient'] = recipeIngredient;
    data['recipeEquipment'] = recipeEquipment;
    if (recipeInstructions != null) {
      data['recipeInstructions'] = recipeInstructions!.map((v) => v.toJson()).toList();
    }
    data['notes'] = notes;
    if (nutrition != null) {
      data['nutrition'] = nutrition!.toJson();
    }
    if (aggregateRating != null) {
      data['aggregateRating'] = aggregateRating!.toJson();
    }
    data['commentCount'] = commentCount;
    if (video != null) {
      data['video'] = video!.toJson();
    }
    data['links'] = links;
    if (publisher != null) {
      data['publisher'] = publisher!.toJson();
    }
    data['dateModified'] = dateModified;
    data['datePublished'] = datePublished;
    return data;
  }

  String? getCombinedAuthor() {
    if (publisher != null) {
      if (author != null) {
        return '${publisher!.name ?? ''} / ${author!.name ?? ''}';
      } else {
        return publisher!.name ?? '';
      }
    }

    if (author != null) {
      return author!.name ?? '';
    }

    return null;
  }
}

class VideoObject {
  String? name;
  String? description;
  String? duration;
  String? embedUrl;
  String? contentUrl;
  String? thumbnailUrl;
  DateTime? uploadDate;

  VideoObject({
    this.name,
    this.description,
    this.duration,
    this.embedUrl,
    this.contentUrl,
    this.thumbnailUrl,
    this.uploadDate,
  });

  VideoObject.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    description = json['description'];
    duration = json['duration'];
    embedUrl = json['embedUrl'];
    contentUrl = json['contentUrl'];
    thumbnailUrl = json['thumbnailUrl'];
    uploadDate = json['uploadDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['description'] = description;
    data['duration'] = duration;
    data['embedUrl'] = embedUrl;
    data['contentUrl'] = contentUrl;
    data['thumbnailUrl'] = thumbnailUrl;
    data['uploadDate'] = uploadDate;
    return data;
  }
}

class ImageObject {
  String? url;
  int? width;
  int? height;
  String? caption;

  ImageObject({
    this.url,
    this.width,
    this.height,
    this.caption,
  });

  ImageObject.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    width = json['width'];
    height = json['height'];
    caption = json['caption'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['width'] = width;
    data['height'] = height;
    data['caption'] = caption;
    return data;
  }
}

class Person {
  String? name;
  String? knowsAbout;
  String? jobTitle;
  String? description;
  String? url;
  String? image;

  Person({
    this.name,
    this.knowsAbout,
    this.jobTitle,
    this.description,
    this.url,
    this.image,
  });

  Person.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    knowsAbout = json['knowsAbout'];
    jobTitle = json['jobTitle'];
    description = json['description'];
    url = json['url'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['knowsAbout'] = knowsAbout;
    data['jobTitle'] = jobTitle;
    data['description'] = description;
    data['url'] = url;
    data['image'] = image;
    return data;
  }
}

class HowToStep {
  String? name;
  String? text;
  String? url;
  String? image;
  String? video;

  HowToStep({
    this.name,
    this.text,
    this.url,
    this.image,
    this.video,
  });

  HowToStep.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    text = json['text'];
    url = json['url'];
    image = json['image'];
    video = json['video'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['text'] = text;
    data['url'] = url;
    data['image'] = image;
    data['video'] = video;
    return data;
  }
}

class HowToSection extends HowToStep {
  List<HowToStep>? itemListElement;

  HowToSection({
    this.itemListElement,
  });

  HowToSection.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    text = json['text'];
    url = json['url'];
    image = json['image'];
    video = json['video'];
    if (json['itemListElement'] != null) {
      itemListElement = <HowToStep>[];
      json['itemListElement'].forEach((v) {
        itemListElement!.add(HowToStep.fromJson(v));
      });
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (itemListElement != null) {
      data['name'] = name;
      data['text'] = text;
      data['url'] = url;
      data['image'] = image;
      data['video'] = video;
      data['itemListElement'] = itemListElement!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NutritionInformation {
  String? calories;
  String? servingSize;
  String? carbohydrateContent;
  String? cholesterolContent;
  String? fatContent;
  String? fiberContent;
  String? proteinContent;
  String? saturatedFatContent;
  String? sodiumContent;
  String? sugarContent;
  String? transFatContent;
  String? unsaturatedFatContent;

  NutritionInformation({
    this.calories,
    this.servingSize,
    this.carbohydrateContent,
    this.cholesterolContent,
    this.fatContent,
    this.fiberContent,
    this.proteinContent,
    this.saturatedFatContent,
    this.sodiumContent,
    this.sugarContent,
    this.transFatContent,
    this.unsaturatedFatContent,
  });

  NutritionInformation.fromJson(Map<String, dynamic> json) {
    calories = json['calories'];
    servingSize = json['servingSize'];
    carbohydrateContent = json['carbohydrateContent'];
    cholesterolContent = json['cholesterolContent'];
    fatContent = json['fatContent'];
    fiberContent = json['fiberContent'];
    proteinContent = json['proteinContent'];
    saturatedFatContent = json['saturatedFatContent'];
    sodiumContent = json['sodiumContent'];
    sugarContent = json['sugarContent'];
    transFatContent = json['transFatContent'];
    unsaturatedFatContent = json['unsaturatedFatContent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['calories'] = calories;
    data['servingSize'] = servingSize;
    data['carbohydrateContent'] = carbohydrateContent;
    data['cholesterolContent'] = cholesterolContent;
    data['fatContent'] = fatContent;
    data['fiberContent'] = fiberContent;
    data['proteinContent'] = proteinContent;
    data['saturatedFatContent'] = saturatedFatContent;
    data['sodiumContent'] = sodiumContent;
    data['sugarContent'] = sugarContent;
    data['transFatContent'] = transFatContent;
    data['unsaturatedFatContent'] = unsaturatedFatContent;
    return data;
  }
}

class Organization {
  String? name;
  String? url;
  String? logo;

  Organization({
    this.name,
    this.url,
    this.logo,
  });

  Organization.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    url = json['url'];
    logo = json['logo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['url'] = url;
    data['logo'] = logo;
    return data;
  }
}

class AggregateRating {
  int? reviewCount;
  int? ratingCount;
  double? ratingValue;
  int? bestRating;
  int? worstRating;

  AggregateRating({
    this.reviewCount,
    this.ratingCount,
    this.ratingValue,
    this.bestRating,
    this.worstRating,
  });

  AggregateRating.fromJson(Map<String, dynamic> json) {
    reviewCount = json['reviewCount'];
    ratingCount = json['ratingCount'];
    ratingValue = json['ratingValue'];
    bestRating = json['bestRating'];
    worstRating = json['worstRating'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reviewCount'] = reviewCount;
    data['ratingCount'] = ratingCount;
    data['ratingValue'] = ratingValue;
    data['bestRating'] = bestRating;
    data['worstRating'] = worstRating;
    return data;
  }
}

class RecipeModel {
  String title, writer, description;
  int cookingTime;
  int servings;
  List<String> ingredients = [];
  String imgPath;

  RecipeModel({
    required this.title,
    required this.writer,
    required this.description,
    required this.cookingTime,
    required this.servings,
    required this.imgPath,
    required this.ingredients,
  });

  static List<RecipeModel> demoRecipe = [
    RecipeModel(
      title: 'Gruyère, Bacon, and Spinach Scrambled Eggs',
      writer: "Imran Sefat",
      description:
          'A touch of Dijon mustard, salty bacon, melty cheese, and a handful of greens seriously upgrades scrambled eggs, without too much effort!',
      cookingTime: 10,
      servings: 4,
      imgPath: 'assets/images/img1.jpg',
      ingredients: [
        '8 large eggs',
        '1 tsp. Dijon mustard',
        'Kosher salt and pepper',
        '1 tbsp. olive oil or unsalted butter',
        '2 slices thick-cut bacon, cooked and broken into pieces',
        '2 c. spinach, torn',
        '2 oz. Gruyère cheese, shredded',
      ],
    ),
    RecipeModel(
      title: 'Classic Omelet and Greens ',
      writer: "Imran Sefat",
      description:
          'Sneak some spinach into your morning meal for a boost of nutrients to start your day off right.',
      cookingTime: 10,
      servings: 4,
      imgPath: 'assets/images/img2.jpg',
      ingredients: [
        '8 large eggs',
        '1 tsp. Dijon mustard',
        'Kosher salt and pepper',
        '1 tbsp. olive oil or unsalted butter',
        '2 slices thick-cut bacon, cooked and broken into pieces',
        '2 c. spinach, torn',
        '2 oz. Gruyère cheese, shredded',
      ],
    ),
    RecipeModel(
      title: 'Sheet Pan Sausage and Egg Breakfast Bake ',
      writer: "Imran Sefat",
      description:
          'A hearty breakfast that easily feeds a family of four, all on one sheet pan? Yes, please.',
      cookingTime: 10,
      servings: 4,
      imgPath: 'assets/images/img3.jpg',
      ingredients: [
        '8 large eggs',
        '1 tsp. Dijon mustard',
        'Kosher salt and pepper',
        '1 tbsp. olive oil or unsalted butter',
        '2 slices thick-cut bacon, cooked and broken into pieces',
        '2 c. spinach, torn',
        '2 oz. Gruyère cheese, shredded',
      ],
    ),
    RecipeModel(
      title: 'Shakshuka',
      writer: "Imran Sefat",
      description:
          'Just wait til you break this one out at the breakfast table: sweet tomatoes, runny yolks, and plenty of toasted bread for dipping.',
      cookingTime: 10,
      servings: 4,
      imgPath: 'assets/images/img4.jpg',
      ingredients: [
        '8 large eggs',
        '1 tsp. Dijon mustard',
        'Kosher salt and pepper',
        '1 tbsp. olive oil or unsalted butter',
        '2 slices thick-cut bacon, cooked and broken into pieces',
        '2 c. spinach, torn',
        '2 oz. Gruyère cheese, shredded',
      ],
    ),
  ];
}
