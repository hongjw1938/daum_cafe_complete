class CafesController < ApplicationController
    before_action :authenticate_user, except: [:index, :show]
    
    # 전체 카페 목록보여주는 페이지
    # -> 로그인 하지 않았을 때: 전체 카페 목록
    # -> 로그인 했을 때: 유저가 가입한 카페 목록
    def index
        @cafes = Daum.all
        
    end
    
    
    # 카페 내용물을 보여주는 페이지
    def show
       @cafe = Daum.find(params[:id])
       #session[:current_cafe] = @cafe.id
    end
    
    # 카페를 개설하는 페이지
    def new
        @cafe = Daum.new
    end
    
    # 카페를 실제로 개설하는 로직
    def create
       @cafe = Daum.new(daum_params)
       @cafe.master_name = current_user.user_name
       if @cafe.save
           Membership.create(daum_id: @cafe.id, user_id: current_user.user_name)
           #show 쪽으로 보낸다. 객체를 넣으면 해당 id를 찾아서 전달함.
           redirect_to cafe_path(@cafe), flash: {success: "카페가 개설되었습니다."}
       else
           # debugging을 위해 실패시 서버에 로그를 찍는다.
           p @cafe.errors
           redirect_to :back, flash: {danger: "카페 개설에 실패했습니다."}
           
       end
       
       
    end
    
    # 카페 정보를 수정하는 페이지
    def edit
        @cafe = Daum.find(params[:id])
        
    end
    # 카페 정보를 실제로 수정하는 로직
    def update
        if @cafe.update(daum_params)
            
            redirect_to cafes_path, flash: {success: '수정되었습니다.'}
        end
    end
    
    def join_cafe
        # 이 카페에 현재 로그인된 사용자가 가입이 됐는지 확인
        
        # 중복 가입을 막을 수 없음
        # 1. 가입버튼을 보이지 않게 설정.(사용자 화면 조작) -> Model 코딩
        # 2. 중복 가입 체크 후 진행(서버에서 로직 조작) -> Model 조건 추가(Validation)
            # Validation 사용 방법 추가(uniqueness)
                # -> validates_uniqueness_of :user_id scope: :daum_id
                # 위 코드는 Membership에 추가하면, 한 번 참조된 관계일 때는 추가적으로 관계 형성하지 않게 도니다.
        
        # 현재 가입하려는 카페
        cafe = Daum.find(params[:cafe_id])
        
        # 사용자가 가입하려는 카페에 현재 유저가 이미 포함되어 있는가?
        if cafe.is_member?(current_user)
            # 가입 실패
            redirect_to :back, flash: {danger: "이미 가입된 카페입니다."}
        else
            # 가입 성공
            Membership.create(daum_id: params[:cafe_id], user_id: current_user.id)
            redirect_to :back, flash: {success: "카페 가입에 성공했습니다."}
        end
        
       
        
    end
    
    
    private
    def daum_params
        #require 뒤에 들어가는 것은 model명 사용
      params.require(:daum).permit(:title, :description)
      # :params: => {:daum => {:title => "..."}, {:description => "..."}}
    end
end
