defmodule STBU.Interface.PetViewer do

  def view_next(addr) do
    send addr, {:view_next, self()}
    receive do
      {:animal, animal} -> animal
      :busy -> nil
    end
  end

  def try_play(addr) do
    send addr, {:try_play, self()}
    receive do
      :playing -> :ok
      :busy -> :error
    end
  end

  def try_adopt(addr) do
    send addr, {:try_adopt, self()}
    receive do
      :adopted -> :ok
      :busy -> :error
      {:schedule, sched} -> {:schedule, sched}
    end
  end

  def finished(addr) do
    send addr, :finished
    nil
  end
end
