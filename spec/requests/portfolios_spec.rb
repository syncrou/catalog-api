include RequestSpecHelper
describe 'Portfolios API' do

  let!(:portfolio)            { create(:portfolio) }
  let!(:portfolio_item)       { create(:portfolio_item) }
  let!(:portfolio_items)      { create_list(:portfolio_item, 3, portfolios: [portfolio]) }
  let(:portfolio_id)          { portfolio.id }
  let(:portfolio_item_id)     { portfolio_items.first.id }
  let(:new_portfolio_item_id) { portfolio_item.id }

  # Encoded Header: { 'identity' => { 'is_org_admin':false, 'org_id':111 } }
  let(:user_encode_key_with_tenant)  { { 'x-rh-auth-identity': 'eyJpZGVudGl0eSI6eyJpc19vcmdfYWRtaW4iOmZhbHNlLCJvcmdfaWQiOiIxMTEifX0=' } }
  # Encoded Header: { 'identity' => { 'is_org_admin':true, 'org_id':111 } }
  let(:admin_encode_key_with_tenant) { { 'x-rh-auth-identity': 'eyJpZGVudGl0eSI6eyJpc19vcmdfYWRtaW4iOnRydWUsIm9yZ19pZCI6MTExfX0=' } }

  %w(admin user).each do |tag|
    describe "GET #{tag} tagged #{api_version}/portfolios/:portfolio_id" do
      before do
        get "#{api_version}/portfolios/#{portfolio_id}", headers: send("#{tag}_encode_key_with_tenant")
      end

      context 'when portfolios exist' do
        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

         it 'returns all portfolio requests' do
          expect(json).not_to be_empty
          expect(json['id']).to eq(portfolio_id)
        end
      end
    end

    describe "GET #{tag} tagged #{api_version}/portfolios/:portfolio_id/portfolio_items" do
      before do
        get "#{api_version}/portfolios/#{portfolio_id}/portfolio_items", headers: send("#{tag}_encode_key_with_tenant")
      end

      it 'returns all associated portfolio_items' do
        expect(json).not_to be_empty
        expect(json.count).to eq 3
        portfolio_item_ids = portfolio_items.map(&:id).sort
        expect(json.map { |x| x['id'] }.sort).to eq portfolio_item_ids
      end
    end

    describe "GET #{tag} tagged #{api_version}/portfolios/:portfolio_id/portfolio_items/:portfolio_item_id" do
      before do
        get "#{api_version}/portfolios/#{portfolio_id}/portfolio_items/#{portfolio_item_id}", headers: send("#{tag}_encode_key_with_tenant")
      end

      it 'returns an associated portfolio_item for a specific portfolio' do
        expect(json).not_to be_empty
        expect(json['id']).to eq portfolio_item_id
      end
    end

    describe "GET #{tag} tagged #{api_version}/portfolios" do
      before do
        get "#{api_version}/portfolios", headers: send("#{tag}_encode_key_with_tenant")
      end

      context 'when portfolios exist' do
        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

         it 'returns all portfolio requests' do
          expect(json.size).to eq(1)
        end
      end
    end
  end

  describe "admin tagged #{api_version}/portfolios", :type => :routing  do
    let(:valid_attributes) { { name: 'rspec 1', description: 'rspec 1 description' } }
    context 'with wrong header' do
      it 'returns a 404' do
        expect(:post => "#{api_version}/portfolios").not_to be_routable
      end
    end
  end

  describe "POST admin tagged #{api_version}/portfolios/:portfolio_id/portfolio_items" do
    let(:valid_attributes) { { :portfolio_item_id => portfolio_item.id, :portfolio_id => portfolio.id } }
    before do
      post "#{api_version}/portfolios/#{portfolio_id}/portfolio_items/", params: valid_attributes, headers: admin_encode_key_with_tenant
    end
    context 'when portfolio and portfolio_item attributes are valid' do
      it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      it 'returns an associated portfolio_item for a specific portfolio' do
        expect(json).not_to be_empty
        expect(json).to be_a Array
        expect(json.first['id']).to eq new_portfolio_item_id
      end
    end
  end

  describe "POST admin tagged #{api_version}/portfolios" do
    let(:valid_attributes) { { name: 'rspec 1', description: 'rspec 1 description' } }
    context 'when portfolio attributes are valid' do
      before { post "/#{api_version}/portfolios", params: valid_attributes, headers: admin_encode_key_with_tenant }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the new portfolio' do
        expect(json['name']).to eq valid_attributes[:name]
      end
    end
  end
end

