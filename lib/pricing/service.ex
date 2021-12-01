defmodule Pricing.Service do
  @moduledoc """
  Fictional service in charge of ticket pricing.
  """

  def current(_event_id, _unit \\ :cents), do: 2_000
end
