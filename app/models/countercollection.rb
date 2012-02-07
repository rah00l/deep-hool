class Countercollection < ActiveRecord::Base
  validates_uniqueness_of :Date , :scope => [:ClusterName,:ShopName],:message=> "Duplicate Entry"
  validates_presence_of :HC,:Outstanding
  validate :check_os_in_multiples_of_five_hundred


  def check_os_in_multiples_of_five_hundred
    if self.Outstanding.to_i % 500 != 0
      self.errors.add_to_base("PLEASE ENTER AMOUNT IN MULTIPLES OF  0  OR  500 ")
    end
  end
  
end


