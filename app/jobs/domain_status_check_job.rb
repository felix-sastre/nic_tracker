class DomainStatusCheckJob < ApplicationJob
  queue_as :default

  def perform(domain_id)
    domain = Domain.find_by(id: domain_id)
    return unless domain

    DomainStatusChecker.new(domain).call
  end
end
