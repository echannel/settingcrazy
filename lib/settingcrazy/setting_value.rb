module SettingCrazy
  class SettingValue < ActiveRecord::Base
    attr_accessible :key, :value, :namespace
    serialize :value
    belongs_to :settable, :polymorphic => true

    def self.namespace(namespace)
      where(:namespace => namespace)
    end
  end
end
