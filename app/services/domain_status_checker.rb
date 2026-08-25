require "resolv"

class DomainStatusChecker
  def initialize(domain)
    @domain = domain
  end

  def call
    return @domain.domain_status if @domain.domain_status

    recheck
  end

  def recheck
    status = @domain.domain_status || @domain.build_domain_status
    status.update!(is_online: online?, checked_at: Time.current)
    status
  end

  private

  def online?
    Resolv.getaddress("#{@domain.name}.#{@domain.zone}")
    true
  rescue Resolv::ResolvError
    false
  end
end
