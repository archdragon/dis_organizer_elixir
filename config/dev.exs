use Mix.Config

config :disorganizer, hipchat_room_id:    System.get_env("DIS_HIPCHAT_ROOM_ID")
config :disorganizer, pivotal_project_id: System.get_env("DIS_PIVOTAL_PROJECT_ID")
config :disorganizer, hipchat_auth_token: System.get_env("DIS_HIPCHAT_AUTH_TOKEN")
config :disorganizer, pivotal_auth_token: System.get_env("DIS_PIVOTAL_AUTH_TOKEN")
