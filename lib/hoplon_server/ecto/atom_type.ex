defmodule HoplonServer.Ecto.AtomType do
  @behaviour Ecto.Type

  @type t :: atom

  @impl true
  def type(), do: :string

  @impl true
  def cast(atom) when is_atom(atom), do: {:ok, atom}

  def cast(string) when is_binary(string), do: safe_string_to_atom(string)

  def cast(_), do: :error

  @impl true
  def load(value), do: safe_string_to_atom(value)

  @impl true
  def dump(atom) when is_atom(atom), do: {:ok, Atom.to_string(atom)}

  def dump(_), do: :error

  @spec safe_string_to_atom(String.t()) :: {:ok, atom} | :error
  defp safe_string_to_atom(str) do
    try do
      # https://nietaki.com/2018/12/04/string-to-existing-atom-is-a-double-edged-sword/
      # {:ok, String.to_existing_atom(str)}
      {:ok, String.to_atom(str)}
    rescue
      ArgumentError -> :error
    end
  end
end
