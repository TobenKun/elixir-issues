defmodule Issues.TableFormatter do
  import Enum, only: [each: 2, map: 2, map_join: 3, max: 1]

  def print_table_for_columns(rows, headers) do
    with data_by_columns = split_into_columns(rows, headers),
         column_widths = widths_of(data_by_columns, headers) do
      puts_one_line_in_columns(headers, column_widths)
      IO.puts(separator(column_widths))
      puts_in_columns(data_by_columns, column_widths)
    end
  end

  def split_into_columns(rows, headers) do
    for header <- headers do
      for row <- rows, do: printable(row[header])
    end
  end

  def printable(str) when is_binary(str), do: str
  def printable(str), do: to_string(str)

  def widths_of(columns, headers) do
    Enum.zip(columns, headers)
    |> Enum.map(fn {column, header} ->
      [to_string(header) | column]
      |> map(&Issues.WidthHelper.visual_length/1)
      |> max()
    end)
  end

  def format_for(column_widths) do
    map_join(column_widths, " | ", fn width -> "~-#{width}s" end) <> "~n"
  end

  def separator(column_widths) do
    map_join(column_widths, "-+-", fn width -> List.duplicate("-", width) end)
  end

  def puts_in_columns(data_by_columns, widths) do
    data_by_columns
    |> Enum.zip()
    |> map(&Tuple.to_list/1)
    |> each(&puts_one_line_in_columns(&1, widths))
  end

  def puts_one_line_in_columns(fields, widths) do
    fields
    |> Enum.zip(widths)
    |> Enum.map(fn {field, width} -> pad_to_width(field, width) end)
    |> Enum.join(" | ")
    |> IO.puts()
  end

  def pad_to_width(str, width) do
    length = Issues.WidthHelper.visual_length(str)
    padding_size = width - length
    padding = String.duplicate(" ", max(padding_size, 0))
    str <> padding
  end
end
