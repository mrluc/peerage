defmodule Peerage.Via.Self do
  use Peerage.Server
  
  def poll, do: [node()]
end
