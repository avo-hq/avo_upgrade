# frozen_string_literal: true

require 'test_helper'

class AvoUpgrade::UpgradeToolTest < ActiveSupport::TestCase
  test 'remove_block_arg_on removes lambda args without removing args within the lambda' do
    field_def = 'field :foobar, format_using: ->(value) { view_context.number_to_currency(value) }'
    test_file = Tempfile.new('test_file')
    test_file.write field_def
    files = [test_file.path]
    test_file.close
    replace_array = ['(value)']
    # expected_field_def = 'field :foobar, format_using: -> { view_context.number_to_currency(value) }'

    AvoUpgrade::UpgradeTool.new.remove_block_arg_on(files, replace_array)
    puts "clean"
    updated_file_contents = File.read(test_file.path)
    puts updated_file_contents
    assert updated_file_contents == 'field :foobar, format_using: -> { view_context.number_to_currency(value) }'

    test_file.unlink
  end
end
