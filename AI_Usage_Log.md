Date - 10/18/25 - Tobey Gray
Question - How to make the background image move when changing tabs?
Application -Instead of using an animated Positioned, use a stack with an animated builder to shift the background with the tabcontroller's animation.
Reflection - This showed me how to use the Positioned widget in an animatedbuilder to animate widget and how to utilzie the animation value used by the tab controller and how it changes with tab use.
-------------
Date - 10/18/25 - Tobey Gray
Question - How to move the background smoothly and allow it to cover the entire screen across tabs.
Application - Changes setting of tab index to be animated to, resulting in the controller being animated and smoothly transitioned. The background was made wider and now wraps so that the screen view is consistently wrapped when moving the background.
Reflection - This showed me how to adjust the way the index value in the tab controller is changed, making its change in value smooth if needed for purposes such as animating the background as well as how certain widgets might function outside of the screen view and how to ensure they behave properly when shifitng them into view.
-------------
Date - 10/22/25 - Amara Irobi
Question - How to make sure ingredients and  instructions are in a numbered/bulleteted list when viewing recipe details?
Application - Turns the lists into a map with keys and values that can be accessed using .entries. The entries are then looped through, the numbering starts at 1, and the instructions are assigned as the values in the map. The ingredients are also iterated through, and text widgets are made for each one.
Reflection - This showed me how to easily display data from a list by using keys and values, as well as aligning the text widget itself.
-------------
Date - 10/25/25 - Tobey Gray
Question - Modify queryitemswithfilters to wrok with the tags and recipe tags being stored in seperate tables
Application - Creates a list of conditions & arguments to add to to build a query string, adding as need be to account for use of filters/search, using INNER JOIN to select corresponding rows between tables and SELECTing from the recipe database with the previously created conditions/arguments lists to fill the WHERE clause.
Reflection - This showed how to join together not only tables in the rows where they are equal, but also how to join together a set of arguments to filter results down in a table.
-------------
Date - 10/25/25 - Tobey Gray
Question - Why am I getting error The following _TypeError was thrown building LayoutBuilder:
type 'Future<List<Map<String, dynamic>>>' is not a subtype of type 'List<Map<String, dynamic>>' in
type cast
Application - Initializes recipesList as a Future<List<Map<String>>>, initializes dbHelper and assigns it, and uses a FutureBuilder with the gridview to wait for the query to complete
Reflection - This shows how to adjust the initializing of a list as well as building of content/UI when dealing with async functions.
-------------
Date - 10/25/25 - Tobey Gray
Question - How to add up the quantity of ingredients from meals table
Application - Gets the list of recipeIDs in the meal planner, from which it gets the list of ingredients for each recipeID. For each recipe, for each row of the ingredients list, add them to a map.
Reflection - I was on the right track retrieving and searching with IDs, but wasn't sure how to add/store without creating duplicates in the list. This showed how to use the column names as keys to map so that for example 'beef' 'lbs' is stored but the 'qty' can be increased as rows containing 'beef' 'lbs' are added without creating duplicate entries. (note, 'beef' 'kg' would still appear)
-------------
Date - 10/26/25 - Tobey Gray
Question - How to include tags, instructions, and ingredients in share recipe tab
Application - Formats the UI so that ingredients is a row of fields for each column in the ingredients table and a field per instruction, each of which has a button to add an additional row or delete a row by adding/removing from their respective lists. The values of these lists are mapped to their appropriate tables in the db. Tags are created as filter chips which add/remove their value on toggle.
Reflection - I wasn't sure how to go about allowing input for the ingredients and instructions. I was considering creating additional fields for each column in the ingredients and also having one form field spliced by commas to create a list of instructions. This showed me how to create/remove additional fields dynamically. I was going to just use the normal checklist boxes for the tags, so I know about the filter chip widget now.
-------------
Date 10/26/25 - Amara Irobi
Question - How to ensure all recipes in database are called correctly and show up when card is pressed
Application - Add the recipeid in all db.insert tables and increase the version number of static const _databaseVersion.
Reflection - I had previous trouble seeing anything when I would click on a card. This showed me that hot reloading when dealing with databases is not enough, and that you must either uninstall the app(not ideal), or increase the database version number, so that SQl can re-run the new tables. The database setup should also merge all tables into one database, myrecipes.db.
-------------
Date 10/26/25 - Amara Irobi
Question - How to make sure the buttons on the recipe screen link back to its respective tab?
Application - The elevated buttons need to be edited so that navigator.pop can navigate to the appropriate tab index.
Reflection - This showed me how features in the app can be easily connected to one other, without too much headache.  
-------------

