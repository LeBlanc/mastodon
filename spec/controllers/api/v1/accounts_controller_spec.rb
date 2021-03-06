require 'rails_helper'

RSpec.describe Api::V1::AccountsController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { double acceptable?: true, resource_owner_id: user.id }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { id: user.account.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #verify_credentials' do
    it 'returns http success' do
      get :verify_credentials
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #statuses' do
    it 'returns http success' do
      get :statuses, params: { id: user.account.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #followers' do
    it 'returns http success' do
      get :followers, params: { id: user.account.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #following' do
    it 'returns http success' do
      get :following, params: { id: user.account.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #follow' do
    let(:other_account) { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob')).account }

    before do
      post :follow, params: { id: other_account.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'creates a following relation between user and target user' do
      expect(user.account.following?(other_account)).to be true
    end
  end

  describe 'POST #unfollow' do
    let(:other_account) { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob')).account }

    before do
      user.account.follow!(other_account)
      post :unfollow, params: { id: other_account.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'removes the following relation between user and target user' do
      expect(user.account.following?(other_account)).to be false
    end
  end

  describe 'POST #block' do
    let(:other_account) { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob')).account }

    before do
      user.account.follow!(other_account)
      post :block, params: { id: other_account.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'removes the following relation between user and target user' do
      expect(user.account.following?(other_account)).to be false
    end

    it 'creates a blocking relation' do
      expect(user.account.blocking?(other_account)).to be true
    end
  end

  describe 'POST #unblock' do
    let(:other_account) { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob')).account }

    before do
      user.account.block!(other_account)
      post :unblock, params: { id: other_account.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'removes the blocking relation between user and target user' do
      expect(user.account.blocking?(other_account)).to be false
    end
  end

  describe 'GET #relationships' do
    let(:simon) { Fabricate(:user, email: 'simon@example.com', account: Fabricate(:account, username: 'simon')).account }
    let(:lewis) { Fabricate(:user, email: 'lewis@example.com', account: Fabricate(:account, username: 'lewis')).account }

    before do
      user.account.follow!(simon)
      lewis.follow!(user.account)
    end

    context 'provided only one ID' do
      before do
        get :relationships, params: { id: simon.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns JSON with correct data' do
        json = body_as_json

        expect(json).to be_a Enumerable
        expect(json.first[:following]).to be true
        expect(json.first[:followed_by]).to be false
      end
    end

    context 'provided multiple IDs' do
      before do
        get :relationships, params: { id: [simon.id, lewis.id] }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      xit 'returns JSON with correct data' do
        # todo
      end
    end
  end
end
