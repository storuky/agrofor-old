config =  {
            :with => :active_record,
            :delta => true
          }

ThinkingSphinx::Index.define :position, config do
  indexes index_field
  where "status = 'opened'"
  has trade_type
  has option_id
  has city
  has weight_min_etalon
  has weight_etalon
  has user_id
end