defmodule Bookable.Impl.Day do
  defstruct ~w[unavailable available appointments owner]a

  @seconds_in_day 86400

  def new(first, date \\ NaiveDateTime.utc_now())
  def new(name, date) when is_binary(name) do
    new(%__MODULE__{owner: name, appointments: []},
      date
      |>Timex.beginning_of_day()
    )
  end

  def new(day_struct = %{}, date) do
    day_struct
    |> struct( %{available: [], unavailable: [Timex.Interval.new(step: [minutes: 15], from: date, until: [seconds: @seconds_in_day - 1])]})
  end

  def set_working_hours(day, start_time, end_time) do
    working_hours =Timex.Interval.new(from: start_time, until: end_time, step: [minutes: 15])
    day
    |>struct(available: [ working_hours ])
    |>struct(unavailable: Timex.Interval.difference(List.first(day.unavailable), working_hours))
  end

  def list_available_times(day, duration) do
   get_all_possible_timeslots(day.available)
   # filter the time slots that contain the duration of the appoinment
   |> get_timeslots_for_appointment(day.available, duration)
  # format the appointment times
   |> Enum.map(&Timex.format!(&1, "%H:%M", :strftime))
  end

  def add_appointment(day, appointment) do
    with {:ok, availability} <- confirm_availability(day, appointment) do
      day
      |> struct(appointments: [ day.appointments | appointment ])
      |> struct(available: update_availability(day.available, availability, appointment ))
    end

  end


 ###################################PRIVATE FUNTCIONS###############################################################

  defp get_all_possible_timeslots(availability) do
    availability
    |>Enum.reduce([], fn x, acc -> [ Enum.map(x, &(&1)) | acc ] end)
    |> List.flatten()
  end

  defp get_timeslots_for_appointment(times, availability, duration) do
    availability
    |> Enum.map(&filter_times(&1, times, duration))
    |> List.flatten()
  end


  defp filter_times(availability, times, duration) do
    times
    |> Enum.filter(&(Timex.Interval.contains?(availability, Timex.Interval.new(from: &1, until: [minutes: duration]))))
  end

  defp confirm_availability(day, appointment) do
    day.available
    |> Enum.filter(&(Timex.Interval.contains?(&1, appointment.interval)))
    |> return_tuple()
  end

  defp return_tuple(list) when length(list) > 0 do
    {:ok, List.first(list)}
  end

  defp return_tuple(_) do
    {:error, []}
  end

  defp update_availability(available_time, availability, appointment) do
    index = Enum.find_index(available_time, &(&1 == availability))
    {work_on, new_avail}  = List.pop_at(available_time, index)
    [Timex.Interval.difference(work_on, appointment.interval) | new_avail]
    |> List.flatten()
  end


end
