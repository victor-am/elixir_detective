defmodule ElixirDetective.Debug.Logger do
  require Logger
  @colors %{
    defmodule: :cyan,
    alias: :green,
    import: :green,
    unknown: :magenta,
    block: :yellow,
    dead_end: :blue
  }
  
  def defmodule_node(node, module_name) do
    log_node(:defmodule, "[Node] Defmodule node - Module: \"#{module_name}\"")
    log_node(:defmodule, format(node))
  end

  def alias_node(node, module_name) do
    log_node(:alias, "[Node] Alias node - Module: \"#{module_name}\"")
    log_node(:alias, format(node))
  end
  
  def import_node(node, module_name) do
    log_node(:import, "[Node] Import node - Module: \"#{module_name}\"")
    log_node(:import, format(node))
  end

  def unknown_node(node) do
    log_node(:unknown, "[Node] Unknown node")
    log_node(:unknown, format(node))
  end

  def block_node(node) do
    log_node(:block, "[Node] Block node")
    log_node(:block, format(node))
  end

  def dead_end_node(node) do 
    log_node(:dead_end, "[Node] Dead-end node")
    log_node(:dead_end, format(node))
  end

  defp log_node(node_type, message) do
    Logger.debug(message, ansi_color: @colors[node_type])
  end

  defp format(data) do
    formatted_data = inspect(data, pretty: true, limit: 10)
    "#{formatted_data}\n"
  end
end