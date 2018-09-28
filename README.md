# MessengerBot

[![Build Status](https://travis-ci.org/mustafaturan/messenger_bot.svg?branch=master)](https://travis-ci.org/mustafaturan/messenger_bot)
[![Hex.pm](https://img.shields.io/hexpm/v/messenger_bot.svg)](http://hex.pm/packages/messenger_bot)
[![Hex.pm](https://img.shields.io/hexpm/dt/messenger_bot.svg)](https://hex.pm/packages/messenger_bot)
[![Hex.pm](https://img.shields.io/hexpm/dw/messenger_bot.svg)](https://hex.pm/packages/messenger_bot)
[![codecov](https://codecov.io/gh/musafaturan/messenger_bot/branch/master/graph/badge.svg)](https://codecov.io/gh/mustafaturan/messenger_bot)
[![Inline docs](http://inch-ci.org/github/mustafaturan/messenger_bot.svg)](http://inch-ci.org/github/mustafaturan/messenger_bot)

Unofficial Facebook Messenger Platform *chatbot client* and *webhook handler*

MessengerBot covers majority of the functions to make calls to Facebook Messenger Platform endpoints.

MessengerBot library is designed for processing webhook events coming from Facebook with an event driven approach. It allows any number of subscribers to process same data without blocking.

## Installation

The package can be installed by adding `messenger_bot` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:messenger_bot, "1.2.0"}]
end
```

## Configuration

### Facebook Messenger App and Page configurations

`App` and `Page` configurations can be done via `config.exs` and `MessengerBot.Config` module. Basic idea is to store apps and pages are type of `MessengerBot.Model.{App, Page}` types.

If you are using the app for a single page, `config.exs` seems to be right place but if you need to load app info from an external source, then use module functions to save your apps.

*Note:* `App` and `Page` keys must be atom() type like in the examples. For `config.exs` you can add apps and pages like below:

```elixir
config :messenger_bot,
  pages: %{
    "1881" => %{
      "1234" => %{
        id: "1234",
        name: "Demo Facebook Messenger Bot",
        access_token: "accesstokenforpage"
      }
    }
  },
  apps: %{
    "1881" => %{
      id: "1881",
      secret: "SECRET",
      setup_token: "Setup Token",
      access_token: "ATOKEN123"
    }
  }
```

Any time after loading `messenger_bot`, you can add more pages for an app.

```elixir
pages = %{
  "1234" => %{
    id: "1234",
    name: "Demo Facebook Messenger Bot",
    token: "accesstokenforpage"
  },
  "1298" => %{
    id: "1298",
    name: "Demo Facebook Messenger Bot 1298",
    token: "accesstokenforpagefor1298"
  }
}

# Update configurations
MessengerBot.Config.save_pages(app_id, pages)
```

Details: https://hexdocs.pm/messenger_bot/1.0.0-beta10/MessengerBot.Config.html#save_pages/2

Any time after loading `messenger_bot`, you can save apps too.

```elixir
apps = %{
  "1881" => %{
    id: "1881",
    secret: "SECRET",
    setup_token: "Setup Token",
    access_token: "ATOKEN123"
  }
}

# Update configurations
MessengerBot.Config.save_apps(apps)
```

Details: https://hexdocs.pm/messenger_bot/1.0.0-beta10/MessengerBot.Config.html#save_apps/1

### Facebook App setup configuration

Add webhook endpoints to your router:

```elixir
forward "/some-path-for-messenger_bot", to: MessengerBot.Web.Router

# The code above will add following routes
# -> GET   /some-path-for-messenger_bot/:app_id (Possible HTTP status codes: 200, 401, 404, 422, 500)
# -> POST  /some-path-for-messenger_bot/:app_id (Possible HTTP status codes: 200, 401, 404, 422, 500)
# -> MATCH /some-path-for-messenger_bot/:any (Possible HTTP status code: 404)
```

### EventBus Configuration

Update your `config.exs` to add `messenger_bot` event topics and id generator for `event_bus`:

```elixir
config :event_bus,
  ttl: 900_000_000,
  time_unit: :microsecond,
  id_generator: MessengerBot.Util.String,
  topics: [
    ##########################################################################
    # Webserver Topics
    ##########################################################################
    :mb_webserv_succeeded,
    :mb_webserv_payload_failed,
    :mb_webserv_erred,
    ##########################################################################
    # Webhook Topics
    ##########################################################################
    :mb_delivery_received,
    :mb_read_received,
    :mb_message_echo_received,
    :mb_message_attachments_received,
    :mb_message_quick_reply_received,
    :mb_message_received,
    :mb_optin_received,
    :mb_postback_received,
    :mb_referral_received,
    :mb_game_play_received,
    :mb_payment_received,
    :mb_checkout_update_received,
    :mb_pre_checkout_received,
    :mb_account_linking_received,
    :mb_policy_enforcement_received,
    :mb_app_roles_received,
    :mb_standby_received,
    :mb_pass_thread_control_received,
    :mb_take_thread_control_received,
    :mb_request_thread_control_received,
    :mb_na_received,
    :mb_app_setup_succeeded,
    :mb_app_setup_failed,
    ##########################################################################
    # Client Request Topics
    ##########################################################################
    :mb_attachment_upload_succeeded,
    :mb_create_message_creatives_succeeded,
    :mb_broadcast_message_succeeded,
    :mb_list_custom_labels_succeeded,
    :mb_fetch_custom_label_succeeded,
    :mb_delete_custom_label_succeeded,
    :mb_label_user_succeeded,
    :mb_unlabel_user_succeeded,
    :mb_list_custom_labels_of_user_succeeded,
    :mb_pass_thread_control_succeeded,
    :mb_take_thread_control_succeeded,
    :mb_request_thread_control_succeeded,
    :mb_fetch_secondary_receivers_succeeded,
    :mb_id_matching_succeeded,
    :mb_create_messenger_code_succeeded,
    :mb_fetch_messaging_feature_review_succeeded,
    :mb_fetch_insights_succeeded,
    :mb_set_messenger_profile_succeeded,
    :mb_reset_messenger_profile_succeeded,
    :mb_fetch_messenger_profile_succeeded,
    :mb_send_message_succeeded,
    :mb_unlink_account_succeeded,
    :mb_fetch_user_profile_succeeded,
    :mb_set_nlp_configs_succeeded,
    :mb_subscribe_to_page_webhooks_succeeded,
    :mb_unsubscribe_to_page_webhooks_succeeded,
    ##########################################################################
    :mb_attachment_upload_failed,
    :mb_create_message_creatives_failed,
    :mb_broadcast_message_failed,
    :mb_list_custom_labels_failed,
    :mb_fetch_custom_label_failed,
    :mb_delete_custom_label_failed,
    :mb_label_user_failed,
    :mb_unlabel_user_failed,
    :mb_list_custom_labels_of_user_failed,
    :mb_pass_thread_control_failed,
    :mb_take_thread_control_failed,
    :mb_request_thread_control_failed,
    :mb_fetch_secondary_receivers_failed,
    :mb_id_matching_failed,
    :mb_create_messenger_code_failed,
    :mb_fetch_messaging_feature_review_failed,
    :mb_fetch_insights_failed,
    :mb_set_messenger_profile_failed,
    :mb_reset_messenger_profile_failed,
    :mb_fetch_messenger_profile_failed,
    :mb_send_message_failed,
    :mb_unlink_account_failed,
    :mb_fetch_user_profile_failed,
    :mb_set_nlp_configs_failed,
    :mb_subscribe_to_page_webhooks_failed,
    :mb_unsubscribe_to_page_webhooks_failed,
    ##########################################################################
    :mb_attachment_upload_erred,
    :mb_create_message_creatives_erred,
    :mb_broadcast_message_erred,
    :mb_list_custom_labels_erred,
    :mb_fetch_custom_label_erred,
    :mb_delete_custom_label_erred,
    :mb_label_user_erred,
    :mb_unlabel_user_erred,
    :mb_list_custom_labels_of_user_erred,
    :mb_pass_thread_control_erred,
    :mb_take_thread_control_erred,
    :mb_request_thread_control_erred,
    :mb_fetch_secondary_receivers_erred,
    :mb_id_matching_erred,
    :mb_create_messenger_code_erred,
    :mb_fetch_messaging_feature_review_erred,
    :mb_fetch_insights_erred,
    :mb_set_messenger_profile_erred,
    :mb_reset_messenger_profile_erred,
    :mb_fetch_messenger_profile_erred,
    :mb_send_message_erred,
    :mb_unlink_account_erred,
    :mb_fetch_user_profile_erred,
    :mb_set_nlp_configs_erred,
    :mb_subscribe_to_page_webhooks_erred,
    :mb_unsubscribe_to_page_webhooks_erred]
```

## Usage

### Webhook handling

MessengerBot library handles allows you to handle all webhooks with subscription to the events.

#### How to subscribe to event topics?

`messenger_bot` package uses [event_bus library](https://github.com/otobus/event_bus) to sent/process Messenger events. Please refer to `event_bus` docs to learn more. You can subscribe registered events. To subscribe all events you can use `EventBus.subscribe({listener, [".*"]})` and to subscribe only specific topics then `EventBus.subscribe({listener, ["mb_message_received$", "mb_postback_received$"]})`. Please refer to `event_bus` library to documentation and Github wiki pages for more information.

Here is a sample echo bot consumer:

```elixir
EventBus.subscribe({MessengerBot.Consumer.Echo, ["mb_message_received$"]})

defmodule MessengerBot.Consumer.Echo do
  @moduledoc """
  Sample consumer implementation which echos for MessengerBot message events
  """

  use GenServer

  @listener __MODULE__

  def process({:mb_message_received, _id} = event_shadow) do
    GenServer.cast(__MODULE__, {:echo, event_shadow})
  end

  # This func is not necessary, but just for an example
  def process({topic, id}) do
    EventBus.mark_as_skipped({@listener, topic, id})
  end

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:ok, []}
  end

  def handle_cast({:echo, {topic, id}}, state) do
    event = EventBus.fetch_event({topic, id})
    echo_back(event.data)
    EventBus.mark_as_completed({@listener, topic, id})

    {:noreply, state}
  end

  defp echo_back(%{app_id: app_id, page_id: page_id, messaging: messaging}) do
    message = prepare_payload(messaging)
    MessengerBot.send_message({app_id, page_id}, message)
  end

  defp prepare_payload(messaging) do
    %{
      "messaging_type" => "RESPONSE",
      "recipient" => %{"id" => messaging["sender"]["id"]},
      "message" => %{
        "text" => messaging["message"]["text"]
      }
    }
  end
end
```

### Using Client to make HTTP request to Facebook endpoints

All MessengerBot client functions can be found on [https://hexdocs.pm/messenger_bot/1.0.0-beta10/MessengerBot.html#content).

## Contributing

### Issues, Bugs, Documentation, Enhancements

Create an issue if there is a bug.

Fork the project.

Make your improvements and write your tests(make sure you covered all the cases).

Make a pull request.

## License

LGPLv3

Copyright (c) 2018 Mustafa Turan

MessengerBot is an Open Source project licensed under the terms of the LGPLv3 license. Please see <http://www.gnu.org/licenses/lgpl-3.0.html> for license text.

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.