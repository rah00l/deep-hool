#For Weekly password reset functionality write a rake task .
namespace :password_reset do
  desc 'Weekly password reset functionality'
	task :for_users => :environment do

#    User.find_all_by_reset_pass(nil).each do |user|
#        pass = "R#{Array.new(4){rand(4)}.join}"
#        user.change_password(pass)
#        user.update_attribute "reset_pass", pass
#    end

    User.find(:all).each do |user|
        pass = "R#{Array.new(4){rand(4)}.join}"
        user.change_password(pass)
        user.update_attribute "reset_pass", pass
    end
    

	end

end