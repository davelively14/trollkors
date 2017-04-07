defmodule Flatfoot.Web.BlackoutOptionControllerTest do
  use Flatfoot.Web.ConnCase

  # alias Flatfoot.Clients.BlackoutOption

  setup [:login_user_setup]

  describe "GET index" do
    test "renders a list of blackout options with valid settings_id", %{logged_in: conn} do
      settings = insert(:settings, user: conn.assigns.current_user)
      insert_list(3, :blackout_option, settings: settings)
      insert_list(2, :blackout_option)

      conn = get conn, blackout_option_path(conn, :index), %{settings_id: settings.id}
      assert %{"data" => results} = json_response(conn, 200)
      assert results |> length == 3
    end

    test "with invalid settings_id returns error", %{logged_in: conn} do
      assert_raise Ecto.NoResultsError, fn -> get conn, blackout_option_path(conn, :index), %{settings_id: 0} end
    end

    test "returns empty list if settings has no blackout options", %{logged_in: conn} do
      settings = insert(:settings, user: conn.assigns.current_user)
      conn = get conn, blackout_option_path(conn, :index), %{settings_id: settings.id}
      assert %{"data" => []} = json_response(conn, 200)
    end

    test "cannot view other users blackout options", %{logged_in: conn} do
      insert(:settings, user: conn.assigns.current_user)
      settings = insert(:settings)
      insert(:blackout_option, settings: settings)
      conn = get conn, blackout_option_path(conn, :index), %{settings_id: settings.id}
      assert %{"errors" => "Unauthorized. Can not view or edit content for another user."} == json_response(conn, 401)
    end

    test "with invalid token returns 401 and halts", %{not_logged_in: conn} do
      settings = insert(:settings)
      insert_list(3, :blackout_option, settings: settings)

      conn = get conn, blackout_option_path(conn, :index), %{settings_id: settings.id}
      assert conn.status == 401
      assert conn.halted
    end

    test "with no settings_id returns ActionClauseError", %{logged_in: conn} do
      settings = insert(:settings, user: conn.assigns.current_user)
      insert_list(3, :blackout_option, settings: settings)
      insert_list(2, :blackout_option)

      assert_raise Phoenix.ActionClauseError, fn -> get conn, blackout_option_path(conn, :index) end
    end
  end

  describe "GET show" do
    test "renders a blackout_option with a valid id", %{logged_in: conn} do
      settings = insert(:settings, user: conn.assigns.current_user)
      option = insert(:blackout_option, settings: settings)

      conn = get conn, blackout_option_path(conn, :show, option.id)
      assert %{"data" => result} = json_response(conn, 200)

      assert result["id"] == option.id
      assert result["start"] == option.start |> Ecto.Time.to_string
      assert result["stop"] == option.stop |> Ecto.Time.to_string
      assert result["threshold"] == option.threshold
      assert result["exclude"] == option.exclude
      assert result["settings_id"] == option.settings_id
    end

    test "raises error on invalid id", %{logged_in: conn} do
      assert_raise Ecto.NoResultsError, fn -> get conn, blackout_option_path(conn, :show, 12) end
    end

    test "will return 401 and error when trying to view another user's blackout option", %{logged_in: conn} do
      settings = insert(:settings)
      option = insert(:blackout_option, settings: settings)

      conn = get conn, blackout_option_path(conn, :show, option.id)
      assert %{"errors" => "Unauthorized. Can not view or edit content for another user."} == json_response(conn, 401)
    end

    test "with invalid token returns 401 and halts", %{not_logged_in: conn} do
      option = insert(:blackout_option)

      conn = get conn, blackout_option_path(conn, :show, option.id)
      assert conn.status == 401
      assert conn.halted
    end
  end
end
