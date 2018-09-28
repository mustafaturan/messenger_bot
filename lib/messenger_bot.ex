defmodule MessengerBot do
  @moduledoc """
  MessengerBot Client
  """

  alias MessengerBot.Client.Base, as: Client
  alias MessengerBot.Config
  alias MessengerBot.Util.Encryption

  @typedoc """
  Facebook App ID
  """
  @type app_id :: String.t()

  @typedoc """
  Facebook Page ID
  """
  @type page_id :: String.t()

  @typedoc """
  User's page-scoped ID or app-scoped ID
  """
  @type psid :: integer() | String.t()

  @typedoc """
  Custom label ID
  """
  @type label_id :: integer() | String.t()

  @typedoc """
  Domain list
  """
  @type domains :: list(String.t())

  @typedoc """
  Metric list
  """
  @type metrics :: list(String.t())

  @typedoc """
  Field list
  """
  @type fields :: list(String.t())

  @typedoc """
  Pagination cursor value from previous calls, can be nil
  """
  @type cursor :: {:after, String.t()} | {:before, String.t()} | {}

  @typedoc """
  Reference for Facebook Page data

  Using page_ref, MessengerBot client access to the page token and app secret
  data from the configuration.
  """
  @type page_ref :: {app_id(), page_id()}

  @typedoc """
  Optional request transaction identifier. This value is passed is passed into
  EventBus Event struct.

  It is usually used to track events in the same transaction. For example;
  when you send batch messages to an audience, you can track which messages
  delivered in the same transaction. Or while setting a Messenger Profile,
  you may need to make series of requests to complete the page setup. You can
  use same tx_id to trace sequential related events.
  """
  @type tx_id :: String.t()

  @typedoc """
  API call execution result

  Successful HTTP requests will return tuple of `:ok` with response body as Map.
  Unsuccessful HTTP requests will return tuple of `:error` with response body as
  Map.

  For HTTP client errors, it will return tuple of `{:error, %{error: reason}}`,
  where `reason` is an error tuple of `Tesla` dependency.
  """
  @type res :: {:ok, map()} | {:error, map()}

  ############################################################################
  # Attachment Upload API                                                    #
  ############################################################################

  @doc """
  Attachment Upload API

  ## Examples

      iex> attachment = %{type: "image", payload: %{url: "...", is_reusable: true}}
      iex> MessengerBot.upload_attachment({"<AppID>", "<PageID>"}, attachment)
      {:ok, %{"attachment_id" => "1857777774821032"}}

  """
  @spec upload_attachment(page_ref(), map(), tx_id() | nil) :: res()
  def upload_attachment({app_id, page_id}, %{} = attachment, tx_id \\ nil) do
    Client.rpost(
      "/me/message_attachments",
      %{message: %{attachment: attachment}},
      {app_id, page_id, :mb_attachment_upload, tx_id}
    )
  end

  ############################################################################
  # Broadcast API                                                            #
  ############################################################################

  @doc """
  Broadcast API / message_creatives

  ## Examples

      iex> messages = [%{}]
      iex> MessengerBot.create_message_creative({"<AppID>", "<PageID>"}, messages)
      {:ok, %{"message_creative_id" => 938461089}}

  """
  @spec create_message_creative(page_ref(), list(map()), tx_id() | nil) :: res()
  def create_message_creative({app_id, page_id}, messages, tx_id \\ nil) do
    Client.rpost(
      "/me/message_creatives",
      %{messages: messages},
      {app_id, page_id, :mb_create_message_creatives, tx_id}
    )
  end

  @doc """
  Broadcast API / broadcast_message

  ## Examples

      iex> message_ref = %{message_creative_id: 938461089}
      iex> MessengerBot.broadcast_message({"<AppID>", "<PageID>"}, message_ref)
      {:ok, %{"broadcast_id" => 827}}

  """
  @spec broadcast_message(page_ref(), map(), tx_id() | nil) :: res()
  def broadcast_message({app_id, page_id}, %{} = message_ref, tx_id \\ nil) do
    Client.rpost(
      "/me/broadcast_messages",
      message_ref,
      {app_id, page_id, :mb_broadcast_message, tx_id}
    )
  end

  @doc """
  Broadcast API / list_custom_labels

  ## Examples

      iex> cursor = {:after, "QVFIUmItNkpTbjVzakxFWGRy"}
      iex> fields = ~w(id name)
      iex> MessengerBot.list_custom_labels({"<AppID>", "<PageID>"}, {fields, cursor})
      {:ok, %{"data" => [], "paging" => {"cursors" => {"after" => "<>", "before" => "<>"}}}}

  """
  @spec list_custom_labels(page_ref(), {fields(), cursor()}, tx_id() | nil) :: res()
  def list_custom_labels({app_id, page_id}, {fields, cursor}, tx_id \\ nil) do
    params = [fields: Enum.join(fields, ",")]
    query_params = if is_nil(cursor), do: params, else: [cursor | params]

    Client.rget(
      "/me/custom_labels",
      query_params,
      {app_id, page_id, :mb_list_custom_labels, tx_id}
    )
  end

  @doc """
  Broadcast API / fetch_custom_label

  ## Examples

      iex> label_id = 1712444532121303
      iex> fields = ~w(name)
      iex> MessengerBot.fetch_custom_label({"<AppID>", "<PageID>"}, {label_id, fields})
      {:ok, %{"name" => "myLabel", "id" => "1001200005002"}}

  """
  @spec fetch_custom_label(page_ref(), {label_id(), list()}, tx_id() | nil) :: res()
  def fetch_custom_label({app_id, page_id}, {label_id, fields}, tx_id \\ nil) do
    Client.rget(
      "/#{label_id}",
      [fields: Enum.join(fields, ",")],
      {app_id, page_id, :mb_fetch_custom_label, tx_id}
    )
  end

  @doc """
  Broadcast API / custom_labels

  ## Examples

      iex> label = %{name: "<LABEL_NAME>"}
      iex> MessengerBot.create_custom_label({"<AppID>", "<PageID>"}, label)
      {:ok, %{"id" => 1712444532121303}}

  """
  @spec create_custom_label(page_ref(), map(), tx_id() | nil) :: res()
  def create_custom_label({app_id, page_id}, %{} = label, tx_id \\ nil) do
    Client.rpost(
      "/me/custom_labels",
      label,
      {app_id, page_id, :mb_create_custom_label, tx_id}
    )
  end

  @doc """
  Broadcast API / delete_custom_label

  ## Examples

      iex> label_id = 1712444532121303
      iex> MessengerBot.delete_custom_label({"<AppID>", "<PageID>"}, label_id)
      {:ok, %{"success" => true}}

  """
  @spec delete_custom_label(page_ref(), label_id(), tx_id() | nil) :: res()
  def delete_custom_label({app_id, page_id}, label_id, tx_id \\ nil) do
    Client.rdelete(
      "/#{label_id}",
      %{},
      {app_id, page_id, :mb_delete_custom_label, tx_id}
    )
  end

  @doc """
  Broadcast API / label_user

  ## Examples

      iex> label_id = 1712444532121303
      iex> user = %{user: "<PSID>"}
      iex> MessengerBot.label_user({"<AppID>", "<PageID>"}, {label_id, user})
      {:ok, %{"success" => true}}

  """
  @spec label_user(page_ref(), {integer(), map()}, tx_id() | nil) :: res()
  def label_user({app_id, page_id}, {label_id, %{} = user}, tx_id \\ nil) do
    Client.rpost(
      "/#{label_id}/label",
      user,
      {app_id, page_id, :mb_label_user, tx_id}
    )
  end

  @doc """
  Broadcast API / unlabel_user

  ## Examples

      iex> label_id = 1712444532121303
      iex> user = %{user: "<PSID>"}
      iex> MessengerBot.unlabel_user({"<AppID>", "<PageID>"}, {label_id, user})
      {:ok, %{"success" => true}}

  """
  @spec unlabel_user(page_ref(), {integer(), map()}, tx_id() | nil) :: res()
  def unlabel_user({app_id, page_id}, {label_id, %{} = user}, tx_id \\ nil) do
    Client.rdelete(
      "/#{label_id}/label",
      user,
      {app_id, page_id, :mb_unlabel_user, tx_id}
    )
  end

  @doc """
  Broadcast API / list_custom_labels_of_user

  ## Examples

      iex> cursor = {:after, "QVFIUmItNkpTbjVzakxFWGRy"}
      iex> fields = ~w(id name)
      iex> MessengerBot.list_custom_labels_of_user({"<AppID>", "<PageID>"}, {fields, cursor})
      {:ok, %{"data" => [], "paging" => {"cursors" => {"after" => "<>", "before" => "<>"}}}}

  """
  @spec list_custom_labels_of_user(page_ref(), {psid(), cursor()}, tx_id() | nil) :: res()
  def list_custom_labels_of_user({app_id, page_id}, {psid, cursor}, tx_id \\ nil) do
    query_params = if is_nil(cursor), do: [], else: [cursor]

    Client.rget(
      "/#{psid}/custom_labels",
      query_params,
      {app_id, page_id, :mb_list_custom_labels_of_user, tx_id}
    )
  end

  ############################################################################
  # Handover Protocol API                                                    #
  ############################################################################

  @doc """
  Handover Protocol API / pass_thread_control
  """
  @spec pass_thread_control(page_ref(), map(), tx_id() | nil) :: res()
  def pass_thread_control({app_id, page_id}, %{} = req, tx_id \\ nil) do
    Client.rpost(
      "/me/pass_thread_control",
      req,
      {app_id, page_id, :mb_pass_thread_control, tx_id}
    )
  end

  @doc """
  Handover Protocol API / take_thread_control
  """
  @spec take_thread_control(page_ref(), map(), tx_id() | nil) :: res()
  def take_thread_control({app_id, page_id}, %{} = req, tx_id \\ nil) do
    Client.rpost(
      "/me/take_thread_control",
      req,
      {app_id, page_id, :mb_take_thread_control, tx_id}
    )
  end

  @doc """
  Handover Protocol API / request_thread_control
  """
  @spec request_thread_control(page_ref(), map(), tx_id() | nil) :: res()
  def request_thread_control({app_id, page_id}, %{} = req, tx_id \\ nil) do
    Client.rpost(
      "/me/request_thread_control",
      req,
      {app_id, page_id, :mb_request_thread_control, tx_id}
    )
  end

  @doc """
  Handover Protocol API / secondary_receivers
  """
  @spec fetch_secondary_receivers(page_ref(), fields(), tx_id() | nil) :: res()
  def fetch_secondary_receivers({app_id, page_id}, fields, tx_id \\ nil) do
    Client.rget(
      "/me/secondary_receivers",
      [fields: Enum.join(fields, ",")],
      {app_id, page_id, :mb_fetch_secondary_receivers, tx_id}
    )
  end

  ############################################################################
  # ID Matching API                                                          #
  ############################################################################

  @doc """
  ID Matching API / ids_for_page

  ## Examples

      iex> psid = 1234567890
      iex> cursor = nil
      iex> MessengerBot.fetch_ids_for_page({"<AppID>", "<PageID>"}, {psid, cursor})
      {:ok, %{"data" => [%{"id" => "1429374444444138", }], "paging" => %{}}}

  """
  @spec fetch_ids_for_page(page_ref(), {psid(), cursor()}, tx_id() | nil) :: res()
  def fetch_ids_for_page({app_id, page_id}, {psid, cursor}, tx_id \\ nil) do
    params = [
      page: page_id,
      appsecret_proof: app_secret_proof({app_id, page_id})
    ]
    query_params = if is_nil(cursor), do: params, else: [cursor | params]

    Client.rget(
      "/#{psid}/ids_for_pages",
      query_params,
      {app_id, page_id, :mb_id_matching, tx_id}
    )
  end

  @doc """
  ID Matching API / ids_for_app

  ## Examples

      iex> psid = 1234567890
      iex> cursor = {:after, "NjgyNDk4MTcxOTQzMTY1"}
      iex> MessengerBot.fetch_ids_for_app({"<AppID>", nil}, {psid, cursor})
      {:ok, %{"data" => [%{"id" => "1429374444444138", }], "paging" => %{}}}

  """
  @spec fetch_ids_for_app({app_id, any()}, {psid(), cursor()}, tx_id() | nil) :: res()
  def fetch_ids_for_app({app_id, _}, {psid, cursor}, tx_id \\ nil) do
    params = [
      app: app_id,
      appsecret_proof: app_secret_proof({app_id}),
      access_token: Config.app_access_token(app_id)
    ]
    query_params = if is_nil(cursor), do: params, else: [cursor | params]

    Client.rget(
      "/#{psid}/ids_for_apps",
      query_params,
      {app_id, nil, :mb_id_matching, tx_id}
    )
  end

  ############################################################################
  # Messenger Code API                                                       #
  ############################################################################

  @doc """
  Messenger Code API

  ## Examples

      iex> req = %{type: "standard", data: %{ref: "ads"}, image_size: 1000}
      iex> MessengerBot.create_messenger_code({"<AppID>", "<PageID>"}, req)
      {:ok, %{"uri" => "..."}}

  """
  @spec create_messenger_code(page_ref(), map(), tx_id() | nil) :: res()
  def create_messenger_code({app_id, page_id}, %{} = req, tx_id \\ nil) do
    Client.rpost(
      "/me/messenger_codes",
      req,
      {app_id, page_id, :mb_create_messenger_code, tx_id}
    )
  end

  ############################################################################
  # Messaging Feature Review API                                             #
  ############################################################################

  @doc """
  Messaging Feature Review API

  ## Examples

      iex> MessengerBot.fetch_messaging_feature_review({"<AppID>", "<PageID>"})
      {:ok, %{"data" => [%{feature: "...", status: "..."}, ]}}

  """
  @spec fetch_messaging_feature_review(page_ref(), tx_id() | nil) :: res()
  def fetch_messaging_feature_review({app_id, page_id}, tx_id \\ nil) do
    Client.rget(
      "/me/messaging_feature_review",
      [],
      {app_id, page_id, :mb_fetch_messaging_feature_review, tx_id}
    )
  end

  ############################################################################
  # Messenger Insights API                                                   #
  ############################################################################

  @doc """
  Insights API

  ## Examples

      iex> metrics = ~w(page_messages_new_conversations_unique page_messages_active_threads_unique)
      iex> MessengerBot.fetch_insights({"<AppID>", "<PageID>"}, {metrics, nil, nil})
      {:ok, %{"data" => [%{name: "...", period: "day", values: []}, ]}}

  """
  @spec fetch_insights(page_ref(), {metrics(), integer(), integer()}, tx_id() | nil) :: res()
  def fetch_insights({app_id, page_id}, {metrics, since, until}, tx_id \\ nil) do
    Client.rget(
      "/me/insights",
      [metric: Enum.join(metrics, ","), since: since, until: until],
      {app_id, page_id, :mb_fetch_insights, tx_id}
    )
  end

  ############################################################################
  # Messenger Profile API                                                    #
  ############################################################################

  @doc """
  Messenger Profile API / Set account linking url

  ## Examples

      iex> url = "https://example.com/fb/auth"
      iex> MessengerBot.set_account_linking_url({"<AppID>", "<PageID>"}, url)
      {:ok, %{"result" => "success"}}

  """
  @spec set_account_linking_url(page_ref(), String.t(), tx_id() | nil) :: res()
  def set_account_linking_url({app_id, page_id}, account_linking_url, tx_id \\ nil) do
    Client.rpost(
      "/me/messenger_profile",
      %{account_linking_url: account_linking_url},
      {app_id, page_id, :mb_set_messenger_profile, tx_id}
    )
  end

  @doc """
  Messenger Profile API / Reset account linking url

  ## Examples

      iex> MessengerBot.reset_account_linking_url({"<AppID>", "<PageID>"})
      {:ok, %{"result" => "success"}}

  """
  @spec reset_account_linking_url(page_ref(), tx_id() | nil) :: res()
  def reset_account_linking_url({app_id, page_id}, tx_id \\ nil) do
    Client.rdelete(
      "/me/messenger_profile",
      %{fields: ["account_linking_url"]},
      {app_id, page_id, :mb_reset_messenger_profile, tx_id}
    )
  end

  @doc """
  Messenger Profile API / Fetch account linking url

  ## Examples

      iex> MessengerBot.fetch_account_linking_url({"<AppID>", "<PageID>"})
      {:ok, %{"data" => [%{"account_linking_url" => "https://..."}]}}

  """
  @spec fetch_account_linking_url(page_ref(), tx_id() | nil) :: res()
  def fetch_account_linking_url({app_id, page_id}, tx_id \\ nil) do
    Client.rget(
      "/me/messenger_profile",
      [fields: "account_linking_url"],
      {app_id, page_id, :mb_fetch_messenger_profile, tx_id}
    )
  end

  @doc """
  Messenger Profile API / Set get started

  ## Examples

      iex> payload = "GET_STARTED"
      iex> MessengerBot.set_get_started({"<AppID>", "<PageID>", payload})
      {:ok, %{"result" => "success"}}

      iex> MessengerBot.set_get_started({"<AppID>", "<PageID>"}, "JUST_STARTED")
      {:ok, %{"result" => "success"}}

  """
  @spec set_get_started(page_ref(), tx_id() | nil) :: res()
  def set_get_started({app_id, page_id}, payload \\ "GET_STARTED", tx_id \\ nil) do
    Client.rpost(
      "/me/messenger_profile",
      %{get_started: %{payload: payload}},
      {app_id, page_id, :mb_set_messenger_profile, tx_id}
    )
  end

  @doc """
  Messenger Profile API / Reset get started

  ## Examples

      iex> MessengerBot.reset_get_started({"<AppID>", "<PageID>"})
      {:ok, %{"result" => "success"}}

  """
  @spec reset_get_started(page_ref(), tx_id() | nil) :: res()
  def reset_get_started({app_id, page_id}, tx_id \\ nil) do
    Client.rdelete(
      "/me/messenger_profile",
      %{fields: ["get_started"]},
      {app_id, page_id, :mb_reset_messenger_profile, tx_id}
    )
  end

  @doc """
  Messenger Profile API / Fetch get started

  ## Examples

      iex> MessengerBot.fetch_get_started({"<AppID>", "<PageID>"})
      {:ok, %{"data" => [%{"get_started" => %{"payload" => "..."}}]}}

  """
  @spec fetch_get_started(page_ref(), tx_id() | nil) :: res()
  def fetch_get_started({app_id, page_id}, tx_id \\ nil) do
    Client.rget(
      "/me/messenger_profile",
      [fields: "get_started"],
      {app_id, page_id, :mb_fetch_messenger_profile, tx_id}
    )
  end

  @doc """
  Messenger Profile API / Set greeting

  ## Examples

      iex> greeting = [%{locale: "default", text: "Hey!"}]
      iex> MessengerBot.set_greeting({"<AppID>", "<PageID>"}, greeting)
      {:ok, %{"result" => "success"}}

  """
  @spec set_greeting(page_ref(), list(map()), tx_id() | nil) :: res()
  def set_greeting({app_id, page_id}, greeting, tx_id \\ nil) do
    Client.rpost(
      "/me/messenger_profile",
      %{greeting: greeting},
      {app_id, page_id, :mb_set_messenger_profile, tx_id}
    )
  end

  @doc """
  Messenger Profile API / Reset greeting

  ## Examples

      iex> MessengerBot.reset_greeting({"<AppID>", "<PageID>"})
      {:ok, %{"result" => "success"}}

  """
  @spec reset_greeting(page_ref(), tx_id() | nil) :: res()
  def reset_greeting({app_id, page_id}, tx_id \\ nil) do
    Client.rdelete(
      "/me/messenger_profile",
      %{fields: ["greeting"]},
      {app_id, page_id, :mb_reset_messenger_profile, tx_id}
    )
  end

  @doc """
  Messenger Profile API / Fetch greeting

  ## Examples

      iex> MessengerBot.fetch_greeting({"<AppID>", "<PageID>"})
      {:ok, %{"data" => [%{"greeting" => [%{}]}]}}

  """
  @spec fetch_greeting(page_ref(), tx_id() | nil) :: res()
  def fetch_greeting({app_id, page_id}, tx_id \\ nil) do
    Client.rget(
      "/me/messenger_profile",
      [fields: "greeting"],
      {app_id, page_id, :mb_fetch_messenger_profile, tx_id}
    )
  end

  @doc """
  Messenger Profile API / Set home url

  ## Examples

      iex> home_url = %{url: "htt..", webview_height_ratio: "tall"}
      iex> MessengerBot.set_home_url({"<AppID>", "<PageID>"}, home_url)
      {:ok, %{"result" => "success"}}

  """
  @spec set_home_url(page_ref(), map(), tx_id() | nil) :: res()
  def set_home_url({app_id, page_id}, home_url, tx_id \\ nil) do
    Client.rpost(
      "/me/messenger_profile",
      %{home_url: home_url},
      {app_id, page_id, :mb_set_messenger_profile, tx_id}
    )
  end

  @doc """
  Messenger Profile API / Reset home url

  ## Examples

      iex> MessengerBot.reset_home_url({"<AppID>", "<PageID>"})
      {:ok, %{"result" => "success"}}

  """
  @spec reset_home_url(page_ref(), tx_id() | nil) :: res()
  def reset_home_url({app_id, page_id}, tx_id \\ nil) do
    Client.rdelete(
      "/me/messenger_profile",
      %{fields: ["home_url"]},
      {app_id, page_id, :mb_reset_messenger_profile, tx_id}
    )
  end

  @doc """
  Messenger Profile API / Fetch home url

  ## Examples

      iex> MessengerBot.fetch_home_url({"<AppID>", "<PageID>"})
      {:ok, %{"data" => [%{"home_url" => %{}}]}}

  """
  @spec fetch_home_url(page_ref(), tx_id() | nil) :: res()
  def fetch_home_url({app_id, page_id}, tx_id \\ nil) do
    Client.rget(
      "/me/messenger_profile",
      [fields: "home_url"],
      {app_id, page_id, :mb_fetch_messenger_profile, tx_id}
    )
  end

  @doc """
  Messenger Profile API / Set payment_settings
  """
  @spec set_payment_settings(page_ref(), map(), tx_id() | nil) :: res()
  def set_payment_settings({app_id, page_id}, payment_settings, tx_id \\ nil) do
    Client.rpost(
      "/me/messenger_profile",
      %{payment_settings: payment_settings},
      {app_id, page_id, :mb_set_messenger_profile, tx_id}
    )
  end

  @doc """
  Messenger Profile API / Reset payment settings

  ## Examples

      iex> MessengerBot.reset_payment_settings({"<AppID>", "<PageID>"})
      {:ok, %{"result" => "success"}}

  """
  @spec reset_payment_settings(page_ref(), tx_id() | nil) :: res()
  def reset_payment_settings({app_id, page_id}, tx_id \\ nil) do
    Client.rdelete(
      "/me/messenger_profile",
      %{fields: ["payment_settings"]},
      {app_id, page_id, :mb_reset_messenger_profile, tx_id}
    )
  end

  @doc """
  Messenger Profile API / Fetch payment settings

  ## Examples

      iex> MessengerBot.fetch_payment_settings({"<AppID>", "<PageID>"})
      {:ok, %{"data" => [%{"payment_settings" => %{}}]}}

  """
  @spec fetch_payment_settings(page_ref(), tx_id() | nil) :: res()
  def fetch_payment_settings({app_id, page_id}, tx_id \\ nil) do
    Client.rget(
      "/me/messenger_profile",
      [fields: "payment_settings"],
      {app_id, page_id, :mb_fetch_messenger_profile, tx_id}
    )
  end

  @doc """
  Messenger Profile API / Set persistent menu

  ## Examples

      iex> menu = []
      iex> MessengerBot.set_persistent_menu({"<AppID>", "<PageID>"}, menu)
      {:ok, %{"result" => "success"}}

  """
  @spec set_persistent_menu(page_ref(), list(), tx_id() | nil) :: res()
  def set_persistent_menu({app_id, page_id}, persistent_menu, tx_id \\ nil) do
    Client.rpost(
      "/me/messenger_profile",
      %{persistent_menu: persistent_menu},
      {app_id, page_id, :mb_set_messenger_profile, tx_id}
    )
  end

  @doc """
  Messenger Profile API / Reset persistent menu

  ## Examples

      iex> MessengerBot.reset_persistent_menu({"<AppID>", "<PageID>"})
      {:ok, %{"result" => "success"}}

  """
  @spec reset_persistent_menu(page_ref(), tx_id() | nil) :: res()
  def reset_persistent_menu({app_id, page_id}, tx_id \\ nil) do
    Client.rdelete(
      "/me/messenger_profile",
      %{fields: ["persistent_menu"]},
      {app_id, page_id, :mb_reset_messenger_profile, tx_id}
    )
  end

  @doc """
  Messenger Profile API / Fetch persistent menu

  ## Examples

      iex> MessengerBot.fetch_persistent_menu({"<AppID>", "<PageID>"})
      {:ok, %{"data" => [%{"persistent_menu" => [%{}, %{}]}]}}

  """
  @spec fetch_persistent_menu(page_ref(), tx_id() | nil) :: res()
  def fetch_persistent_menu({app_id, page_id}, tx_id \\ nil) do
    Client.rget(
      "/me/messenger_profile",
      [fields: "persistent_menu"],
      {app_id, page_id, :mb_fetch_messenger_profile, tx_id}
    )
  end

  @doc """
  Messenger Profile API / Set target audience

  ## Examples

      iex> audience = %{audience_type: "custom", countries: %{whitelist: ["US", "TR"]}}
      iex> MessengerBot.set_target_audience({"<AppID>", "<PageID>"}, audience)
      {:ok, %{"result" => "success"}}

  """
  @spec set_target_audience(page_ref(), map(), tx_id() | nil) :: res()
  def set_target_audience({app_id, page_id}, target_audience, tx_id \\ nil) do
    Client.rpost(
      "/me/messenger_profile",
      %{target_audience: target_audience},
      {app_id, page_id, :mb_set_messenger_profile, tx_id}
    )
  end

  @doc """
  Messenger Profile API / Reset target audience

  ## Examples

      iex> MessengerBot.reset_target_audience({"<AppID>", "<PageID>"})
      {:ok, %{"result" => "success"}}

  """
  @spec reset_target_audience(page_ref(), tx_id() | nil) :: res()
  def reset_target_audience({app_id, page_id}, tx_id \\ nil) do
    Client.rdelete(
      "/me/messenger_profile",
      %{fields: ["target_audience"]},
      {app_id, page_id, :mb_reset_messenger_profile, tx_id}
    )
  end

  @doc """
  Messenger Profile API / Fetch target audience

  ## Examples

      iex> MessengerBot.fetch_target_audience({"<AppID>", "<PageID>"})
      {:ok, %{"data" => [%{"target_audience" => %{}}]}}

  """
  @spec fetch_target_audience(page_ref(), tx_id() | nil) :: res()
  def fetch_target_audience({app_id, page_id}, tx_id \\ nil) do
    Client.rget(
      "/me/messenger_profile",
      [fields: "target_audience"],
      {app_id, page_id, :mb_fetch_messenger_profile, tx_id}
    )
  end

  @doc """
  Messenger Profile API / Set whitelisted domains

  ## Examples

      iex> domains = ["https://bit.ly/", "https://github.com"]
      iex> MessengerBot.set_whitelisted_domains({"<AppID>", "<PageID>"}, domains)
      {:ok, %{"result" => "success"}}

  """
  @spec set_whitelisted_domains(page_ref(), domains(), tx_id() | nil) :: res()
  def set_whitelisted_domains({app_id, page_id}, whitelisted_domains, tx_id \\ nil) do
    Client.rpost(
      "/me/messenger_profile",
      %{whitelisted_domains: whitelisted_domains},
      {app_id, page_id, :mb_set_messenger_profile, tx_id}
    )
  end

  @doc """
  Messenger Profile API / Reset whitelisted domains

  ## Examples

      iex> MessengerBot.reset_whitelisted_domains({"<AppID>", "<PageID>"})
      {:ok, %{"result" => "success"}}

  """
  @spec reset_whitelisted_domains(page_ref(), tx_id() | nil) :: res()
  def reset_whitelisted_domains({app_id, page_id}, tx_id \\ nil) do
    Client.rdelete(
      "/me/messenger_profile",
      %{fields: ["whitelisted_domains"]},
      {app_id, page_id, :mb_reset_messenger_profile, tx_id}
    )
  end

  @doc """
  Messenger Profile API / Fetch whitelisted domains

  ## Examples

      iex> MessengerBot.fetch_whitelisted_domains({"<AppID>", "<PageID>"})
      {:ok, %{"data" => [%{"whitelisted_domains" => ["https://bit.ly/", ]}]}}

  """
  @spec fetch_whitelisted_domains(page_ref(), tx_id() | nil) :: res()
  def fetch_whitelisted_domains({app_id, page_id}, tx_id \\ nil) do
    Client.rget(
      "/me/messenger_profile",
      [fields: "whitelisted_domains"],
      {app_id, page_id, :mb_fetch_messenger_profile, tx_id}
    )
  end

  ############################################################################
  # Send API                                                                 #
  ############################################################################

  @doc """
  Send API

  Please refer to platform documentation for message types and payloads:
  https://developers.facebook.com/docs/messenger-platform/reference/send-api/

  ## Examples

      iex> req = %{messaging_type: "...", recipient: %{id: "12"}, message: %{text: "hi!"}}
      iex> MessengerBot.send_message({"<AppID>", "<PageID>"}, req)
      {:ok, %{recipient_id" => "12", "message_id" => "mid..."}}

  """
  @spec send_message(page_ref(), map(), tx_id() | nil) :: res()
  def send_message({app_id, page_id}, %{} = req, tx_id \\ nil) do
    Client.rpost(
      "/me/messages",
      req,
      {app_id, page_id, :mb_send_message, tx_id}
    )
  end

  ############################################################################
  # Unlink Account API                                                       #
  ############################################################################

  @doc """
  Account Linking API / unlink_accounts

  ## Examples

      iex> req = %{psid: "PSID"}
      iex> MessengerBot.unlink_account({"<AppID>", "<PageID>"}, req)
      {:ok, %{"result" => "unlink account success"}}

  """
  @spec unlink_account(page_ref(), map(), tx_id() | nil) :: res()
  def unlink_account({app_id, page_id}, %{} = req, tx_id \\ nil) do
    Client.rpost(
      "/me/unlink_accounts",
      req,
      {app_id, page_id, :mb_unlink_account, tx_id}
    )
  end

  ############################################################################
  # User Profile API                                                         #
  ############################################################################

  @doc """
  User Profile API / user_profiles

  ## Examples

      iex> psid = 1234567890
      iex> fields = ~w(first_name last_name profile_pic locale timezone gender)
      iex> MessengerBot.fetch_user_profile({"<AppID>", "<PageID>"}, {psid, fields})
      {:ok, %{"first_name" => "...", "last_name" => "...", }}

  """
  @spec fetch_user_profile(page_ref(), {psid(), fields()}, tx_id() | nil) :: res()
  def fetch_user_profile({app_id, page_id}, {psid, fields}, tx_id \\ nil) do
    Client.rget(
      "/#{psid}",
      [fields: Enum.join(fields, ",")],
      {app_id, page_id, :mb_fetch_user_profile, tx_id}
    )
  end

  ############################################################################
  # NLP Configs API                                                          #
  ############################################################################

  @doc """
  NLP Configs API / nlp_configs

  ## Examples

      iex> params = %{nlp_enabled: true, custom_token: "<WITAITOKEN>"}
      iex> MessengerBot.set_nlp_configs({"<AppID>", "<PageID>"}, params)
      {:ok, %{"success" => true}}

  """
  @spec set_nlp_configs(page_ref(), map(), tx_id() | nil) :: res()
  def set_nlp_configs({app_id, page_id}, params, tx_id \\ nil) do
    Client.rpost(
      "/me/nlp_configs",
      params,
      {app_id, page_id, :mb_set_nlp_configs, tx_id}
    )
  end

  ############################################################################
  # Subscribed Apps API                                                      #
  ############################################################################

  @doc """
  Subscribed Apps API / create subscribed_apps

  ## Examples

      iex> MessengerBot.subscribe_to_page_webhooks({"<AppID>", "<PageID>"})
      {:ok, %{"success" => true}}

  """
  @spec subscribe_to_page_webhooks(page_ref(), tx_id() | nil) :: res()
  def subscribe_to_page_webhooks({app_id, page_id}, tx_id \\ nil) do
    Client.rpost(
      "/#{page_id}/subscribed_apps",
      %{},
      {app_id, page_id, :mb_subscribe_to_page_webhooks, tx_id}
    )
  end

  @doc """
  Subscribed Apps API / delete subscribed_apps

  ## Examples

      iex> MessengerBot.unsubscribe_to_page_webhooks({"<AppID>", "<PageID>"})
      {:ok, %{"success" => true}}

  """
  @spec unsubscribe_to_page_webhooks(page_ref(), tx_id() | nil) :: res()
  def unsubscribe_to_page_webhooks({app_id, page_id}, tx_id \\ nil) do
    Client.rdelete(
      "/#{page_id}/subscribed_apps",
      %{},
      {app_id, page_id, :mb_unsubscribe_to_page_webhooks, tx_id}
    )
  end

  ############################################################################
  # PRIVATE                                                                  #
  ############################################################################

  defp app_secret_proof({app_id, page_id}) do
    page_access_token = Config.page_access_token(app_id, page_id)
    app_secret = Config.app_secret(app_id)
    Encryption.calculate_sha256(app_secret, page_access_token)
  end

  defp app_secret_proof({app_id}) do
    app_access_token = Config.app_access_token(app_id)
    app_secret = Config.app_secret(app_id)
    Encryption.calculate_sha256(app_secret, app_access_token)
  end
end
