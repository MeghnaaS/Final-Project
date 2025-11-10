import 'package:recipe_scraper/recipe_scraper.dart';


final recipe = await scrapeRecipe('https://www.allrecipes.com/recipe/228293/curry-stand-chicken-tikka-masala-sauce/');

if (recipe != null) {
print('Title: ${recipe.title}');
print('Description: ${recipe.description}');
print('Servings: ${recipe.servings}');
print('Total Time: ${recipe.totalTime}');
} else {
print('No recipe found at this URL');
}