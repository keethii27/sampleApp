require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    # usersはfixtureのファイル名users.ymlを表し、
    # :michaelというシンボルはユーザーを参照するためのキーを表す
    @user = users(:michael)
  end

  test "login with invalid information" do
    # ログイン用のパスを開く
    get login_path
    # 新しいセッションのフォームが正しく表示されたことを確認する
    assert_template 'sessions/new'
    # わざと無効なparamsハッシュを使ってセッション用パスにPOSTする
    post login_path, params: {session: {email: "", password: ""}}
    # 新しいセッションのフォームが再度表示され、フラッシュメッセージが追加されることを確認する
    assert_template 'sessions/new'
    assert_not flash.empty?
    # 別のページ (Homeページなど) にいったん移動する
    get root_path
    # 移動先のページでフラッシュメッセージが表示されていないことを確認する
    assert flash.empty?
  end

  test "login with valid infomation followed by logout" do
    get login_path
    post login_path, params: {session: { email: @user.email, password: 'password'}}
    assert is_logged_in?
    # リダイレクト先が正しいかどうかをチェック
    assert_redirected_to @user
    # そのページに実際に移動
    follow_redirect!
    assert_template 'users/show'
    # ログインパスのリンクがページにないかどうかで判定
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    # deleteメソッドでDELETEリクエストをログアウト用パスに発行
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count:0
    assert_select "a[href=?]", user_path(@user), count:0
  end

end
