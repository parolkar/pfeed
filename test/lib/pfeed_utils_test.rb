require 'test_helper'

context 'attempting past tense' do
  def _(verb, past_tense)
    asserts('') {ParolkarInnovationLab::SocialNet::PfeedUtils.attempt_pass_tense(verb)}.equals(past_tense)
  end

  _ "addFriend", "added_friend"
  _ "fightWithFriend", "fought_with_friend"
  _ "buy_item", "bought_item"
end
