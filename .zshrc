# get current cmd before executing 
preexec() {
  export PLZ_CURRENT_COMMAND="$1"
}

# so we can provide it to plz
plz() {
  PLZ_FULL_CMD="$PLZ_CURRENT_COMMAND" $HOME/.dotfiles/scripts/plz "$@"
}
