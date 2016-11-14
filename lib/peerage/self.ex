defmodule Peerage.Via.Self do
  @behaviour Peerage.Provider
  @moduledoc "'No-op' Provider that only tries to connect to itself."
  
  def poll, do: [node()]
end
