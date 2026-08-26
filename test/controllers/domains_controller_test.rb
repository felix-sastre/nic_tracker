require "test_helper"

class DomainsControllerTest < ActionDispatch::IntegrationTest
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
    assert_select "p", text: /Formato de fecha inválido/
  end

  test "index reuses existing domains for a date already imported" do
    get domains_url, params: { fecha: "03-07-2026" } # coincide con registration_date de las fixtures

    assert_response :success
    assert_select "h2", text: /example-one/
    assert_no_difference("Domain.count") do
      get domains_url, params: { fecha: "03-07-2026" }
    end
  end

  test "index enqueues a DNS check job only for domains without a status yet" do
    unchecked = Domain.create!(name: "unchecked", zone: "com.ar", registration_date: domains(:one).registration_date, nic_id: "unchecked-1", transaction_type: "alta")

    assert_enqueued_with(job: DomainStatusCheckJob, args: [ unchecked.id ]) do
      get domains_url, params: { fecha: "03-07-2026" }
    end

    assert_enqueued_jobs 1, only: DomainStatusCheckJob
    assert_select "span", text: /Chequeando/
  end
end
