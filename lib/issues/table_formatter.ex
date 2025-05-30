defmodule Issues.TableFormatter do
  import Enum, only: [each: 2, map: 2, map_join: 3, max: 1]

  @doc """
  표의 각 행이 될 맵의 리스트와 헤더의 리스트를 받아,
  각 행에서 헤더를 기준으로 데이터를 식별해 표준 출력으로 표를 표시한다.
  즉 각 헤더는 표의 열이 되며, 이를 이용해 각 행에서 필드의 값을 추출해 출력한다.

  각 열의 가로 길이는 해당 열의 가장 긴 값에 맞도록 계산한다.
  """
  def print_table_for_columns(rows, headers) do
    with string_header = Enum.map(headers, &printable/1),
         data_by_columns = split_into_columns(rows, headers),
         column_widths = widths_of(data_by_columns, string_header) do
      puts_one_line_in_columns(string_header, column_widths)
      IO.puts(separator(column_widths))
      puts_in_columns(data_by_columns, column_widths)
    end
  end

  @doc """
  각 행이 키-값 쌍으로 이르어진 리스트일 때, 이 행의 리스트를 받아
  각 필드의 값만으로 이루어진 리스트를 반환한다.
  'header' 파라미터는 추출할 필드(열) 이름이 담긴 리스트다.

  ## 사용 예

    iex> list = [Enum.into([{"a", "1"}, {"b", "2"}, {"c", "3"}], %{}),
    ...>        Enum.into([{"a", "4"}, {"b", "5"}, {"c", "6"}], %{})]
    iex> Issues.TableFormatter.split_into_columns(list, [ "a", "b", "c"])
    [ ["1", "4"], ["2", "5"], ["3", "6"] ]
  """
  def split_into_columns(rows, headers) do
    for header <- headers do
      for row <- rows, do: printable(row[header])
    end
  end

  @doc """
  파라미터를 바이너리(문자열)로 변환해 반환한다.

  ## 사용 예
    iex> Issues.TableFormatter.printable("a")
    "a"
    iex> Issues.TableFormatter.printable(99)
    "99"
  """
  def printable(str) when is_binary(str), do: str
  def printable(str), do: to_string(str)

  @doc """
  데이터를 담은 리스트를 포함하는 중첩 리스트와
  각 데이터의 라벨 리스트를 받아.
  각 열의 최대 길이가 담긴 리스트를 반환한다.
  최대 길이는 데이터 중 최대 길이와 라벨의 길이 중 더 큰 것을 선택한다.

  ## 사용 예
    iex> data = [ [ "cat", "wombat", "elk"], ["mongoose", "ant", "gnu"]]
    iex> headers = ["long long word", "short"]
    iex> Issues.TableFormatter.widths_of(data, headers)
    [ 14, 8 ]
  """
  def widths_of(columns, headers) do
    Enum.zip(columns, headers)
    |> Enum.map(fn {column, header} ->
      [to_string(header) | column]
      |> map(&Issues.WidthHelper.visual_length/1)
      |> max()
    end)
  end

  @doc """
  *사용되지 않음*
  숫자의 리스트를 받아, 표의 열을 나누는 포맷 문자열을 반환한다.
  각 열 사이에는 '" | "' 문자를 넣는다.

  ## 사용 예
    iex> widths = [5,6,99]
    iex> Issues.TableFormatter.format_for(widths)
    "~-5s | ~-6s | ~-99s~n"
  """
  def format_for(column_widths) do
    map_join(column_widths, " | ", fn width -> "~-#{width}s" end) <> "~n"
  end

  @doc """
  표의 제목 행 아래에 올 구분선을 만든다.
  열 구분선과 같은 위치에는 +기호, 그 외의 자리에는 -기호를 사용한다.

  ## 사용 예
    iex> widths = [5, 6, 9]
    iex> Issues.TableFormatter.separator(widths)
    "------+--------+----------"
  """
  def separator(column_widths) do
    map_join(column_widths, "-+-", fn width -> List.duplicate("-", width) end)
  end

  @doc """
  데이터의 행으로 이루어진 리스트, 필드 리스트, 폭을 받아
  포맷 문자열의 형식으로 추출한 데이터를 출력한다.
  """
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
