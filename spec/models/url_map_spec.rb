require 'spec_helper'

describe UrlMap do

  let(:repository) { FactoryGirl.create :repository }
  let(:url_map)    { FactoryGirl.create :url_map, repository: repository }

  subject { url_map }

  describe 'Migrations' do
    %w( source target ).each do |column|
      it { have_db_column(column).of_type(:string) }
    end

    it {  have_db_index([:repository_id, :source]).unique(true) }
  end

  describe 'Associations' do
    it { belong_to :repository }
  end

  describe 'UrlMapInstance' do
    describe 'responsiveness' do
      [:source, :target, :repository].each do |field|
        it { should respond_to(field) }
      end
    end

    describe 'validations' do
      it { should be_valid }

      describe 'source empty' do
        subject do
          source = ""
        end
        it do
          url_map.source = ""
          url_map.valid?
          url_map.errors[:source].should == ["can't be blank"]
        end
      end

      describe 'target empty' do
        it do
          url_map.target = ""
          url_map.valid?
          url_map.errors[:target].should == ["can't be blank"]
        end
      end

      describe 'source not unique' do
        it do
          url_map2 = url_map.dup
          url_map2.errors.should_not be_nil
        end
      end
    end
  end

end
