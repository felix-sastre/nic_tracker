require "test_helper"

class StatsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get stats_url
    assert_response :success
  end

  test "index aggregates domain counts by registration date" do
    get stats_url

    assert_select "td", text: "03-07-2026"
    assert_select "tr", text: /03-07-2026.*2.*0.*2.*0/m
  end
end
