require "test_helper"

class DomainStatusCheckJobTest < ActiveJob::TestCase
  test "creates a DomainStatus for a domain that doesn't have one yet" do
    domain = Domain.create!(
      name: "never-checked",
      zone: "com.ar",
      registration_date: Date.new(2026, 7, 3),
      nic_id: "job-test-1",
      transaction_type: "alta"
    )

    assert_nil domain.domain_status

    DomainStatusCheckJob.perform_now(domain.id)

    assert_not_nil domain.reload.domain_status
  end

  test "does nothing if the domain no longer exists" do
    assert_nothing_raised do
      DomainStatusCheckJob.perform_now(-1)
    end
  end
end
