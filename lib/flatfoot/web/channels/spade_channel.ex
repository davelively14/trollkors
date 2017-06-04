defmodule Flatfoot.Web.SpadeChannel do
  use Flatfoot.Web, :channel
  alias Flatfoot.{Spade, SpadeInspector}

  @doc """
  On join, will return a fully preloaded user JSON response.

  Provide the channel name (i.e. "spade:0") and the socket. Params are unused.
  """
  def join("spade:" <> user_id, _params, socket) do
    if user = Spade.get_user_preload(user_id) do
      {:ok, Phoenix.View.render(Flatfoot.Web.Spade.UserView, "user.json", %{user: user}), assign(socket, :user_id, user.id)}
    else
      {:error, "User does not exist"}
    end
  end

  @doc """
  On order, will fetch and return a fully preloaded user JSON response.

  Must include the "get_user" message, and a valid user_id within params object.

  Params requirement:
  "user_id": integer
  """
  def handle_in("get_user", params, socket) do
    if user = Spade.get_user_preload(params["user_id"]) do
      broadcast! socket, "user_data", Phoenix.View.render(Flatfoot.Web.Spade.UserView, "user.json", %{user: user})

      {:reply, :ok, socket}
    else
      {:reply, :error, socket}
    end
  end

  @doc """
  On order, will fetch and return a fully preloaded ward JSON response.

  Must include the "get_ward" message, and a valid ward_id within params object.

  Params requirement:
  "ward_id": integer
  """
  def handle_in("get_ward", params, socket) do
    if ward = Spade.get_ward_preload(params["ward_id"]) do
      broadcast! socket, "ward_#{ward.id}_data", Phoenix.View.render(Flatfoot.Web.WardView, "ward_preload.json", %{ward: ward})

      {:reply, :ok, socket}
    else
      {:reply, :error, socket}
    end
  end

  @doc """
  On order, fetches recently stored results for a given ward_account_id

  Must include the "get_ward_account_results" message and a valid ward_account_id within params object.

  Params requirement:
  "ward_account_id": integer (required)
  "as_of": ISO date YYYY-MM-DD (optional)
  """
  def handle_in("get_ward_account_results", %{"ward_account_id" => id, "as_of" => as_of}, socket) do
    if Regex.match?(~r/\d{4}-\d{2}-\d{2}/, as_of) do
      results = Spade.list_ward_results(id, as_of)
      broadcast! socket, "ward_account_#{id}_results", Phoenix.View.render(Flatfoot.Web.Spade.WardResultView, "ward_result_list.json", %{ward_results: results})

      {:reply, :ok, socket}
    else
      {:reply, :error, socket}
    end
  end
  def handle_in("get_ward_account_results", %{"ward_account_id" => id}, socket) do
    results = Spade.list_ward_results(id)
    broadcast! socket, "ward_account_#{id}_results", Phoenix.View.render(Flatfoot.Web.Spade.WardResultView, "ward_result_list.json", %{ward_results: results})

    {:reply, :ok, socket}
  end

  @doc """
  On order, fetches the newest results for all active wards of a given user. Results are returned in order of newest to oldest.

  Must include the "get_ward_results_for_user" message and a valid user token within the params object.

  Params requirement:
  "token": string (required)
  "as_of": ISO date YYYY-MM-DD (optional)
  """
  def handle_in("get_ward_results_for_user", %{"token" => token, "as_of" => as_of}, socket) do
    if Regex.match?(~r/\d{4}-\d{2}-\d{2}/, as_of) do
      results = Spade.list_ward_results_by_user(token, as_of)
      broadcast! socket, "user_ward_results", Phoenix.View.render(Flatfoot.Web.Spade.WardResultView, "ward_result_list.json", %{ward_results: results})

      {:reply, :ok, socket}
    else
      {:reply, :error, socket}
    end
  end
  def handle_in("get_ward_results_for_user", %{"token" => token}, socket) do
    results = Spade.list_ward_results_by_user(token)
    broadcast! socket, "user_ward_results", Phoenix.View.render(Flatfoot.Web.Spade.WardResultView, "ward_result_list.json", %{ward_results: results})

    {:reply, :ok, socket}
  end

  @doc """
  On order, fetches new results for a given ward. Will automaticaly load results
  for all associated ward_accounts.

  Must include the "fetch_new_ward_results" message and a valid ward_id.

  Params requirement:
  "ward_id": integer (required)
  """
  def handle_in("fetch_new_ward_results", %{"ward_id" => id}, socket) do
    SpadeInspector.Server.fetch_update(id)

    {:reply, :ok, socket}
  end

  @doc """
  Will receive a new_ward_results broadcast from the SpadeInspector.Sever module.
  """
  def handle_in("new_ward_results", %{"results" => _results}, socket) do

    {:noreply, :ok, socket}
  end

  @doc """
  With valid parameters, will create a new ward and return the new ward.

  Must include "create_ward" message and valid "ward_params".

  Params requirement:
  "ward_params": map (required)
   -> valid parameters for "ward_params":
    - "user_id": integer (required)
    - "name": string (required)
    - "relationship": string (required)
    - "active": boolean (optional)
  """
  def handle_in("create_ward", %{"ward_params" => attrs}, socket) do
    if attrs["user_id"] && attrs["name"] && attrs["relationship"] do
      {:ok, new_ward} = Spade.create_ward(attrs)
      broadcast! socket, "new_ward", Phoenix.View.render(Flatfoot.Web.WardView, "ward.json", %{ward: new_ward})
    else
      broadcast! socket, "Error: invalid attributes passed for create_ward", attrs
    end

    {:reply, :ok, socket}
  end
end
