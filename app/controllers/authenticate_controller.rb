class AuthenticateController < ApplicationController
    # 회원가입 페이지
    def sign_up
        @user = User.new
    end
    # 실제 회원가입 로직
    def user_sign_up
        @user = User.new(user_name: params[:user_name], password: params[:password], password_confirmation: params[:confirmation])
        if @user.save
            redirect_to root_path, flash: {success: '회원가입 성공'}  
        else
            p @user.errors
            redirect_to :back, flash: {success: '회원가입 실패'}  
        end
    end
    
    # 로그인 페이지
    def sign_in
        
    end
    # 실제 로그인 로직
    def user_sign_in
        @user = User.find_by(user_name: params[:user_name])
        # bcrypt의 메서드인 authenticate를 사용해 비교
        if @user.present? and @user.authenticate(params[:password])
            session[:sign_in_user] = @user.id
            redirect_to root_path, flash: {alert: '로그인 되었습니다.'}    
        else
            p @user.errors
            redirect_to :back, flash: {error: '로그인 정보를 확인하십시오.'}
        end
    end
    
    # 유저 정보 페이지
    # 로그아웃 로직
    def sign_out
        session.delete(:sign_in_user)
        redirect_to :back, flash: {warning: '로그아웃 되었습니다.'}
    end

end
