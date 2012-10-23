# Settingcrazy

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'settingcrazy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install settingcrazy

Finally, create a migration and run:

    $ rails g settingcrazy:setting_values_migration
    $ rake db:migrate

## Usage

To use simply include the SettingCrazy module in any ActiveRecord model that you want to have settings:

    class User < ActiveRecord::Base
      include SettingCrazy
    end

Your model will now have a settings method which you can use to get and set values.

    user = User.first
    user.settings => {}
    user.settings.my_setting = "foo"
    user.settings.my_setting => "foo"
    user.settings => { "my_setting" => "foo" }

To persist, call save or save! on the parent. Eg;

    user.save

### Serializable Values

TODO

### Setting Inheritance

Your settings can inherit from the settings of a parent.

    class House < ActiveRecord::Base
      include SettingCrazy
      has_many :rooms
    end

    class Room < ActiveRecord::Base
      include SettingCrazy
      belongs_to :house
      settings_inherit_via :house
    end

    house = House.create(...)
    house.settings.color = "blue"
    house.save!

    room = house.rooms.create
    room.settings.color => "blue"

### Setting Templates

TODO

### Mass Assignment and Usage in Forms

You can easily bulk set settings using a hash.

    house.settings = { :foo => "bar", :fruit => "apple" }

This extends to mass assignment:

    house.attributes = {
      :settings => { :foo => "bar", :fruit => "apple" }
    }

If using in a form you can use fields for (eg in Haml):

    = form.fields_for :settings, @house.settings do |setting|
      = setting.text_field :foo

### Setting Namespaces

If you have a model that needs settings to be divided in some way (perhaps by functional area) you can use a namespace.

    class Scenario < ActiveRecord::Base
      include SettingCrazy

      setting_namespace :weekdays
      setting_namespace :weekends
    end

Now you can access your settings like so:

    scenario = Scenario.find(...)
    scenario.settings.weekends.foo = "bar"
    scenario.settings.weekends.foo => "bar"
    scenario.settings.weekdays.foo => nil

    scenario.settings.weekends => { :foo => "bar" }

Not providing a namespace still works and will access all settings:

    scenario.settings.foo => "bar"

Setting namespaces work with bulk setting and mass assignment too:

    scenario.settings.weekends = { :foo => "bar" }

    scenario.attributes = {
      :settings => {
        :weekends => {
          :foo => "bar
        },
      },
    }

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
