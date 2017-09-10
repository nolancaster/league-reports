require 'test_helper'

class LineupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @lineup = lineups(:one)
  end

  test "should get index" do
    get lineups_url
    assert_response :success
  end

  test "should get new" do
    get new_lineup_url
    assert_response :success
  end

  test "should create lineup" do
    assert_difference('Lineup.count') do
      post lineups_url, params: { lineup: { owner_id: @lineup.owner_id, result: @lineup.result, score: @lineup.score, team_id: @lineup.team_id, team_name: @lineup.team_name } }
    end

    assert_redirected_to lineup_url(Lineup.last)
  end

  test "should show lineup" do
    get lineup_url(@lineup)
    assert_response :success
  end

  test "should get edit" do
    get edit_lineup_url(@lineup)
    assert_response :success
  end

  test "should update lineup" do
    patch lineup_url(@lineup), params: { lineup: { owner_id: @lineup.owner_id, result: @lineup.result, score: @lineup.score, team_id: @lineup.team_id, team_name: @lineup.team_name } }
    assert_redirected_to lineup_url(@lineup)
  end

  test "should destroy lineup" do
    assert_difference('Lineup.count', -1) do
      delete lineup_url(@lineup)
    end

    assert_redirected_to lineups_url
  end
end
