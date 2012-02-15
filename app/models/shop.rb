class Shop < ActiveRecord::Base
    validates_presence_of :ShopName, :on=> :create
    validates_presence_of :ShopName, :on=> :update
    
    validates_uniqueness_of :ShopName, :on=> :create
    validates_uniqueness_of :ShopName, :on=>:update
    
    validates_presence_of :ClusterName, :on=> :create
    validates_presence_of :ClusterName, :on=> :update
    
     
    validates_numericality_of :OpeningBal, :message=>"must be a numberic value"
    validates_presence_of :OpeningBal, :on=> :create

   validates_numericality_of :os, :message=>"must be a numberic value"
    validates_presence_of :os, :on=> :create
    
    validates_presence_of :Address, :on=>:create
    validates_presence_of :Address, :on=>:update
   # has_many :groups, :foreign_key=>'ShopName',:class_name=>'Groups',:dependent=>:destroy
    
def self.all_shop_name_list
   Shop.find(:all,:select=>"ShopName",:order=>"ShopName").collect(&:ShopName)
end

def self.selected_shop_name_list(cluster_name)
  Shop.find(:all,:select=>"ShopName",:conditions=>["ClusterName=?",cluster_name],:order=>"ShopName").collect(&:ShopName)
end
    
   
end
