class Daum < ApplicationRecord
    has_many :memberships
    has_many :users, through: :memberships
    has_many :posts
    
    # 인스턴스 메소드를 사용해 특정 메소드를 모델에 추가할 수 있다.
    # 이 인스턴스 메소드로 이미 카페에 가입된 유저인지 확인하고자 한다.
    # 이 때, self는 카페 객체이며, user로 받는 parameter는 현재의 유저이다.
    # 만약, 매개변수를 받지 않고 모델에서 직접 current_user를 사용한다거나 하는 방식은 매우 위험하다.
    def is_member?(user)
        self.users.include?(user)
    end
end
