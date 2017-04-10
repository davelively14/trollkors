defmodule Flatfoot.Factory do
  use ExMachina.Ecto, repo: Flatfoot.Repo

  def user_factory do
    pw = Faker.Code.isbn

    %Flatfoot.Clients.User{
      username: Faker.Internet.user_name,
      email: Faker.Internet.free_email,
      password_hash: Comeonin.Bcrypt.hashpwsalt(pw)
    }
  end

  def session_factory do
    %Flatfoot.Clients.Session{
      token: SecureRandom.urlsafe_base64(),
      user: build(:user)
    }
  end

  def notification_record_factory do
    %Flatfoot.Clients.NotificationRecord{
      nickname: Faker.Name.name,
      email: Faker.Internet.free_email,
      role: Faker.Company.buzzword,
      threshold: Enum.random(0..100),
      user: build(:user)
    }
  end

  def settings_factory do
    %Flatfoot.Clients.Settings{
      global_threshold: Enum.random(0..100),
      user: build(:user)
    }
  end

  def blackout_option_factory do
    %Flatfoot.Clients.BlackoutOption{
      start: random_ecto_time(),
      stop: random_ecto_time(),
      threshold: Enum.random(0..100),
      exclude: "[#{Faker.Address.state_abbr}, #{Faker.Address.state_abbr}]",
      settings: build(:settings)
    }
  end

  def archer_backend_factory do
    name_snake = Faker.Name.name |> String.downcase |> String.replace(" ", "_")
    
    %Flatfoot.Archer.Backend{
      name: Faker.Name.name,
      name_snake: name_snake,
      url: Faker.Internet.url,
      module: "Flatfoot.Archer.#{name_snake}"
    }
  end

  #####################
  # Private Functions #
  #####################

  defp random_ecto_time, do: Ecto.Time.cast({Enum.random(0..23), Enum.random([0,30]), 0}) |> elem(1)
end
