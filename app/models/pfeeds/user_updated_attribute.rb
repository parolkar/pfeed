class Pfeeds::UserUpdatedAttribute < PfeedItem
  
  def pack_data(method_name,method_name_in_past_tense,returned_result,*args_supplied_to_method,&block_supplied_to_method) 
     super
     self.data = {} if ! self.data
     attribute_name = args_supplied_to_method[0].to_s.humanize
     hash_to_be_merged = {:attribute_name => attribute_name}

     self.data.merge!  hash_to_be_merged
   end
 
end

