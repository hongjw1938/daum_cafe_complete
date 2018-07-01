class User < ApplicationRecord
    has_secure_password
    
    # user컬럼에 unique 속성 부여
    validates :user_name, uniqueness: true,
                        presence: true #빈 값을 허용하지 않음.
    
    has_many :memberships
    has_many :daums, through: :memberships
    has_many :posts
end
