class Clientdata < ActiveRecord::Base
validates_uniqueness_of :Date , :scope => [:GroupID,:ShopName,:MachineNo,:MachineName],:message=> "Duplicate Entry"
#validates_presense_of  :GroupID,:ShopName,:MachineNo,:MachineName
#
#   with_options :if => :driver? do |driver|
#    driver.validates_presence_of :truck_serial
#    driver.validates_length_of :truck_serial, :maximum => 30
#  end
end
