require "resolv"

class DomainStatusChecker
  def initialize(domain)
    @domain = domain
  end

  def call
    return @domain.domain_status if @domain.domain_status

    DomainStatus.create!(
      domain: @domain,
      is_online: online?,
      checked_at: Time.current
    )
  end

  private

  def online?
    Resolv.getaddress("#{@domain.name}.#{@domain.zone}")
    true
  rescue Resolv::ResolvError
    false
  end
end
