#!/bin/bash

# Common functions used across scripts

doctor() {
  # check version manager
  check_version_manager
  check_elixir_erlang_available
  # check elixir and erlang versions

}

check_version_manager() {
  vm=$(available_version_manager)
  if [ "$vm" = "mise" ];  then
    echo "✅ mise version manager is installed"
  elif [ "$vm" = "asdf" ]; then
    echo "✅ asdf version manager is installed"
  else
    echo "❌ version manager is not installed"
  fi

  return 0
}

available_version_manager() {
  errors=()
  vm=""

  if command -v mise &> /dev/null; then
    vm="mise"
  elif command -v asdf &> /dev/null; then
    vm="asdf"
  else
    errors+="version_manager_not_found"
  fi

  echo $vm

  return 0
}

check_elixir_erlang_available() {
  VERSION_MANAGER=$(check_version_manager)
  errors=()

  if command -v elixir --version &> /dev/null; then
    echo "✅ elixir is installed"
  else
    errors+=("elixir_not_found")
    echo "❌ Elixir is not installed"
  fi

  if command -v erl -version &> /dev/null; then
    echo "✅ erlang is installed"
  else
    echo "❌ Erlang is not installed"
    errors+=("erlang_not_found")
  fi

  return 0
}

setup() {
  vm=$(available_version_manager)
  elixir_version=$(get_elixir_version)
  erlang_version=$(get_erlang_version)
  phoenix_version="1.8.1"

  if [ "$vm" = "mise" ];  then
    mise use --global elixir@"$elixir_version"
    mise use --global erlang@"$erlang_version"

  elif [ "$vm" = "asdf" ]; then
    asdf plugin add elixir https://github.com/asdf-vm/asdf-elixir.git
    asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
    asdf install elixir "$elixir_version"
    asdf install erlang "$erlang_version"
    asdf set --home elixir "$elixir_version"
    asdf set --home erlang "$erlang_version"
  else
    doctor
    return 1
  fi

  mix archive.install hex phx_new "$phoenix_version" --force

  doctor

  return 0
}


get_elixir_version() {
  echo $(grep "^elixir" .tool-versions | awk '{print $2}')
}

get_erlang_version() {
  echo $(grep "^erlang" .tool-versions | awk '{print $2}')
}

create_tool_versions() {
  local erlang_version=$1
  local elixir_version=$2
  local path=${3:-.}

  cat > "$path/.tool-versions" << EOF
erlang $erlang_version
elixir $elixir_version
EOF

  echo "✅ Created .tool-versions"
}

install_deps() {
  echo ""
  echo "📦 Installing dependencies..."
  mix deps.get
}
