module SettingCrazy
  class SettingValue < ActiveRecord::Base
    attr_accessible :key, :value
    belongs_to :settable, :polymorphic => true
  end
end
