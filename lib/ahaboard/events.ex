defmodule Ahaboard.Events do

  import Ecto.Query

  alias Ahaboard.Repo
  alias Ahaboard.Events.Event

  @spec list_events(binary(), map) :: [Event.t()]
  def list_events(user_id, params) do
    Event
    |> where(user_id: ^user_id)
    |> where(^filter_where(params))
    |> order_by(desc: :updated_at)
    |> limit(100)
    |> Repo.all()
  end

  @spec filter_where(map) :: Ecto.Query.DynamicExpr.t()
  def filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {"q", value}, dynamic ->
        dynamic([p], ^dynamic and ilike(p.name, ^"%#{value}%"))

      {_, _}, dynamic ->
        # Not a where parameter
        dynamic
    end)
  end

  @spec get_event!(binary()) :: Event.t() | nil
  def get_event!(id) do
    Event |> Repo.get!(id)
  end

  @spec get_event!(binary(), integer) :: Event.t() | nil
  def get_event!(id, user_id) do
    Event |> Repo.get_by!([id: id, user_id: user_id])
  end

  @spec get_event_by_code(binary()) :: Event.t() | nil
  def get_event_by_code(code) do
    Event |> Repo.get_by([code: code])
  end

  @spec create_event(map()) :: {:ok, Event.t()} | {:error, Ecto.Changeset.t()}
  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Event.clean_code()
    |> Repo.insert()
  end

  @spec update_event(Event.t, map()) :: {:ok, Event.t()} | {:error, Ecto.Changeset.t()}
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end
end
