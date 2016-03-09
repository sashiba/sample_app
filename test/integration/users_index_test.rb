require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
  end

 # test "index including pagination" do
 #   log_in_as(@user)
 #   get users_path
 #   assert_template 'users/index'
 #   assert_select 'div.pagination'
 #   User.paginate(page: 1).each do |user|
 #     assert_select 'a[href=?]', user_path(user), text: user.name
 #   end
 # end
  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end

  test "index has only activated users" do
    log_in_as(@non_admin)
    get users_path
    assert_template 'users/index'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_equal true, user.activated?
    end
  end

  test "show/id should not redirect if user is activated" do
    log_in_as(@non_admin)
    get user_path(@non_admin)
    assert_template 'users/show'
  end

  test "show should redirect if not activated" do
    log_in_as(@non_admin)
    @non_admin.toggle!(:activated)
    get user_path(@non_admin)
    assert_redirected_to root_url
  end
end
