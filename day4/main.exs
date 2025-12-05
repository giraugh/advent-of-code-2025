# Figure out where our input is and read it
input_path =
  case Enum.fetch(System.argv(), 1) do
    {:ok, path} -> path
    :error -> raise "No input path provided"
  end

# Read the input
{:ok, contents} = File.read(input_path)

# Parse each char and get coordinates
grid =
  String.splitter(contents, "\n")
  |> Enum.with_index()
  |> Enum.flat_map(fn {line, y} ->
    String.graphemes(line)
    |> Enum.with_index()
    |> Enum.map(fn {char, x} ->
      case char do
        "@" -> {x, y}
        "." -> nil
      end
    end)
    |> Enum.filter(fn x -> x != nil end)
  end)

# All the occupied coords
grid_s = MapSet.new(grid)

defmodule AoC3 do
  def count_accessible_at(grid_s, {x, y}) do
    -1..1
    |> Enum.flat_map(fn dx -> -1..1 |> Enum.map(fn dy -> {dx, dy} end) end)
    |> Enum.filter(fn {dx, dy} -> not (dx == 0 && dy == 0) end)
    |> Enum.filter(fn {dx, dy} -> MapSet.member?(grid_s, {x + dx, y + dy}) end)
    |> Enum.count()
  end

  def count_accessible(grid_s, grid) do
    Enum.reduce(grid, 0, fn {x, y}, acc ->
      acc +
        case count_accessible_at(grid_s, {x, y}) do
          n when n < 4 -> 1
          _ -> 0
        end
    end)
  end

  def count_removable(grid_s, total) do
    # What could be removed
    to_remove =
      MapSet.to_list(grid_s)
      |> Enum.map(fn coord ->
        case count_accessible_at(grid_s, coord) do
          n when n < 4 -> coord
          _ -> nil
        end
      end)
      |> Enum.filter(fn x -> x != nil end)

    to_remove_s = MapSet.new(to_remove)

    # If we have some to remove, add them then recurse otherwise stop here
    case MapSet.size(to_remove_s) do
      0 -> total
      remove_amt -> count_removable(MapSet.difference(grid_s, to_remove_s), total + remove_amt)
    end
  end
end

p1 = AoC3.count_accessible(grid_s, grid)
p2 = AoC3.count_removable(grid_s, 0)

IO.inspect(p1)
IO.inspect(p2)
