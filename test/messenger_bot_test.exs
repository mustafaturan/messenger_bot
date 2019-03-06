defmodule MessengerBotTest do
  use ExUnit.Case, async: false
  import Mock
  alias MessengerBot.Client.Base, as: Client

  @app_id "1881"
  @page_id "1234"
  @tx_id UUID.uuid4()

  test ".upload_attachment" do
    attachment = %{type: "image", payload: %{url: "...", is_reusable: true}}

    with_mock Client, [rpost: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.upload_attachment({@app_id, @page_id}, attachment, @tx_id)

      assert called Client.rpost(
                      "/me/message_attachments",
                      %{message: %{attachment: attachment}},
                      {@app_id, @page_id, :mb_attachment_upload, @tx_id}
                    )
    end
  end

  test ".create_message_creative" do
    messages = [%{}]

    with_mock Client, [rpost: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.create_message_creative({@app_id, @page_id}, messages, @tx_id)

      assert called Client.rpost(
                      "/me/message_creatives",
                      %{messages: messages},
                      {@app_id, @page_id, :mb_create_message_creatives, @tx_id}
                    )
    end
  end

  test ".broadcast_message" do
    message_ref = %{message_creative_id: 938_461_089}

    with_mock Client, [rpost: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.broadcast_message({@app_id, @page_id}, message_ref, @tx_id)

      assert called Client.rpost(
                      "/me/broadcast_messages",
                      message_ref,
                      {@app_id, @page_id, :mb_broadcast_message, @tx_id}
                    )
    end
  end

  test ".list_custom_labels without cursor" do
    fields = ["name"]

    with_mock Client, [rget: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.list_custom_labels({@app_id, @page_id}, {fields, nil}, @tx_id)

      assert called Client.rget(
                      "/me/custom_labels",
                      [fields: "name"],
                      {@app_id, @page_id, :mb_list_custom_labels, @tx_id}
                    )
    end
  end

  test ".list_custom_labels with cursor" do
    fields = ["name"]
    cursor = {:after, "rehsmT"}

    with_mock Client, [rget: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.list_custom_labels({@app_id, @page_id}, {fields, cursor}, @tx_id)

      assert called Client.rget(
                      "/me/custom_labels",
                      [after: "rehsmT", fields: "name"],
                      {@app_id, @page_id, :mb_list_custom_labels, @tx_id}
                    )
    end
  end

  test ".fetch_custom_label" do
    label_id = 1234
    fields = ["name"]

    with_mock Client, [rget: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.fetch_custom_label({@app_id, @page_id}, {label_id, fields}, @tx_id)

      assert called Client.rget(
                      "/#{label_id}",
                      [fields: "name"],
                      {@app_id, @page_id, :mb_fetch_custom_label, @tx_id}
                    )
    end
  end

  test ".create_custom_label" do
    label = %{name: "<LABEL_NAME>"}

    with_mock Client, [rpost: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.create_custom_label({@app_id, @page_id}, label, @tx_id)

      assert called Client.rpost(
                      "/me/custom_labels",
                      label,
                      {@app_id, @page_id, :mb_create_custom_label, @tx_id}
                    )
    end
  end

  test ".delete_custom_label" do
    label_id = 123_456

    with_mock Client, [rdelete: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.delete_custom_label({@app_id, @page_id}, label_id, @tx_id)

      assert called Client.rdelete(
                      "/#{label_id}",
                      %{},
                      {@app_id, @page_id, :mb_delete_custom_label, @tx_id}
                    )
    end
  end

  test ".label_user" do
    label_id = 123_456
    user = %{user: "<PSID>"}

    with_mock Client, [rpost: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.label_user({@app_id, @page_id}, {label_id, user}, @tx_id)

      assert called Client.rpost(
                      "/#{label_id}/label",
                      user,
                      {@app_id, @page_id, :mb_label_user, @tx_id}
                    )
    end
  end

  test ".unlabel_user" do
    label_id = 123_456
    user = %{user: "<PSID>"}

    with_mock Client, [rdelete: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.unlabel_user({@app_id, @page_id}, {label_id, user}, @tx_id)

      assert called Client.rdelete(
                      "/#{label_id}/label",
                      user,
                      {@app_id, @page_id, :mb_unlabel_user, @tx_id}
                    )
    end
  end

  test ".list_custom_labels_of_user with cursor" do
    psid = 1234
    cursor = {:after, "rehsmT"}

    with_mock Client, [rget: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.list_custom_labels_of_user({@app_id, @page_id}, {psid, cursor}, @tx_id)

      assert called Client.rget(
                      "/#{psid}/custom_labels",
                      [after: "rehsmT"],
                      {@app_id, @page_id, :mb_list_custom_labels_of_user, @tx_id}
                    )
    end
  end

  test ".list_custom_labels_of_user without cursor" do
    psid = 1234

    with_mock Client, [rget: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.list_custom_labels_of_user({@app_id, @page_id}, {psid, nil}, @tx_id)

      assert called Client.rget(
                      "/#{psid}/custom_labels",
                      [],
                      {@app_id, @page_id, :mb_list_custom_labels_of_user, @tx_id}
                    )
    end
  end

  test ".pass_thread_control" do
    req = %{}

    with_mock Client, [rpost: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.pass_thread_control({@app_id, @page_id}, req, @tx_id)

      assert called Client.rpost(
                      "/me/pass_thread_control",
                      req,
                      {@app_id, @page_id, :mb_pass_thread_control, @tx_id}
                    )
    end
  end

  test ".take_thread_control" do
    req = %{}

    with_mock Client, [rpost: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.take_thread_control({@app_id, @page_id}, req, @tx_id)

      assert called Client.rpost(
                      "/me/take_thread_control",
                      req,
                      {@app_id, @page_id, :mb_take_thread_control, @tx_id}
                    )
    end
  end

  test ".request_thread_control" do
    req = %{}

    with_mock Client, [rpost: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.request_thread_control({@app_id, @page_id}, req, @tx_id)

      assert called Client.rpost(
                      "/me/request_thread_control",
                      req,
                      {@app_id, @page_id, :mb_request_thread_control, @tx_id}
                    )
    end
  end

  test ".fetch_secondary_receivers" do
    fields = ["id", "name"]

    with_mock Client, [rget: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.fetch_secondary_receivers({@app_id, @page_id}, fields, @tx_id)

      assert called Client.rget(
                      "/me/secondary_receivers",
                      [fields: Enum.join(fields, ",")],
                      {@app_id, @page_id, :mb_fetch_secondary_receivers, @tx_id}
                    )
    end
  end

  test ".fetch_ids_for_page without cursor" do
    proof = "ef07faa3ff57c828ad712a2e30ab18fa57a6ff71fb2981fc5cc86dd599486f67"
    query_params = [page: @page_id, appsecret_proof: proof]

    with_mock Client, [rget: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.fetch_ids_for_page({@app_id, @page_id}, {"124", nil}, @tx_id)

      assert called Client.rget(
                      "/124/ids_for_pages",
                      query_params,
                      {@app_id, @page_id, :mb_id_matching, @tx_id}
                    )
    end
  end

  test ".fetch_ids_for_page with cursor" do
    proof = "ef07faa3ff57c828ad712a2e30ab18fa57a6ff71fb2981fc5cc86dd599486f67"
    cursor = {:after, "rehsmT"}
    query_params = [cursor | [page: @page_id, appsecret_proof: proof]]

    with_mock Client, [rget: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.fetch_ids_for_page({@app_id, @page_id}, {"124", cursor}, @tx_id)

      assert called Client.rget(
                      "/124/ids_for_pages",
                      query_params,
                      {@app_id, @page_id, :mb_id_matching, @tx_id}
                    )
    end
  end

  test ".fetch_ids_for_app without cursor" do
    proof = "f7cab2def83699262071f04ccd757a9985c9ddcef9f7f9aa58b4a64ae9bf8932"
    query_params = [app: @app_id, appsecret_proof: proof, access_token: "ATOKEN123"]

    with_mock Client, [rget: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.fetch_ids_for_app({@app_id, nil}, {"123", nil}, @tx_id)

      assert called Client.rget(
                      "/123/ids_for_apps",
                      query_params,
                      {@app_id, nil, :mb_id_matching, @tx_id}
                    )
    end
  end

  test ".fetch_ids_for_app with cursor" do
    cursor = {:before, "y7mip"}
    proof = "f7cab2def83699262071f04ccd757a9985c9ddcef9f7f9aa58b4a64ae9bf8932"
    params = [app: @app_id, appsecret_proof: proof, access_token: "ATOKEN123"]
    query_params = [cursor | params]

    with_mock Client, [rget: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.fetch_ids_for_app({@app_id, nil}, {"123", cursor}, @tx_id)

      assert called Client.rget(
                      "/123/ids_for_apps",
                      query_params,
                      {@app_id, nil, :mb_id_matching, @tx_id}
                    )
    end
  end

  test ".create_messenger_code" do
    req = %{type: "standard", data: %{ref: "ads"}, image_size: 1000}

    with_mock Client, [rpost: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.create_messenger_code({@app_id, @page_id}, req, @tx_id)

      assert called Client.rpost(
                      "/me/messenger_codes",
                      req,
                      {@app_id, @page_id, :mb_create_messenger_code, @tx_id}
                    )
    end
  end

  test ".fetch_messaging_feature_review" do
    with_mock Client, [rget: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.fetch_messaging_feature_review({@app_id, @page_id}, @tx_id)

      assert called Client.rget(
                      "/me/messaging_feature_review",
                      [],
                      {@app_id, @page_id, :mb_fetch_messaging_feature_review, @tx_id}
                    )
    end
  end

  test ".fetch_insights" do
    metrics = ~w(page_messages_new_conversations_unique page_messages_active_threads_unique)
    since = 0
    until = System.os_time(:second)

    with_mock Client, [rget: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.fetch_insights({@app_id, @page_id}, {metrics, since, until}, @tx_id)

      assert called Client.rget(
                      "/me/insights",
                      [metric: Enum.join(metrics, ","), since: since, until: until],
                      {@app_id, @page_id, :mb_fetch_insights, @tx_id}
                    )
    end
  end

  test ".set_account_linking_url" do
    url = "https://example.com/fb/auth"

    with_mock Client, [rpost: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.set_account_linking_url({@app_id, @page_id}, url, @tx_id)

      assert called Client.rpost(
                      "/me/messenger_profile",
                      %{account_linking_url: url},
                      {@app_id, @page_id, :mb_set_messenger_profile, @tx_id}
                    )
    end
  end

  test ".reset_account_linking_url" do
    with_mock Client, [rdelete: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.reset_account_linking_url({@app_id, @page_id}, @tx_id)

      assert called Client.rdelete(
                      "/me/messenger_profile",
                      %{fields: ["account_linking_url"]},
                      {@app_id, @page_id, :mb_reset_messenger_profile, @tx_id}
                    )
    end
  end

  test ".fetch_account_linking_url" do
    with_mock Client, [rget: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.fetch_account_linking_url({@app_id, @page_id}, @tx_id)

      assert called Client.rget(
                      "/me/messenger_profile",
                      [fields: "account_linking_url"],
                      {@app_id, @page_id, :mb_fetch_messenger_profile, @tx_id}
                    )
    end
  end

  test ".set_get_started" do
    payload = "EXAMPLE_GET_STARTED"

    with_mock Client, [rpost: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.set_get_started({@app_id, @page_id}, payload, @tx_id)

      assert called Client.rpost(
                      "/me/messenger_profile",
                      %{get_started: %{payload: payload}},
                      {@app_id, @page_id, :mb_set_messenger_profile, @tx_id}
                    )
    end
  end

  test ".reset_get_started" do
    with_mock Client, [rdelete: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.reset_get_started({@app_id, @page_id}, @tx_id)

      assert called Client.rdelete(
                      "/me/messenger_profile",
                      %{fields: ["get_started"]},
                      {@app_id, @page_id, :mb_reset_messenger_profile, @tx_id}
                    )
    end
  end

  test ".fetch_get_started" do
    with_mock Client, [rget: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.fetch_get_started({@app_id, @page_id}, @tx_id)

      assert called Client.rget(
                      "/me/messenger_profile",
                      [fields: "get_started"],
                      {@app_id, @page_id, :mb_fetch_messenger_profile, @tx_id}
                    )
    end
  end

  test ".set_greeting" do
    greeting = [%{locale: "default", text: "Hey!"}]

    with_mock Client, [rpost: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.set_greeting({@app_id, @page_id}, greeting, @tx_id)

      assert called Client.rpost(
                      "/me/messenger_profile",
                      %{greeting: greeting},
                      {@app_id, @page_id, :mb_set_messenger_profile, @tx_id}
                    )
    end
  end

  test ".reset_greeting" do
    with_mock Client, [rdelete: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.reset_greeting({@app_id, @page_id}, @tx_id)

      assert called Client.rdelete(
                      "/me/messenger_profile",
                      %{fields: ["greeting"]},
                      {@app_id, @page_id, :mb_reset_messenger_profile, @tx_id}
                    )
    end
  end

  test ".fetch_greeting" do
    with_mock Client, [rget: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.fetch_greeting({@app_id, @page_id}, @tx_id)

      assert called Client.rget(
                      "/me/messenger_profile",
                      [fields: "greeting"],
                      {@app_id, @page_id, :mb_fetch_messenger_profile, @tx_id}
                    )
    end
  end

  test ".set_home_url" do
    home_url = [%{url: "https://..", webview_height_ratio: "tall"}]

    with_mock Client, [rpost: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.set_home_url({@app_id, @page_id}, home_url, @tx_id)

      assert called Client.rpost(
                      "/me/messenger_profile",
                      %{home_url: home_url},
                      {@app_id, @page_id, :mb_set_messenger_profile, @tx_id}
                    )
    end
  end

  test ".reset_home_url" do
    with_mock Client, [rdelete: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.reset_home_url({@app_id, @page_id}, @tx_id)

      assert called Client.rdelete(
                      "/me/messenger_profile",
                      %{fields: ["home_url"]},
                      {@app_id, @page_id, :mb_reset_messenger_profile, @tx_id}
                    )
    end
  end

  test ".fetch_home_url" do
    with_mock Client, [rget: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.fetch_home_url({@app_id, @page_id}, @tx_id)

      assert called Client.rget(
                      "/me/messenger_profile",
                      [fields: "home_url"],
                      {@app_id, @page_id, :mb_fetch_messenger_profile, @tx_id}
                    )
    end
  end

  test ".set_payment_settings" do
    payment_settings = %{}

    with_mock Client, [rpost: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.set_payment_settings({@app_id, @page_id}, payment_settings, @tx_id)

      assert called Client.rpost(
                      "/me/messenger_profile",
                      %{payment_settings: payment_settings},
                      {@app_id, @page_id, :mb_set_messenger_profile, @tx_id}
                    )
    end
  end

  test ".reset_payment_settings" do
    with_mock Client, [rdelete: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.reset_payment_settings({@app_id, @page_id}, @tx_id)

      assert called Client.rdelete(
                      "/me/messenger_profile",
                      %{fields: ["payment_settings"]},
                      {@app_id, @page_id, :mb_reset_messenger_profile, @tx_id}
                    )
    end
  end

  test ".fetch_payment_settings" do
    with_mock Client, [rget: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.fetch_payment_settings({@app_id, @page_id}, @tx_id)

      assert called Client.rget(
                      "/me/messenger_profile",
                      [fields: "payment_settings"],
                      {@app_id, @page_id, :mb_fetch_messenger_profile, @tx_id}
                    )
    end
  end

  test ".set_persistent_menu" do
    persistent_menu = []

    with_mock Client, [rpost: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.set_persistent_menu({@app_id, @page_id}, persistent_menu, @tx_id)

      assert called Client.rpost(
                      "/me/messenger_profile",
                      %{persistent_menu: persistent_menu},
                      {@app_id, @page_id, :mb_set_messenger_profile, @tx_id}
                    )
    end
  end

  test ".reset_persistent_menu" do
    with_mock Client, [rdelete: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.reset_persistent_menu({@app_id, @page_id}, @tx_id)

      assert called Client.rdelete(
                      "/me/messenger_profile",
                      %{fields: ["persistent_menu"]},
                      {@app_id, @page_id, :mb_reset_messenger_profile, @tx_id}
                    )
    end
  end

  test ".fetch_persistent_menu" do
    with_mock Client, [rget: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.fetch_persistent_menu({@app_id, @page_id}, @tx_id)

      assert called Client.rget(
                      "/me/messenger_profile",
                      [fields: "persistent_menu"],
                      {@app_id, @page_id, :mb_fetch_messenger_profile, @tx_id}
                    )
    end
  end

  test ".set_target_audience" do
    target_audience = %{audience_type: "custom", countries: %{whitelist: ["US", "TR"]}}

    with_mock Client, [rpost: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.set_target_audience({@app_id, @page_id}, target_audience, @tx_id)

      assert called Client.rpost(
                      "/me/messenger_profile",
                      %{target_audience: target_audience},
                      {@app_id, @page_id, :mb_set_messenger_profile, @tx_id}
                    )
    end
  end

  test ".reset_target_audience" do
    with_mock Client, [rdelete: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.reset_target_audience({@app_id, @page_id}, @tx_id)

      assert called Client.rdelete(
                      "/me/messenger_profile",
                      %{fields: ["target_audience"]},
                      {@app_id, @page_id, :mb_reset_messenger_profile, @tx_id}
                    )
    end
  end

  test ".fetch_target_audience" do
    with_mock Client, [rget: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.fetch_target_audience({@app_id, @page_id}, @tx_id)

      assert called Client.rget(
                      "/me/messenger_profile",
                      [fields: "target_audience"],
                      {@app_id, @page_id, :mb_fetch_messenger_profile, @tx_id}
                    )
    end
  end

  test ".set_whitelisted_domains" do
    domains = ["https://bit.ly", "https://github.com", "https://hex.pm"]

    with_mock Client, [rpost: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.set_whitelisted_domains({@app_id, @page_id}, domains, @tx_id)

      assert called Client.rpost(
                      "/me/messenger_profile",
                      %{whitelisted_domains: domains},
                      {@app_id, @page_id, :mb_set_messenger_profile, @tx_id}
                    )
    end
  end

  test ".reset_whitelisted_domains" do
    with_mock Client, [rdelete: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.reset_whitelisted_domains({@app_id, @page_id}, @tx_id)

      assert called Client.rdelete(
                      "/me/messenger_profile",
                      %{fields: ["whitelisted_domains"]},
                      {@app_id, @page_id, :mb_reset_messenger_profile, @tx_id}
                    )
    end
  end

  test ".fetch_whitelisted_domains" do
    with_mock Client, [rget: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.fetch_whitelisted_domains({@app_id, @page_id}, @tx_id)

      assert called Client.rget(
                      "/me/messenger_profile",
                      [fields: "whitelisted_domains"],
                      {@app_id, @page_id, :mb_fetch_messenger_profile, @tx_id}
                    )
    end
  end

  test ".send_message" do
    message = %{messaging_type: "RESPONSE", recipient: %{id: "<PSID>"}, message: %{text: "It's me!"}}

    with_mock Client, [rpost: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.send_message({@app_id, @page_id}, message, @tx_id)

      assert called Client.rpost(
                      "/me/messages",
                      message,
                      {@app_id, @page_id, :mb_send_message, @tx_id}
                    )
    end
  end

  test ".unlink_account" do
    req = %{psid: "<PSID>"}

    with_mock Client, [rpost: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.unlink_account({@app_id, @page_id}, req, @tx_id)

      assert called Client.rpost(
                      "/me/unlink_accounts",
                      req,
                      {@app_id, @page_id, :mb_unlink_account, @tx_id}
                    )
    end
  end

  test ".fetch_user_profile" do
    fields = ~w(first_name last_name profile_pic)

    with_mock Client, [rget: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.fetch_user_profile({@app_id, @page_id}, {"<PSID>", fields}, @tx_id)

      assert called Client.rget(
                      "/<PSID>",
                      [fields: Enum.join(fields, ",")],
                      {@app_id, @page_id, :mb_fetch_user_profile, @tx_id}
                    )
    end
  end

  test ".set_nlp_configs" do
    params = %{nlp_enabled: true, custom_token: "<WITAITOKEN>"}

    with_mock Client, [rpost: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.set_nlp_configs({@app_id, @page_id}, params, @tx_id)

      assert called Client.rpost(
                      "/me/nlp_configs",
                      params,
                      {@app_id, @page_id, :mb_set_nlp_configs, @tx_id}
                    )
    end
  end

  test ".subscribe_to_page_webhooks" do
    with_mock Client, [rpost: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.subscribe_to_page_webhooks({@app_id, @page_id}, @tx_id)

      assert called Client.rpost(
                      "/#{@page_id}/subscribed_apps",
                      %{},
                      {@app_id, @page_id, :mb_subscribe_to_page_webhooks, @tx_id}
                    )
    end
  end

  test ".unsubscribe_to_page_webhooks" do
    with_mock Client, [rdelete: fn(_, _, _) -> {:ok, %{}} end] do
      MessengerBot.unsubscribe_to_page_webhooks({@app_id, @page_id}, @tx_id)

      assert called Client.rdelete(
                      "/#{@page_id}/subscribed_apps",
                      %{access_token: "ATOKEN123"},
                      {@app_id, @page_id, :mb_unsubscribe_to_page_webhooks, @tx_id}
                    )
    end
  end
end
