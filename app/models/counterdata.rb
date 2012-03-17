class Counterdata < ActiveRecord::Base
  validates_uniqueness_of :Date , :scope => [:ClusterName,:ShopName],:message=> "Duplicate Entry"
end
