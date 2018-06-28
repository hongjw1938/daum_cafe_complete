### 전체 카페 구현(daum_cafe)
* 기본 내용
    - 모델
        - daum(cafe를 의미), user, post(게시글 - 각 카페에 저장됨), membership(카페와 유저 M:N관계 join table), comment(댓글)
    - 컨트롤러
        - cafe, user, authenticate(회원가입, 로그인 등), comment, post
    - view
        - 
* rails 설정
    - route
        - resources 사용시 각 RESTful URL이 생성됨.
    - gem
        - bootstrap : 부트스트랩의 UI 사용
        - bcrypt : 비밀번호 암호화하여 사용하는 gem
        - Faker : 테스트용으로 seed파일을 이용하여 무작위 데이터 입력시 사용
        - fog-aws : Amazon S3를 지원하는 file uploader gem
        - mini_magick : file resizing등에 사용
        - carrierwave : file upload시 사용
        - figaro : credential하게 프로젝트를 관리할 수 있다.(application.yml 파일이 .gitignore에 추가됨)
    - seeds
    - JS and Stylesheete
        - `@import 'bootstrap';`으로 부트스트랩 import
        - `popper, bootstrap require`
    - app
        - uploader(carrierwave gem 필요)
            - uploader를 mount 시킨다
                > `mount_uploader :image_path, ImageUploader` : 해당 내용을 post.rb로 마운트시킨다.

            - 이미지를 업로드시에 리사이징(용량, 크기) 할 수 있다.
                > ubuntu환경 : `sudo apt-get update`를 한 다음 `sudo apt-get install imagemagick`
                
                > MacOS : 'brew install imagemagick'
                
                > uploader.rb에서 `include CarrierWave::MiniMagick`를 주석해제 하고, mini_magick gem을 설치한다.
                
                * resize_to_fill / resize_to_fit
                    - uploader파일에서 주석 처리되어 있는 부분을 해제 하고 사이즈를 지정한다.
                    - fill은 지정사이즈에 맞춰 resizing하고 남는 부분을 자른다.
                    - fit은 가로 세로 비율을 맞추어서 fitting해준다.
            - 특정 확장자만 가능하도록 지정할 수 있다.(`extension_whitelist`)
                - 다른 종류의 파일을 올리게 되면 transaction이 진행되지 않는다.
                - 이미지외에 다른 파일을 리사이징하게되면 문제가 될 수 있다.
                - 만약 다른 파일을 업로드 하고 싶은 경우에는 다른 colomn 및 Uploader(`rails g uploader 이름`으로 새로 생성)를 이용하여 mount해야 한다.
            - filename
                - upload시에 `model.id`가 아닌 original_filename으로 업로드할 수 있다.
    - config
        - initializer
            - fog.rb : <a href="https://github.com/carrierwaveuploader/carrierwave">fog</a>에 있는 fog부분을 copy paste한다.
                - *application.yml*에 amazon key, secret key를 지정하고 개발 단계에서만 사용(development:)
                - fog.rb에서 모든 key, endpoint등을 지정하고 uploader.rb에서 storage를 fog로 변경하면 된다.
                - 이에 따라, 이미지를 업로드 하면 이제 경로가 S3의 경로로 되며, 버킷을 살펴보면 변화가 있는 것을 알 수 있다.
* 전체
    - controller(application_controller) : 추가 필요
        - `helper_method` : 뷰에서 해당 메소드를 직접 사용할 수 있도록 지정할 수 있다.
            > user_signed_in? 과 current_user를 지정

        - user_signed_in? : 현재 로그인한 유저가 있는지 확인
            > `session[sign_in_user].present?` 로직으로 현재 로그인한 유저 여부 확인 및 `true | false`반환

        - authenticate_user : 유저가 로그인하지 않았다면 로그인 페이지로 이동시킨다.
            > cafe 개설, 수정, 가입시에 로그인 되어있는지 확인한다.
            
        - current_user : 로그인을 했다면 현재 유저의 정보를 가져온다.
            > `@current_user = User.find(session[:sign_in_user]) if user_signed_in?`
            
    - view(views/layouts, views/shared) : 추가 필요
