require 'rails_helper'
require 'spec_helper'

RSpec.describe Space, type: :model do
  describe '#create' do
    let (:user) { FactoryGirl.create(:user) }
    subject (:space) { FactoryGirl.build(:space, user: user, is_private: is_private) }

    context 'public' do
      let (:is_private) { false }
      it { is_expected.to be_valid }
    end

    context 'private' do
      let (:is_private) { true }

      context 'with user on free plan' do
        it { is_expected.not_to be_valid }
      end

      context 'with user on small plan' do
        let (:user) { FactoryGirl.create(:user, :small_plan) }
        it { is_expected.to be_valid }
      end
    end
  end

  describe '#searchable' do
    subject(:space) { FactoryGirl.build(:space, name: name, is_private: is_private, graph: graph) }
    let(:graph) {nil}
    let(:is_private) { false }

    context 'with valid name' do
      let(:name) {'real model'}
      it 'should have a real name' do
        expect(space.has_real_name?).to be true
      end

      it 'should not be searchable with no graph' do
        expect(space.is_searchable?).to be false
      end

      context 'searchable graph' do
        let(:graph) {
          {'metrics'=>
            [{'name'=>'Point Test'},
             {'name'=>'Uniform Test'},
             {'name'=>'Normal Test'},
             {'name'=>'Function Test'}],
           'guesstimates'=>
            [{'guesstimateType'=>'POINT'},
             {'guesstimateType'=>'UNIFORM'},
             {'guesstimateType'=>'NORMAL'},
             {'guesstimateType'=>'FUNCTION'}]}
        }
        it 'should be searchable with a valid graph' do
          expect(space.is_searchable?).to be true
        end
      end
    end

    context 'private space' do
      let(:is_private) { true }
      let(:name) {'real model'}

      it 'should not be searchable' do
        expect(space.is_searchable?).to be false
      end
    end
  end
end