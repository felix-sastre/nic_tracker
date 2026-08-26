class StatsController < ApplicationController
  def index
    totals = Domain.group(:registration_date).count
    online_counts = Domain.joins(:domain_status).merge(DomainStatus.where(is_online: true)).group(:registration_date).count
    offline_counts = Domain.joins(:domain_status).merge(DomainStatus.where(is_online: false)).group(:registration_date).count

    @stats = totals.keys.sort.reverse.map do |date|
      total = totals[date]
      online = online_counts[date] || 0
      offline = offline_counts[date] || 0

      {
        registration_date: date,
        total: total,
        online: online,
        offline: offline,
        pending: total - online - offline
      }
    end
  end
end
