# Author: Er Abhishek Parolkar

require File.dirname(__FILE__) + '/lib/pfeed'
require File.dirname(__FILE__) + '/lib/pfeed_utils'
ActiveRecord::Base.send(:include, ParolkarInnovationLab::SocialNet)

ActionController::Base.helper do
  def pfeed_content(pfeed)  #FIXME: interesting idea , but currently un-supported
    controller.send('render_to_string',
      :partial => "pfeeds/#{pfeed.view_template_name}.html.erb", :locals => {:object => pfeed})
  end

  def pfeed_item_url(pfeed_item)
    # same as: polymorphic_url pfeed_item.originator
    # but no need to query the database
    send(pfeed_item.originator_type.underscore + '_url', pfeed_item.originator_id)
  end
end
