use Mix.Config

config :event_bus,
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
    :mb_app_setup_received,
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
    ##########################################################################
    # Test topics
    ##########################################################################
    :mb_test_succeeded,
    :mb_test_failed,
    :mb_test_erred
  ]

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
