module ParolkarInnovationLab
  module SocialNet
    module PfeedUtils
      extend self
      def attempt_pass_tense str_obj
        #What can it do?
        # it can automagically transform
        # "addFriend" => "added_friend"
        # "fightWithFriend" => "faught_with_friend"
        # "buy_item" => "baught_item"
        #the magic trick "abhishekParolkar hu hu".underscore.parameterize.underscore.to_s
        str = str_obj.dup
        str = str.underscore.parameterize.underscore.to_s
        str_arr = str.split("_")
        str_arr[0] = str_arr[0].to_past_tense # this is from infectionist ( script/plugin install git://github.com/parolkar/inflectionist.git )
        str = str_arr.join("_")
      end  
    end
  end
end
    