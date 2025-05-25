defmodule TableFormatterTest do
  use ExUnit.Case
  # 표준 출력으로 나가는 값을 가져올 수 있게 한다
  import ExUnit.CaptureIO
  alias Issues.TableFormatter, as: TF

  @simple_test_data [
    [c1: "r1 c1", c2: "r1 c2", c3: "r1 c3", c4: "r1+++c4"],
    [c1: "r2 c1", c2: "r2 c2", c3: "r2 c3", c4: "r2 c4"],
    [c1: "r3 c1", c2: "r3 c2", c3: "r3 c3", c4: "r3 c4"],
    [c1: "r4 c1", c2: "r4++c2", c3: "r4 c3", c4: "r4 c4"]
  ]

  @headers [:c1, :c2, :c4]

  def split_with_three_columns do
    TF.split_into_columns(@simple_test_data, @headers)
  end

  test "컬럼을 나눈다." do
    columns = split_with_three_columns()
    assert length(columns) == length(@headers)
    assert List.first(columns) == ["r1 c1", "r2 c1", "r3 c1", "r4 c1"]
    assert List.last(columns) == ["r1+++c4", "r2 c4", "r3 c4", "r4 c4"]
  end

  test "컬럼의 너비" do
    # 함수를 수정하여 라벨을 함께 전달
    # 라벨이 더 긴 경우 라벨의 너비를 가져온다
    widths = TF.widths_of(split_with_three_columns(), ["L1", "L2", "L3"])
    assert widths == [5, 6, 7]
  end

  test "문자열이 올바른 형식으로 반환된다." do
    result =
      capture_io(fn ->
        TF.print_table_for_columns(@simple_test_data, @headers)
      end)

    assert result == """
           c1    | c2     | c4     
           ------+--------+--------
           r1 c1 | r1 c2  | r1+++c4
           r2 c1 | r2 c2  | r2 c4  
           r3 c1 | r3 c2  | r3 c4  
           r4 c1 | r4++c2 | r4 c4  
           """
  end
end
