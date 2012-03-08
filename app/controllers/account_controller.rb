class AccountController < ApplicationController
  model   :user
#  after_login :check_for_new_password
  #LOGIN METHOD FOR CHECKING AUTHENTICITY
  def login
    case @request.method
    when :post
      @session['uname']=@params['user_login']
      @session['pass']=@params['user_password']
      if @session['user'] = User.authenticate(@params['user_login'], @params['user_password'])
				@result=User.login_type(@params['user_login'],@params['user_password'])
        if @result.userstatus==1
          @user=User.find(@result.id)
          @user.loginstatus='Y'
          @user.save
          if @result.usertype=="Admin"
            redirect_to  :controller => 'users',:action => "main"
          else
            redirect_to  :controller => 'users',:action => "client"
          end
        else
          @message="You cannot login !!"
        end
      else
        @login    = @params['user_login']
        @check_for_changed_pass = true
        @message  = "Login unsuccessful"
      end
    end
  end
  
  def signup
    case @request.method
    when :post
      @user = User.new(@params['user'])
      if @user.save
        @session['user'] = User.authenticate(@user.login, @params['user']['password'])
        flash['notice']  = "Signup successful"
        redirect_back_or_default :action => "welcome"
      end
    when :get
      @user = User.new
    end      
  end  
  
  
  def delete
      
    if @params['id'] and @session['user']
      @user = User.find(@params['id'])
      @user.destroy
    end
    redirect_back_or_default :action => "welcome"
  end  
   
  def logout
    begin
      cookies.delete :user_id
      @user=User.find_first(["login=?",@session['user']['login']])
      @c=User.update(@user.id,{:loginstatus=>'N'})
      @session['user'] = nil
    rescue Exception => exc
      STDERR.puts "Error is #{exc.message}"
    end
  end
    
  def welcome
  end

  def check_for_new_password
    if params[:user_name]
      user = User.find_by_login(params[:user_name])
      @user = user.reset_pass if user
    end
  end
end
