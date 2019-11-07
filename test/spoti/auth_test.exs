defmodule Spoti.AuthTest do
  use Spoti.DataCase

  alias Spoti.Auth

  describe "credentials" do
    alias Spoti.Auth.Credential

    @valid_attrs %{access_token: "some access_token", refresh_token: "some refresh_token"}
    @update_attrs %{
      access_token: "some updated access_token",
      refresh_token: "some updated refresh_token"
    }
    @invalid_attrs %{access_token: nil, refresh_token: nil}

    def credential_fixture(attrs \\ %{}) do
      {:ok, credential} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Auth.create_credential()

      credential
    end

    test "list_credentials/0 returns all credentials" do
      credential = credential_fixture()
      assert Auth.list_credentials() == [credential]
    end

    test "get_credential!/1 returns the credential with given id" do
      credential = credential_fixture()
      assert Auth.get_credential!(credential.id) == credential
    end

    test "create_credential/1 with valid data creates a credential" do
      assert {:ok, %Credential{} = credential} = Auth.create_credential(@valid_attrs)
      assert credential.access_token == "some access_token"
      assert credential.refresh_token == "some refresh_token"
    end

    test "create_credential/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_credential(@invalid_attrs)
    end

    test "update_credential/2 with valid data updates the credential" do
      credential = credential_fixture()
      assert {:ok, %Credential{} = credential} = Auth.update_credential(credential, @update_attrs)
      assert credential.access_token == "some updated access_token"
      assert credential.refresh_token == "some updated refresh_token"
    end

    test "update_credential/2 with invalid data returns error changeset" do
      credential = credential_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.update_credential(credential, @invalid_attrs)
      assert credential == Auth.get_credential!(credential.id)
    end

    test "delete_credential/1 deletes the credential" do
      credential = credential_fixture()
      assert {:ok, %Credential{}} = Auth.delete_credential(credential)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_credential!(credential.id) end
    end

    test "change_credential/1 returns a credential changeset" do
      credential = credential_fixture()
      assert %Ecto.Changeset{} = Auth.change_credential(credential)
    end
  end
end
