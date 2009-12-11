require 'test_helper'

load_schema

def pfeed
  PfeedItem.find_by_originator_id(topic.id)
end

class Emitter < ActiveRecord::Base
  def if_false_ping; end
  def if_false; false end
  def if_true_ping; end
  def if_true; true end

  def unless_false_ping; end
  def unless_false; false end
  def unless_true_ping; end
  def unless_true; true end
end

context 'an emitter not satisfying an if or unless condition' do
  setup do
    Emitter.class_eval do
      emits_pfeeds :on => :if_false_ping, :if => :if_false
      emits_pfeeds :on => :unless_true_ping, :unless => :unless_true
    end
    Emitter.new.if_false_ping
    Emitter.new.unless_true_ping
  end
  should("not create a pfeed item") { PfeedItem.all.empty? }
end

context 'an emitter satisfying an if condition' do
  setup do
    Emitter.class_eval do
      emits_pfeeds :on => :if_true_ping, :if => :if_true
    end
    returning(Emitter.create!(:name => 'bob')) do |e|
      e.if_true_ping
    end
  end
  should("create a pfeed item") { !PfeedItem.all.empty? }
  should("guess the name") { pfeed.data[:originator_identity] }.equals('bob')
end

context 'an emitter satisfying an unless condition' do
  setup do
    Emitter.class_eval do
      emits_pfeeds :on => :unless_false_ping, :unless => :unless_false
    end
    e = Emitter.create!
    e.unless_false_ping
  end
  should("create a pfeed item") { !PfeedItem.all.empty? }
end
