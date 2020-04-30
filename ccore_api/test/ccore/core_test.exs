defmodule CCore.CoreTest do
  use CCore.DataCase

  alias CCore.Core

  describe "ccore" do
    alias CCore.Core.Sat

    @valid_attrs %{sat: "some sat"}
    @update_attrs %{sat: "some updated sat"}
    @invalid_attrs %{sat: nil}

    def sat_fixture(attrs \\ %{}) do
      {:ok, sat} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Core.create_sat()

      sat
    end

    test "list_ccore/0 returns all ccore" do
      sat = sat_fixture()
      assert Core.list_ccore() == [sat]
    end

    test "get_sat!/1 returns the sat with given id" do
      sat = sat_fixture()
      assert Core.get_sat!(sat.id) == sat
    end

    test "create_sat/1 with valid data creates a sat" do
      assert {:ok, %Sat{} = sat} = Core.create_sat(@valid_attrs)
      assert sat.sat == "some sat"
    end

    test "create_sat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_sat(@invalid_attrs)
    end

    test "update_sat/2 with valid data updates the sat" do
      sat = sat_fixture()
      assert {:ok, %Sat{} = sat} = Core.update_sat(sat, @update_attrs)
      assert sat.sat == "some updated sat"
    end

    test "update_sat/2 with invalid data returns error changeset" do
      sat = sat_fixture()
      assert {:error, %Ecto.Changeset{}} = Core.update_sat(sat, @invalid_attrs)
      assert sat == Core.get_sat!(sat.id)
    end

    test "delete_sat/1 deletes the sat" do
      sat = sat_fixture()
      assert {:ok, %Sat{}} = Core.delete_sat(sat)
      assert_raise Ecto.NoResultsError, fn -> Core.get_sat!(sat.id) end
    end

    test "change_sat/1 returns a sat changeset" do
      sat = sat_fixture()
      assert %Ecto.Changeset{} = Core.change_sat(sat)
    end
  end
end
