defmodule Issues.WidthHelper do
  def visual_length(str) do
    String.codepoints(str)
    |> Enum.reduce(0, fn cp, acc ->
      acc + char_width(cp)
    end)
  end

  defp char_width(<<cp::utf8>>) do
    cond do
      # 한글 (U+AC00 ~ U+D7A3)
      cp in 0xAC00..0xD7A3 ->
        2

      # CJK Unified Ideographs (한자)
      cp in 0x4E00..0x9FFF ->
        2

      # 히라가나
      cp in 0x3040..0x309F ->
        2

      # 가타카나
      cp in 0x30A0..0x30FF ->
        2

      # 전각 기호 등
      cp in 0xFF01..0xFF60 ->
        2

      true ->
        1
    end
  end
end
