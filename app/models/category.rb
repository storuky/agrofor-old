class Category < ActiveRecord::Base
  has_many :options
  CATEGORY = [ "berries",
      "bobs",
      "corn",
      "dairy",
      "dried fruit",
      "eggs",
      "fish",
      "fruits",
      "herbs",
      "mushrooms",
      "feed for animals",
      "oilseeds",
      "meat",
      "honey",
      "flour",
      "nuts",
      "vegetable oil",
      "seafood",
      "seed ang seedlings",
      "sugar",
      "vegetables",
      "wheat",
      "wood",
      "fertilizers and chemicals"]

  def title_locale
    I18n.t('category.items.'+self.title)
  end
  
  def self.with_options
    # Rails.cache.fetch("with_options", expires_in: 12.hours) do
      query = {
                :only => [:id, :title],
                :methods => :title_locale,
                :include => {
                  :options => {
                    :methods => :title_locale,
                    :only => :id,
                    :include => {
                      :category => {
                        :only => [],
                        :methods => :title_locale
                      }
                    }
                  }
                }
              }

      Category.all.includes(:options).as_json(query).sort_by!{ |m| m["title_locale"] }
    # end
  end

  def self.with_options_group
    Category.with_options.index_by{|t| t["id"]}
  end
end
