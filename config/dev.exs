use Mix.Config

config :disorganizer, hipchat_room_id:    System.get_env("DIS_HIPCHAT_ROOM_ID")
config :disorganizer, pivotal_project_id: System.get_env("DIS_PIVOTAL_PROJECT_ID")
config :disorganizer, hipchat_auth_token: System.get_env("DIS_HIPCHAT_AUTH_TOKEN")
config :disorganizer, pivotal_auth_token: System.get_env("DIS_PIVOTAL_AUTH_TOKEN")
config :disorganizer, github_auth_token:  System.get_env("DIS_GITHUB_AUTH_TOKEN")
config :disorganizer, github_user_agent:  System.get_env("DIS_GITHUB_USER_AGENT")
config :disorganizer, github_repo_addr:   System.get_env("DIS_GITHUB_REPO_ADDR")
config :disorganizer, rollbar_auth_token: System.get_env("DIS_ROLLBAR_AUTH_TOKEN")
config :disorganizer, slack_auth_token:   System.get_env("DIS_SLACK_AUTH_TOKEN")
