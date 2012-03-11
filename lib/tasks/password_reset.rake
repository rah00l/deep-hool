#For Weekly password reset functionality written following rake tasks .
namespace :password_reset do
  desc 'Weekly password reset functionality'
	task :for_users_expired => :environment do

    User.find(:all).each do |user|
     unless user.usertype.eql?('SuperAdmin') || user.usertype.eql?('Admin')
        pass = rand(36**5).to_s(36)
        user.change_password(pass)
        user.update_attribute "reset_pass", "EXPIRED"
        end
    end

  end

  task :for_users => :environment do
    User.find(:all).each do |user|
      unless user.usertype.eql?('SuperAdmin') || user.usertype.eql?('Admin')
      pass = rand(36**5).to_s(36)
        user.change_password(pass)
        user.update_attribute "reset_pass", pass
      end
    end
	end
end