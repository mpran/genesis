#!/bin/bash

set -e

run() {
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/common.sh"

  echo "====Application setup===="

  DEFAULT_ELIXIR_VERSION=$(get_elixir_version)
  DEFAULT_ERLANG_VERSION=$(get_erlang_version)

  read -p "Base directory*: " BASE_DIR
  read -p "App type* (api ui lib app_sup web_monolith): " APP_TYPE
  read -p "App name*: " APP_NAME
  read -p "Base module name if different than app. ex: CoolApp.Api []: " MODULE_NAME_ARG
  read -p ".tool-versions elixir version [$DEFAULT_ELIXIR_VERSION]: " ELIXIR_VERSION
  ELIXIR_VERSION=${ELIXIR_VERSION:-DEFAULT_ELIXIR_VERSION}
  read -p ".tool-versions erlang version [$DEFAULT_ERLANG_VERSION]: " ERLANG_VERSION
  ERLANG_VERSION=${ELIXERLANG_VERSIONIR_VERSION:-DEFAULT_ERLANG_VERSION}

  if [ -z "$BASE_DIR" ]; then
    echo "❌ Base directory is required"
    return 1
  fi

  if [ -z "$APP_TYPE" ]; then
    echo "❌ App type is required"
    return 1
  fi

  if [ -z "$APP_NAME" ]; then
    echo "❌ App name is required"
    return 1
  fi

  APP_PATH="$BASE_DIR/$APP_NAME"
  PROJECT_ARGS=""

  if [[ "$APP_TYPE" == "api" || "$APP_TYPE" == "web_monolith" ]]; then
    read -p "Database (postgres mysql mssql sqlite) [postgres]: " DATABASE_ARG
  fi

  if [[ "$APP_TYPE" = "ui" || "$APP_TYPE" = "web_monolith" ]]; then
    read -p "Use liview (y/n): " USE_LIVEVIEW

    if [ "$USE_LIVEVIEW" = "n" ]; then
      PROJECT_ARGS="$PROJECT_ARGS --no-live"
    fi

  fi

  if [ -z "$DATABASE_ARG" ]; then
    DATABASE_ARG="postgres"
  fi

  if [ -n "$MODULE_NAME_ARG" ]; then
    MODULE_NAME_ARG="--module $MODULE_NAME_ARG"
  fi

  BASE_WEB_ARGS="--adapter bandit --no-dashboard --database $DATABASE_ARG"

  BASE_DIR="${BASE_DIR/#\~/$HOME}"

  cd "$BASE_DIR"

  case "$APP_TYPE" in
    api)
      ARGS="$APP_NAME $PROJECT_ARGS $MODULE_NAME_ARG $BASE_WEB_ARGS --no-assets --no-esbuild --no-gettext --no-html --no-live --no-tailwind"
      echo "Running mix phx.new $ARGS"
      mix phx.new $ARGS
      ;;
    ui)
      ARGS="$APP_NAME $MODULE_NAME_ARG $PROJECT_ARGS $BASE_WEB_ARGS --no-ecto --no-mailer"
      echo "Running mix phx.new $ARGS"
      mix phx.new $ARGS
      ;;
    web_monolith)
      ARGS="$APP_NAME $MODULE_NAME_ARG $PROJECT_ARGS $BASE_WEB_ARGS"
      echo "Running mix phx.new $ARGS"
      mix phx.new $ARGS
      ;;
    lib)
      ARGS="$APP_NAME $MODULE_NAME_ARG $PROJECT_ARGS"
      echo "Running mix new $ARGS"
      mix new $ARGS
      ;;
    app_sup)
      ARGS="$APP_NAME $MODULE_NAME_ARG $PROJECT_ARGS --sup"
      echo "Running mix new $ARGS"
      mix new $ARGS
      ;;
    *)
      echo "❌ Invalid app type"
  esac

  return 0
}

run
