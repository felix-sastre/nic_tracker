require "test_helper"

class DomainsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @domain = domains(:one)
  end

  test "should get index" do
    get domains_url
    assert_response :success
  end

  test "index enqueues an import job and shows a pending message for a never-imported date" do
    assert_enqueued_with(job: NicImportJob, args: [ "15-05-2019", Date.new(2019, 5, 15) ]) do
      get domains_url, params: { fecha: "15-05-2019" }
    end

    assert_response :success
    assert_select "p", text: /Importando datos de nic.ar/
  end

  test "index shows an error for an invalid date" do
    get domains_url, params: { fecha: "not-a-date" }

    assert_response :success
    assert_select "p", text: /Invalid date format/
  end

  test "index reuses existing domains for a date already imported" do
    get domains_url, params: { fecha: "03-07-2026" } # coincide con registration_date de las fixtures

    assert_response :success
    assert_select "h2", text: /example-one/
    assert_no_difference("Domain.count") do
      get domains_url, params: { fecha: "03-07-2026" }
    end
  end

  test "should get new" do
    get new_domain_url
    assert_response :success
  end

  test "should create domain" do
    assert_difference("Domain.count") do
      post domains_url, params: { domain: { name: @domain.name, nic_id: "nic-id-99", registration_date: @domain.registration_date, transaction_type: @domain.transaction_type, zone: @domain.zone } }
    end

    assert_redirected_to domain_url(Domain.last)
  end

  test "should show domain" do
    get domain_url(@domain)
    assert_response :success
  end

  test "should get edit" do
    get edit_domain_url(@domain)
    assert_response :success
  end

  test "should update domain" do
    patch domain_url(@domain), params: { domain: { name: @domain.name, nic_id: @domain.nic_id, registration_date: @domain.registration_date, transaction_type: @domain.transaction_type, zone: @domain.zone } }
    assert_redirected_to domain_url(@domain)
  end

  test "should destroy domain" do
    assert_difference("Domain.count", -1) do
      delete domain_url(@domain)
    end

    assert_redirected_to domains_url
  end
end
