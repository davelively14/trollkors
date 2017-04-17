defmodule Flatfoot.Spade.User do
  use Ecto.Schema

  schema "clients_users" do
    has_many :watchlists, Flatfoot.Spade.Watchlist, on_delete: :delete_all
    has_many :wards, Flatfoot.Spade.Ward, on_delete: :delete_all
    field :email, :string
    field :username, :string

    timestamps()
  end
end
