defmodule Peerage.Via.List do
  use Peerage.Server
  
  def poll do
    Application.fetch_env!(:peerage, :node_list)
  end
end
