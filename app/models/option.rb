class Option < ActiveRecord::Base
  belongs_to :category
  has_many :position

  OPTIONS = {
    "berries" => ["watermelon", "barberry", "cowberry", "elder", "grapes", "goji berries", "blueberry", "cherry", "melon", "blackberries", "strawberry", "shadberry", "viburnum", "dogwood", "strawberry", "cranberry", "redcurrant", "gooseberry", "lemongrass", "raspberry", "cloudberry", "sea buckthorn", "green olives", "rowan", "blackthorn", "feijoa ", "physalis", "cherry", "blackberry", "blueberry", "bird-cherry tree", "chokeberry", "mulberry", "briar"], 
    "bobs" => ["mung beans", "vetch", "peas", "lupine", "chick-pea", "soy", "beans", "lentil", "chin"],
    "corn" => ["corn sugar", "waxy maize", "corn filmy", "corn burst", "dent corn", "starchy corn", "corn siliceous"],
    "dairy" => ["milk", "cheese", "feta cheese", "butter", "cream", "sour cream", "cottage cheese"],
    "dried fruit" => ["raisins", "fig", "dried apricots", "date", "prune"],
    "eggs" => ["goose eggs", "turkey eggs", "chicken eggs", "quail eggs", "ostrich eggs", "duck eggs"],
    "fish" => ["anchovies", "red mullet (sultan)", "chub", "pink salmon", "dorado", "ruff", "lancet fish", "flounder", "crucian", "carp", "dog-salmon", "mullet", "smelt", "tench", "bream", "bluefish", "mackerel", "pollack", "capelin", "sea bass", "burbot", "perch", "sturgeon", "halibut", "haddock", "roach", "carp", "sprat", "sardine", "herring", "salmon", "whitefish", "mackerel", "catfish", "horse mackerel", "sterlet", "zander", "carp", "cod", "tuna", "trout", "hake", "pike", "ide"],
    "fruits" => ["apricot", "avocado", "quince", "cherry-plum", "pineapple", "annona (guanabana)", "orange", "banana", "garnet", "grapefruit", "pear", "guava", "jackfruit", "draconian fruit (pitahaya)", "durian", "carambola", "kiwi", "clementines", "kumquat", "lime", "lemon", "lichee", "mango", "mangosteen", "tangerine", "passionfruit", "medlar", "nectarine", "papaya", "peach", "witch's broom", "rambutan", "sweetie", "plum", "persimmon", "apple"],
    "herbs" => ["artichoke", "asparagus", "basil", "parsley", "lettuce", "celery", "dill", "chicory", "wild leek", "spinach", "sorrel"],
    "mushrooms" => ["cep (boletus)", "oyster mushrooms", "milk mushroom", "ivishen (clitopilus prunulus)", "chanterelles", "boletus", "flywheel", "mushrooms", "boletus", "orange-cap boletus", "saffron milk cap", "morels", "russule", "truffle", "champignon", "shiitake"],
    "feed for animals" => ["vitamins", "cake", "pulp", "wms", "ingredients", "fodder", "feed additives", "meat meal", "meat and bone meal", "bran", "premixes", "fishmeal", "silage", "soy", "schroth"],
    "oilseeds" => ["mustard", "coriander", "sesame", "flax", "sunflower", "rape", "cumin"],
    "meat" => ["lamb", "bacon", "cold boiled pork", "ham", "beef ", "hare", "goat meat", "horsemeat", "rabbit", "venison", "liver", "fat", "pork", "veal", "meat language"],
    "honey" => ["linden honey", "acacia honey", "sunflower honey", "buckwheat honey", "raspberry honey", "barberry honey", "cornflower honey", "heather honey", "honey mustard", "blackberry honey", "pumpkin honey", "melissovy honey", "clover honey", "mint honey", "dandelion honey", "ryabinovny honey", "blueberry honey", "sage honey", "carrot honey", "may honey", "meadow honey", "forest honey", "field honey", "mountain honey", "tobacco honey", "stone honey", "powdered honey", "comb"],
    "flour" => ["wheat top grade flour", "wheat first grade flour", "wheat second grade flour", "flaxseed oil", "olive oil"],
    "nuts" => ["peanuts", "brazil nuts ", "walnut", "chestnut", "pine nuts", "cashew", "coconut", "almonds", "nutmeg", "pistachios", "hazelnut"],
    "vegetable oil" => ["sunflower oil", "peanut oil", "mustard oil", "sesame oil ", "corn oil", "rapeseed oil", "soybean oil"],
    "seafood" => ["algae", "squid", "crab", "shrimp", "crayfish", "scampi", "lobster", "mussel", "laminaria", "scallops", "octopus", "trepang", "oyster"],
    "seed ang seedlings" => ["seed", "seedlings"],
    "sugar" => ["sugar", "cane sugar", "lump sugar", "candy sugar"],
    "vegetables" => ["arrowroot", "eggplant", "rutabaga", "buryak", "squash ", "capers", "white cabbage", "broccoli", "brussels sprouts", "cabbage", "cabbage", "cauliflower", "potato", "corn", "onions", "leek", "shallot", "carrot", "cucumber", "parsnip", "squash", "sweet pepper", "tomato", "cherry tomatoes", "radishes", "radish", "turnip", "beet", "pumpkin", "horseradish", "zucchini", "garlic"],
    "wheat" => ["buckwheat", "wheat", "rice", "rye", "barley"],
    "wood" => ["firewood", "sawdust"],
    "fertilizers and chemicals" => ["biofertilizers", "herbicides", "primers", "pesticides", "plant protection products", "fertilizers"]
  }

  def title_locale
    I18n.t('option.'+title)
  end
end
