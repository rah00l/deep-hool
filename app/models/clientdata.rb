class Clientdata < ActiveRecord::Base
validates_uniqueness_of :Date , :scope => [:GroupID,:ShopName,:MachineNo,:MachineName],:message=> "Duplicate Entry"
end
