defmodule NeoWalletWeb.Util do
  @alpa "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

  def hex_to_integer(hexStr) do
    hexStr |>
    hexStr2Bytes |>
    bytes2Integer
  end

  def hex_to_addr(hexStr) do
    hexStr2Bytes(hexStr) |> bytes2NeoAddress
  end

  def hex_to_string(hexStr) do
    hexStr2Bytes(hexStr)
  end


  defp hexStr2Bytes(hexString, bytes \\ <<>>) do
    length = String.length(hexString)

    cond do
      length == 0 ->
        bytes

      rem(length, 2) != 0 ->
        raise "hex string length % 2 != 0"

      true ->
        {a, left} = String.split_at(hexString, 2)
        {b, ""} = Integer.parse(a, 16)
        <<h::size(4), l::size(4)>> = <<b>>
        hexStr2Bytes(left, bytes <> <<h::size(4), l::size(4)>>)
    end
  end

  defp bytes2Integer(hexBytes) do
    bitSize = bit_size(hexBytes)
    <<x::size(bitSize)-little-integer>> = hexBytes
    x
  end

  defp bytes2NeoAddress(hexBytes) do
    addressVersion = Application.get_env(:neo_wallet_web, :neo_address_version, 23)
    addressBits = <<addressVersion::size(8), hexBytes::binary>>
    checksum = :crypto.hash(:sha256, :crypto.hash(:sha256, addressBits))

    #??? 为什么直接获取的结果不对？<<checksumRst::32, _other::binary>> = checksum
    # A: 默认为32位integer，如果后续使用<<checksumRst>>，会取余。应该使用<<checksumRst::32-bitstring,...>>表示。
    <<checksumRst::32-bitstring, _other::binary>> = checksum

    #IO.puts("checksum - #{inspect(checksum)}")
    #IO.puts("inspect - #{inspect(checksumRst)}")
    data = addressBits <> checksumRst
    base58(data)

  end

  defp base58(inputBytes) do
   # IO.puts(inspect(inputBytes)) # ok
    #IO.puts("aaaaaaa")

    #??? 自定义的binary_reverse算法和String.reverse的算法哪里不同？
   # IO.puts(inspect(binary_reverse(<<0::size(8)>> <> inputBytes, <<>>))) #ok
    #IO.puts(inspect(String.reverse(<<0::size(8)>> <> inputBytes))) #ok

    reverseBits = binary_reverse(<<0::size(8)>> <> inputBytes, <<>>)#String.reverse(<<0::size(8)>> <> inputBytes)
    mysize = bit_size(reverseBits)

    <<value::size(mysize)-signed-little-integer>> = reverseBits

    #IO.puts(value)
    {sb, modValue} = base58Help(value)
    #IO.puts(inspect(xxxxxx))
    sb2 = String.at(@alpa, modValue) <> sb # ok

    appendF(:binary.bin_to_list(inputBytes), sb2)
  end

  defp base58Help(value, sb \\ <<>>) do
    if value >= 58 do
      mod = rem(value, 58)
      dived = div(value, 58)
      base58Help(dived, String.at(@alpa, mod) <> sb)
    else
      {sb, value}
    end
  end

  defp appendF(charLst, sb) do
    case charLst do
      [] ->
        sb
      _x ->
        fist = List.first(charLst)
        if fist == 0 do
          appendF(List.delete_at(charLst, 0), String.at(@alpa, 0) <> sb)
        else
          sb
        end

    end
  end

  # use bit syntax instend
  # defp binary2integer(binary, sum \\ 0, curIndex \\ 0, maxIndex \\ 0) do
  #   size = bit_size(binary)
  #   if size == 0 do
  #     sum
  #   else

  #     {newSum, otherBinary} = if index == 0 do
  #       <<first::size(8)-signed-integer, other::binary>> = binary
  #       {sum + first * :math.pow(256, index)}
  #     end
  #     binary2Integer(other, sum + first)
  #   end
  # end

  # same as String.reverse
  defp binary_reverse(binary, acc) do
    # IO.puts(binary)
    if byte_size(binary) == 1 do
      binary <> acc
    else
      <<head::size(8), other::binary>> = binary
      # IO.puts(acc)
      binary_reverse(other, <<head>> <> acc)
    end

  end

  def read_file_lines(path) do
    File.stream!(path)
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn line -> line end)
    |> Enum.to_list
  end
end
