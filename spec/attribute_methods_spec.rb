require 'spec_helper'

describe SettingCrazy::AttributeMethods do
  describe 'define_attr_method' do
    context 'when no block is passed' do
      it 'should raise an ArgumentError' do
        expect { SettingCrazy::Template::Base.define_attr_method(:foo) }.to raise_error(ArgumentError, 'Block Required')
      end
    end

    context 'when a block is passed' do
      it 'calls define_method on the singleton_class' do
        blk = lambda { |arg| foo = 'foo' }
        SettingCrazy::Template::Base.singleton_class.expects(:define_method).with(:foo, &blk)
        SettingCrazy::Template::Base.define_attr_method(:foo, &blk)
      end
    end
  end
end
