require 'test_helper'

load_schema

class Emitter < ActiveRecord::Base
  def if_false_ping; end
  def if_false; false end
  def if_true_ping; end
  def if_true; true end
end

context 'an emitter not satisfying and if condition' do
  setup do
    Emitter.class_eval do
      emits_pfeeds :on => :if_false_ping, :if => :if_false
    end
    Emitter.new.if_false_ping
  end
  should("not create a pfeed item") {PfeedItem.all.empty?}
end

context 'an emitter not satisfying and if condition' do
  setup do
    Emitter.class_eval do
      emits_pfeeds :on => :if_true_ping, :if => :if_true
    end
#    Emitter.create!.if_true_ping
  end
  should("not create a pfeed item") {!PfeedItem.all.empty?}
end
