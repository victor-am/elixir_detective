defmodule ElixirDetective.Debug.Logger do
  require Logger

  @colors %{
    defmodule: :cyan,
    reference: :green,
    alias: :red,
    unknown: :magenta,
    do: :yellow,
    block: :yellow,
    call: :yellow,
    dead_end: :blue
  }

  def defmodule_node(node, module_name) do
    log_node(:defmodule, "[Node] Defmodule node - Module: \"#{join(module_name)}\"")
    log_node(:defmodule, format(node))
  end

  def reference_node(node, module_name) do
    log_node(:reference, "[Node] Reference node - Module: \"#{join(module_name)}\"")
    log_node(:reference, format(node))
  end

  def alias_node(node) do
    log_node(:alias, "[Node] Alias node")
    log_node(:alias, format(node))
  end

  def unknown_node(node) do
    log_node(:unknown, "[Node] Unknown node")
    log_node(:unknown, format(node))
  end

  def do_node(node) do
    log_node(:do, "[Node] Do node")
    log_node(:do, format(node))
  end

  def block_node(node) do
    log_node(:do, "[Node] Block node")
    log_node(:do, format(node))
  end

  def call_node(node) do
    log_node(:do, "[Node] Call node")
    log_node(:do, format(node))
  end

  def dead_end_node(node) do
    log_node(:dead_end, "[Node] Dead-end node")
    log_node(:dead_end, format(node))
  end

  def warn(message) do
    message
    |> format(1000)
    |> Logger.warn()
  end

  defp log_node(node_type, message) do
    Logger.debug(message, ansi_color: @colors[node_type])
  end

  defp format(data), do: format(data, 10)

  defp format(data, limit) do
    formatted_data = inspect(data, pretty: true, limit: limit)
    "#{formatted_data}\n"
  end

  defp join(list) do
    try do
      Enum.join(list, ".")
    rescue
      _ -> inspect(list)
    end
  end
end
