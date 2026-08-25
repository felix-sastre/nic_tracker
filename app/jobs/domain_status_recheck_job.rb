class DomainStatusRecheckJob < ApplicationJob
  queue_as :default

  STALE_AFTER = 1.hour

  def perform
    Domain.joins(:domain_status)
          .where(domain_statuses: { checked_at: ...STALE_AFTER.ago })
          .find_each { |domain| DomainStatusChecker.new(domain).recheck }
  end
end
