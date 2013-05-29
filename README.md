# Settingcrazy

Similar to other settings gems, Settingcrazy allows you to set arbitrary settings to your ActiveRecord models.
It also allows you inherit settings from parent objects, save namespaced settings, and use setting templates to specify possible setting keys and values, validations, and default values.

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

Available settings are specified through the use of setting templates. These tell settingcrazy the options that exist, and the possible values they can take.

    class House < ActiveRecord::Base
      include SettingCrazy
      has_many :rooms
      use_setting_template Settings::House
    end

use_setting_template can also be passed a block, in case your model needs to use different templates, depending on the record itself.

    class Room < ActiveRecord::Base
      include SettingCrazy
      belongs_to :house
      settings_inherit_via :house

      # Use the template associated with the room type of this room
      use_setting_template do |record|
        record.room_type.template
      end
    end

#### Enums

The template itself is a collection of enums. Any attempt to get or set a setting that is not defined in a template will result in an ActiveRecord::UnknownAttributeError.
The basic structure of an enum is:

    enum :key, 'name', validation_options do
      value 'value', 'key'
      ...
    end

    class Settings::House < SettingCrazy::Template::Base
      enum :bedroom_count, 'Room Count', {} do
        value 1, 'One'
        value 2, 'Two'
        value 3, 'Three'
      end
    end

    house = House.create(...)
    house.settings.bedroom_count => nil
    house.settings.bedroom_count = 1
    house.save!

A setting template can inherit enums from another setting template by inheriting from that template. This is useful if you want the enums in one template to be a superset of the enums in another template. Enums can be added or overwritten by specifying them as normal.

	class Settings::Vehicle < SettingCrazy::Template::Base
		enum :passenger_capacity, 'Passenger Capacity', {} do
			value 1, 'One'
			value 2, 'Two'
			value 3, 'Three'
			value 4, 'Four'
			# ...
		end
	end

	class Settings::Car < Vehicle
		# New enums can be added
		enum :wheel_count, 'Wheel Count', {} do
			value 3, 'Three'
			value 4, 'Four'
		end
		
		# Existing Enums can be overwritten
		enum :passenger_capacity, 'Passenger Capacity', {} do
			value 2, 'Two'
			value 3, 'Three'
			value 4, 'Four'
			value 5, 'Five'
		end
	end
	

#### Validation

Settings validation will only occur for a model that is using a template, or a namespaced template. When validating, Settingcrazy will always validate whether the value set for an option has been defined as a possible value for that option. As well as this automatic validation, there are a number of additional validation options that can be specified per enumeration.

    # multiple (boolean) - Whether it is valid to save more than one entry for a single key
    # dependent ({ enum_key: setting_value }) - A value may only be set for this option if all of the options it is dependent on are set to the specified values
    # required (boolean) - Whether a value must be set for this enum
    # required_if ({ enum_key: setting_value }) - A value must be set for this option if all of the options it is dependent on are set to the specified values
    # type (string) - Only current available value is 'text'. This causes settingcrazy to skip the range validation, so any value for this option will be valid.
    # greater_than|greater_than_or_equal_to|less_than|less_than_or_equal_to|equal_to|not_equal_to ({ value: number } | { attribute: :attribute_name } | { attribute: :attribute_name, association: :association_name })

Due to the ability to namespace settings (discussed later), the validation errors for each object are placed in the hash, setting_errors, for each model. If validation of settings fails, the object will still be flagged as invalid, but the details will need to be retrieved from setting_errors. To allow multiple templates to contain settings of the same name, validation errors for settings will be listed under the setting template's class name of the invalid setting(s).

    class Settings::House < SettingCrazy::Template::Base
      enum :is_furnished, 'Furnished', { multiple: false, required: true } do
        value false, 'Not Furnished'
        value true, 'Is Furnished'
      end

      enum :has_dining_table, 'Has Dining Table', { dependent: { is_furnished: true } } do
        value false, 'No Dining Table'
        value true, 'Dining Table'
      end
    end

    house = House.create(...)
    house.valid? => false
    house.errors => { :base => ["Settings are invalid"] }
    house.setting_errors => { 'Settings::House' => { :is_furnished => ["Setting, 'Furnished', is required"] } }
    house.settings.is_furnished = false
    house.valid? => true
    house.settings.has_dining_table = false
    house.valid? => false ("'Has Dining Table' can only be specified if 'Furnished' is set to 'Not Furnished'")
    house.settings.is_furnished = true
    house.valid? => true
    house.settings.has_dining_table = 3
    house.valid? => false ("'3' is not a valid setting for 'Has Dining Table'")


##### Defaults

Defaults enable both the ability to ensure the user starts with a valid object, and  that the most common values are set on creation. To define defaults, create a class method in your template that returns a hash of default settings.

    class Settings::House < SettingCrazy::Template::Base
      # Assuming the enums for all these settings are defined below
      def self.defaults
        {
          bedroom_count: 2,
          is_furnished: false
        }
      end
    end

    house = House.create(...)
    house.settings => {}
    house.settings.bedroom_count => 2
    house.settings.bedroom_count = 3
    house.settings => { :bedroom_count => 3 }
    house.is_furnished => false
    house.has_dining_table => nil

##### Numerical Validation
As shown above, a number of mathematical operators are available for numerical validation. These allow comparison with a static value, as well as with other settings of the current instance, and finally with settings of associated instance.

    class Settings::House < SettingCrazy::Template::Base
      enum :window_count, 'Number of Windows', { type: 'text', greater_than: { value: 0 } } do
        value '', 'Number of Windows text value'
      end
    end

    class Settings::Room < SettingCrazy::Template::Base
      enum :window_count, 'Number of Windows', { type: 'text', less_than_or_equal_to: { association: :house, attribute: :window_count } } do
        value '', 'Number of Windows text value'
      end
    end

    house = House.create(...)
    room = house.rooms.create(...)
    house.settings.window_count => 0
    house.valid? => false
    house.setting_errors => {'Settings::House' => { :window_count => ["Setting, 'Number of Windows' must be greater than 0" ] } }
    house.settings.window_count = 2
    room.settings.window_count = 3
    room.valid? => false
    room.setting_errors => {'Settings::Room' => { :window_count => ["Setting, 'Number of Windows' must be less than or equal to the 'Number of Windows' of its House."] }}

When validating against an association whose settings are namespaced, the current instance must inherit these settings from the association, with the namespace passed to the 'settings_inherit_via' method.

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

You can also set templates to work per namespace:

    setting_namespace :weekdays, :template => WeekDayTemplate

When inheriting via a parent with namespaces you may like to specify a namespace to inherit from instead of just the settings as a whole.

    settings_inherit_via :house, :namespace => :a_namespace

Or, you can even use a proc

    settings_inherit_via :house, :namespace => Proc.new { |room| room.parent_setting_namespace }

## Ignoring a Namespace

In some cases, if you have validations on a namespace but that namespace is not needed your validations will always fail. You can get around this by defining a method on your model called `available_setting_namespaces`. The method should simply return an array of strings or symbols of the namespaces you want to apply in this case. This is useful if a particular instance of you model only needs settings from one or some namespaces.

    class User < ActiveRecord::Base
      include SettingCrazy

      setting_namespace :user, :template => UserSettings
      setting_namespace :admin, :template => AdminSettings

      def available_setting_namespaces
        if admin?
          %w(user admin)
        else
          %(user)
        end
      end
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
