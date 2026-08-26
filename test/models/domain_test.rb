require "test_helper"

class DomainTest < ActiveSupport::TestCase
  test "is invalid without a name" do
    domain = Domain.new(zone: "com.ar", registration_date: Date.today, nic_id: "x1")
    assert_not domain.valid?
  end

  test "is invalid without a zone" do
    domain = Domain.new(name: "example", registration_date: Date.today, nic_id: "x2")
    assert_not domain.valid?
  end

  test "is invalid without a registration_date" do
    domain = Domain.new(name: "example", zone: "com.ar", nic_id: "x3")
    assert_not domain.valid?
  end

  test "is invalid without a nic_id" do
    domain = Domain.new(name: "example", zone: "com.ar", registration_date: Date.today)
    assert_not domain.valid?
  end

  test "is invalid with a duplicate nic_id" do
    Domain.create!(name: "first", zone: "com.ar", registration_date: Date.today, nic_id: "dup-1")
    duplicate = Domain.new(name: "second", zone: "com.ar", registration_date: Date.today, nic_id: "dup-1")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:nic_id], "ya está en uso"
  end

  test "is valid with a unique nic_id" do
    domain = Domain.new(name: "example", zone: "com.ar", registration_date: Date.today, nic_id: "unique-1")
    assert domain.valid?
  end
end
