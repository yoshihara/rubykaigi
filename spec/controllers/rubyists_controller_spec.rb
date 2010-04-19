require 'spec_helper'

describe RubyistsController do
  describe 'GET /show' do
    before do
      @ursm = Rubyist.make(:name => 'ursm')
      get :show, :id => 'ursm'
    end

    it { response.should be_success }
    it { assigns[:rubyist].should == @ursm }
  end

  describe 'GET /new' do
    context 'with Twitter credentials' do
      before do
        session[:credentials] = {:twitter_user_id => 4567}
        get :new
      end

      it { response.should be_success }
    end

    context 'with OpenID credentials' do
      before do
        session[:credentials] = {:identity_url => 'http://ursm.jp/'}
        get :new
      end

      it { response.should be_success }
    end

    context 'no credentials' do
      before do
        get :new
      end

      it { response.should redirect_to(new_sessions_path) }
    end
  end

  describe 'POST /create' do
    context 'with Twitter credentials' do
      before do
        session[:credentials] = {:twitter_user_id => 4567}
      end

      context 'saved' do
        before do
          mock.instance_of(Rubyist).save { true }
          mock(controller).user = is_a(Rubyist)

          post :create, :rubyist => {:name => 'ursm'}
        end

        it { response.should redirect_to(root_path) }
        it { assigns[:rubyist].twitter_user_id.should == 4567 }
        it { session[:credentials].should be_nil }
      end

      context 'failed' do
        before do
          mock.instance_of(Rubyist).save { false }
          dont_allow(controller).user = anything

          post :create, :rubyist => {:name => 'ursm'}
        end

        it { response.should be_success }
        it { response.should render_template(:new) }
        it { session[:credentials][:twitter_user_id].should == 4567 }
      end
    end

    context 'with OpenID credentials' do
      before do
        session[:credentials] = {:identity_url => 'http://ursm.jp/'}
      end

      context 'saved' do
        before do
          mock.instance_of(Rubyist).save { true }
          mock(controller).user = is_a(Rubyist)

          post :create, :rubyist => {:name => 'ursm'}
        end

        it { response.should redirect_to(root_path) }
        it { assigns[:rubyist].identity_url.should == 'http://ursm.jp/' }
        it { session[:credentials].should be_nil }
      end

      context 'failed' do
        before do
          mock.instance_of(Rubyist).save { false }
          dont_allow(controller).user = anything

          post :create, :rubyist => {:name => 'ursm'}
        end

        it { response.should be_success }
        it { response.should render_template(:new) }
        it { session[:credentials][:identity_url].should == 'http://ursm.jp/' }
      end
    end

    context 'no credentials' do
      before do
        post :create, :rubyist => {:name => 'ursm'}
      end

      it { response.should redirect_to(new_sessions_path) }
    end
  end
end
