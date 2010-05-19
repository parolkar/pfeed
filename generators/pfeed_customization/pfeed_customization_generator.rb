class PfeedCustomizationGenerator < Rails::Generator::Base
  attr_reader :past_classname
  attr_reader :past_varname

  def initialize(args, other = {})
    super
    @model, @current_action = args
    @past_action = ParolkarInnovationLab::SocialNet::PfeedUtils.attempt_pass_tense(@current_action)
    @past = @model.downcase + '_' + @past_action
    @past_classname = @model.capitalize + @past_action.capitalize
    @past_varname = @model.downcase + '_' + @past_action.downcase
    @model_filename =  @past + '.rb'
    @view_filename = '_' + @past + '.html.erb'
  end


  def manifest
    record do |m|
      m.directory('app/models/pfeeds')
      m.directory('app/views/pfeeds')
      m.template('pfeed_model.rb', "app/models/pfeeds/#{@model_filename}")
      m.template('pfeed_view.html.erb', "app/views/pfeeds/#{@view_filename}")
    end
  end

end
