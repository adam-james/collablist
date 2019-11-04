defmodule SpotiWebSearchControllerTest do
  use SpotiWeb.ConnCase

  describe "index" do
    test "renders search from", %{conn: conn} do
      conn = get(conn, Routes.search_path(conn, :index))
      assert html_response(conn, 200) =~ "Hi there Adam"
    end
  end
end
