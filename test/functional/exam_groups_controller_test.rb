require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ExamGroupsControllerTest < ActionController::TestCase
  fixtures :users

  context 'with admin logged in' do
    setup do
      @controller = ExamGroupsController.new
      @request = ActionController::TestRequest.new
      @response = ActionController::TestResponse.new
      @request.session[:user_id] = 1

      Factory.create(:course, :id => 1)
      Factory.create(:batch,  :course_id => 1)
    end

    should 'render index' do
      get :index, {:batch_id => 1}
      assert_response :success
      assert_template :index
    end

    should 'render new' do
      get :new, {:batch_id => 1}
      assert_response :success
      assert_template :new
    end

    should 'render new template if wrong parameters are given in new form' do
      post :create, {:batch_id => 1}
      assert_template :new
    end

    should 'redirect to index if correct parameters are give in new form' do
      post :create, {
        :exam_group => Factory.attributes_for(:exam_group),
        :batch_id => 1
      }
      assert_redirected_to :action => 'index'
    end

  end
end