* 카페
    - route : `resources`를 사용해 RESTful URL 설정.(destroy제와)
    - 관계
        - 한 명의 유저는 여러 카페를 가질 수 있고, 하나의 카페는 여러 유저를 회원으로 갖는다(유저와 M:N관계)
            > Membership으로 Join Table을 만들어 관계설정

        - 한 카페는 다수의 Post를 가질 수 있으며, 하나의 Post는 하나의 Cafe(daum)만 갖는다.(게시글과 1:N관계)
    - 모델(daum.rb)
        - db에는 카페의 title, description, 개설한 user의 name(master_name)을 저장한다.
    - 컨트롤러
        - 액션
            * before_action : 카페에 대한 정보 요청시, 카페 개설, 수정, 가입 등은 인증된 사용자만 가능하다.
                > `authenticate_user`로 확인
                
            * index : 카페의 전체 목록을 보여준다.(`@cafe`)에 저장
            * show : 특정 카페의 정보를 보여준다.(`@cafe`)에 저장, find함수 사용
                > 관계에서 한 카페는 다수의 Post를 가질 수 있다. 따라서, Post작성 시, 어떤 카페에서 작성되었는지 정보가 필요하다.
                
                > 카페의 id를 저장해서 hash로 알 필요가 있다. 이곳에서 `session[:current_cafe]`를 이용해 미리 아이디를 저장하고
                해당 내용을 전달하는 방식을 사용할 수 있다.
                
            * new : 새로운 카페를 개설할 때 사용한다.
                > `authenticate_user`로 인증된 유저인지 확인 후 개설해야 한다.
                
            * create : 실제로 카페를 개설하는 로직을 작성한다.(post방식)
                > `daum_paras`를 통해 `form_for`로 전달된 parameter를 확인하여 저장.
                
                > 카페 개설자의 id는 master_name으로 저장한다. 현재 유저는 session에 의해 application_controller에서 찾는 로직을 구성
                
                > 카페 개설에 성공했을 경우, Membership을 추가하고 redirect
                
                > 만약 실패했다면 실패 로그를 서버에 저장. `errors`메소드를 사용
            
            * edit : 카페 정보를 수정할 수 있는 페이지로 이동
                > id를 통해 해당 카페의 정보를 모델에서 찾아온다.
            
            * join_cafe : 카페에 실제로 가입하는 로직
                > 중복 가입을 막기 위해 Model코딩을 한다.(메소드를 추가하거나, Validation을 이용한다.) : ex)daum.rb의 `is_member`인스턴스 메소드
                
                > 예를 들어, 인스턴스 메소드 is_member를 추가하면 해당 메소드로 카페에 유저가 추가되어 있는지 확인할 수 있다.
                
                > 따라서, 메소드의 리턴값을 사용해 로직을 구성하여 가입 성공 실패를 결정한다.
                
                > 또는, join table인 Membership 모델에 `validate` keyword를 이용하여 제약을 추가할 수 있다.
                
            * daum_params(private) : model에서 쿼리하고 객체를 반환할 때 parameter를 전달하기 위한 메소드
                > `params.require(model_name).permit(parameters)`를 통해 모델에 지정된 parameter를 전달할 수 있다.
                
    - 뷰
        - index : 개설된 카페 리스트를 보여주며 새로운 카페를 개설할 수 있다.
        - new : `form_for`를 통해 새로 개설할 카페의 title, description을 지정한다.
        - show : 카페에 가입할 수 있으며, 카페의 정보가 보인다. 새 글을 작성할 수 있다.(기가입 여부에 따라 다른 로직)
            > 새 글을 작성시에는 카페의 id를 전달하여 어느 카페에서 전달했는지 확인할 수 있다.(혹은 세션을 사용)
            
* 유저
    - 관계
        - `has_secure_password`를 통해 password를 check할 수 있다.
        - 하나의 유저는 여러 카페를 가입할 수 있고, 카페는 여러 명의 유저를 회원으로 갖는다.
        - 따라서, join table인 membership을 통해 서로를 연결한다.(`has_many`, `through`)
    - 모델
        - 회원의 정보를 저장하는 id, password(*bcrypt gem*을 이용해 암호화)를 요구
    - 컨트롤러(authenticate_controller) : 회원가입, 로그인, 로그아웃 로직을 작성한다.
        - sign_up : 실제 회원가입을 할 수 있는 페이지로 이동
        - user_sign_up : *password*와 *password_confirmation*이 같은 경우에만 가능. *bcrypt* 버전에 따라 내용이 달라짐. 추가 필요
            > 성공한 경우 저장하고 페이지를 이동. 실패시 transaction오류를 확인하기 위해 서버에 로그를 저장한다.

        - sign_in : 로그인 페이지로 이동시킨다.
        - user_sign_in : 실제 로그인을 진행하는 로직을 구현한다.
            > id로 찾을 수 없으므로 `user_name`으로 find_by하여 객체를 찾는다. 찾으면 해당 유저의 존재여부, 비밀번호 일치 여부 확인(`authenticate`메소드)
            
            > 비밀번호까지 일치하는 경우, session에 hash를 추가하여 저장, 실패시 이동 및 서버로그를 찍는다.
            
        - sign_out : 로그아웃 로직을 작성한다.
            > 세션을 `delete`한다.
            
    - 뷰
        - authenticate/sign_in
            > 로그인에 필요한 아이디, 비밀번호를 입력받는다.
            
        - authenticate/sign_up
            > 회원가입에 필요한 아이디, 비밀번호, 비밀번호 확인을 입력받는 페이지
            
* 게시글(post)
    - 관계
        - 한 유저는 여러 포스트를 작성하며, 하나의 포스트는 한명의 유저에 의해 작성된다.(유저와 1:n 관계)
        - 한 카페는 여러 포스트를 가지며, 하나의 포스트는 하나의 카페에 종속된다.(카페와 1:n 관계)
        - 한 포스트는 여러 댓글을 가지며, 한 댓글은 하나의 포스트에 종속된다.(댓글과 1:n 관계)
    - 모델
        - 게시글 제목, content, 이미지 경로를 가지며, 관계에 의해 `user_id`, `daum_id`를 가진다.
        * ImageUploader : 이미지를 업로드하기 위해서 사용하는 uploader
    - 컨트롤러
        - index
        - show
        - new
        - create
        - edit
        - update
        - destroy
        - set_post(private)
        - post_params(private)
    - 뷰
        - _form
        - _post
        - edit
        - index
        - new
        - show
* 댓글(comment)
    - 모델
    - 컨트롤러
    - 뷰
