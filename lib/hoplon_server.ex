defmodule HoplonServer do
  def welcome_message(name, greeting \\ "Hello") do
    "#{greeting}, #{name}!"
  end
end
