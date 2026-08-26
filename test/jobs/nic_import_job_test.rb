require "test_helper"

class NicImportJobTest < ActiveJob::TestCase
  test "delegates to NicImporter.import_if_needed" do
    input_date = "15-05-2019"
    db_date = Date.new(2019, 5, 15)
    received_args = nil

    stub_import_if_needed(->(*args) { received_args = args }) do
      NicImportJob.perform_now(input_date, db_date)
    end

    assert_equal [ input_date, db_date ], received_args
  end

  test "logs and swallows FetchError instead of raising" do
    stub_import_if_needed(->(*) { raise NicImporter::FetchError, "boom" }) do
      assert_nothing_raised do
        NicImportJob.perform_now("15-05-2019", Date.new(2019, 5, 15))
      end
    end
  end

  private

  def stub_import_if_needed(implementation)
    original = NicImporter.method(:import_if_needed)
    NicImporter.define_singleton_method(:import_if_needed) { |*args| implementation.call(*args) }
    yield
  ensure
    NicImporter.define_singleton_method(:import_if_needed, original)
  end
end
