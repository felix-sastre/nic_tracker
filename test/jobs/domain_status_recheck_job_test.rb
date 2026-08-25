require "test_helper"

class DomainStatusRecheckJobTest < ActiveJob::TestCase
  test "rechecks domain statuses older than the staleness threshold" do
    stale_status = domain_statuses(:one)

    assert_changes -> { stale_status.reload.checked_at } do
      DomainStatusRecheckJob.perform_now
    end
  end

  test "leaves recently checked domain statuses untouched" do
    fresh_status = domain_statuses(:two)
    fresh_status.update!(checked_at: 5.minutes.ago)

    assert_no_changes -> { fresh_status.reload.checked_at } do
      DomainStatusRecheckJob.perform_now
    end
  end
end
