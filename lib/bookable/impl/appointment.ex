defmodule Bookable.Impl.Appointment do
  alias Timex.Interval
  defstruct ~w[interval name ]a

  def new(%{name: name, start: start, duration: duration}) do
    %__MODULE__{
      name: name,
      interval: Interval.new(from: start, until: [minutes: duration])
    }
  end
end
