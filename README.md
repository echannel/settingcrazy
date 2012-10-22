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

### Advanced Usage

TODO: Talk about setting groups

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
