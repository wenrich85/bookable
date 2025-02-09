defmodule Bookable.Impl.Month do


  def create_month(name, day, func) do
    date = Timex.beginning_of_month(day)
    Enum.to_list(1..Timex.days_in_month(day.year, day.month))
    |> Enum.map(&(func.(name, NaiveDateTime.add(date,&1-1, :day))))
  end

  def get_weekdays(month) do
    Enum.filter(month, &(Timex.weekday(get_from_date(&1)) < 6))
  end


  defp get_from_date(date) do
    List.first(date.unavailable).from
  end

end
