defmodule Bookable do
  alias Bookable.Impl.Day
  alias Bookable.Impl.Month

  def new(name) do
    Day.new(name)
  end

  def new(name, date) do
    Day.new(name, date)
  end

  def create_month(name, day) do
    Month.create_month(name, day, &Day.new/2)
  end

  def create_month_of_weekdays(name, day) do
    Month.create_month(name, day, &Day.new/2)
    |> Month.get_weekdays()
  end

end
