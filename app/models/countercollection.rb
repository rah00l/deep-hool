class Countercollection < ActiveRecord::Base
  validates_uniqueness_of :Date , :scope => [:ClusterName,:ShopName],:message=> "Duplicate Entry"
  validates_presence_of :HC,:Outstanding
end


