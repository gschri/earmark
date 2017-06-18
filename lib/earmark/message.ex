defmodule Earmark.Message do

  alias Earmark.Context
  alias Earmark.Options

  @type message_type :: :error | :warning
  @type t :: {message_type, number, binary}
  @type ts:: list(t)
  @type container_type :: Options.t | Context.t

  @spec add_messages(container_type, ts) :: container_type
  def add_messages(container, messages), do:
    Enum.reduce(messages, container, &(add_message(&2, &1)))

  @spec add_message(container_type, t) :: container_type
  def add_message(container, message)
  def add_message(options = %Options{}, message) do
    %{options | messages: [message | options.messages]}
  end
  def add_message(context = %Context{}, message) do
    %{context | options: %{context.options | messages: [message | context.options.messages]}}
  end

  @spec get_messages( container_type ) :: ts
  def get_messages(container)
  def get_messages(%Context{options: %{messages: messages}}), do: messages
  def get_messages(%Options{messages: messages}),             do: messages

  def emit_messages(filename, messages, device \\ :stderr), do:
    Enum.each(messages, &(emit_message(filename, &1, device)))

  defp emit_message(filename, msg, device), do:
    IO.puts(device, format_message(filename, msg))

  @spec format_message( String.t, t ) :: String.t
  defp format_message filename, {type, line, text} do
    "#{filename}:#{line}: #{type}: #{text}"
  end
end
