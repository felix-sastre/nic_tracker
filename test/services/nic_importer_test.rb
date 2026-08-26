require "test_helper"

class NicImporterTest < ActiveSupport::TestCase
  test "claim succeeds for a date with no ImportedDate yet" do
    imported_date = NicImporter.claim(Date.new(2019, 5, 15))

    assert imported_date.persisted?
    assert_equal Date.new(2019, 5, 15), imported_date.registration_date
  end

  test "claim returns nil for a date that was already claimed" do
    NicImporter.claim(Date.new(2019, 5, 15))

    assert_nil NicImporter.claim(Date.new(2019, 5, 15))
  end
end
