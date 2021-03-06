defmodule MauricioTest.Storage.MongoStorage do
  use ExUnit.Case
  use PropCheck

  alias Mauricio.Storage
  alias MauricioTest.TestData

  setup do
    Storage.flush()
  end

  test "fetch failed" do
    assert :error == Storage.fetch(1)
  end

  test "flush drops collection" do
    some_chat = TestData.produce_some_chat()
    chat_id = some_chat.chat_id

    :ok = Storage.put(some_chat)
    {:ok, _} = Storage.fetch(chat_id)

    Storage.flush()

    assert :error == Storage.fetch(chat_id)
  end

  test "put then fetch" do
    some_chat = TestData.produce_some_chat()
    chat_id = some_chat.chat_id
    :ok = Storage.put(some_chat)
    {:ok, fetched_chat} = Storage.fetch(chat_id)
    assert some_chat == fetched_chat
  end

  test "get all ids" do
    some_chat = &TestData.produce_some_chat/0

    chats =
      [some_chat.(), some_chat.(), some_chat.(), some_chat.(), some_chat.()]
      |> Enum.uniq_by(&(&1.chat_id))

    chat_ids = MapSet.new(chats, &(&1.chat_id))

    Enum.each(chats, &Storage.put/1)
    retrieved_chat_ids = Storage.get_all_ids() |> MapSet.new()
    assert chat_ids == retrieved_chat_ids
  end

  test "put then pop" do
    some_chat = TestData.produce_some_chat()
    chat_id = some_chat.chat_id
    :ok = Storage.put(some_chat)
    Storage.pop(chat_id)
    assert :error == Storage.fetch(chat_id)
  end

  test "update" do
    some_chat = TestData.produce_some_chat()
    chat_id = some_chat.chat_id

    :ok = Storage.put(some_chat)
    new_old_chat = update_in(some_chat.cat.weight, &(&1 + 1))

    :ok = Storage.put(new_old_chat)
    {:ok, fetched_chat} = Storage.fetch(chat_id)

    assert fetched_chat == new_old_chat
  end
end
