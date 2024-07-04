#!/usr/bin/env bash

# Create a mock command in the test/mocks directory
create_mock() {
  local command_name="$1"
  local mock_dir="$(pwd)/test/mocks"
  mkdir -p "$mock_dir"
  echo "#!/usr/bin/env bash" > "$mock_dir/$command_name"
  echo "echo \"Mock $command_name executed with \$@\"" >> "$mock_dir/$command_name"
  chmod +x "$mock_dir/$command_name"
}

# Cean up mocks
cleanup_mocks() {
  rm -rf "$(pwd)/test/mocks"
}

# Custom assertion example
assert_file_contains() {
  local file="$1"
  local expected_content="$2"
  grep -qF -- "$expected_content" "$file"
  assert_success "$?"
}