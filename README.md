# Plz

A wildly dangerous piece of shell magic that runs claude in yolo mode to do whatever you want.

See the examples below. Anyone who lives out of shell will get why this is cool.

## Installation

Aside from putting the `plz` script on your path, you also need to do this
hacky shit so it can see the full command:

### Nushell

```nu
# config.nu
$env.config.hooks.pre_execution = (
    $env.config.hooks.pre_execution? | default [] | append {||
        $env.PLZ_FULL_CMD = (commandline)
    }
)
```

### Zsh

```zsh
# ~/.zshrc
autoload -Uz add-zsh-hook
_plz_capture_cmd() { export PLZ_FULL_CMD="$1"; }
add-zsh-hook preexec _plz_capture_cmd
```

## Examples

### Get a command to do something

```nushell
ls -la | plz "give me a command to extract filenames"
```

#### Output

##### Nushell

```nushell
ls | get name
```

##### Bash

```bash
ls -la | awk '{print $NF}'
```

### Or just tell it to do stuff

```nushell
ls -la | plz "extract the filenames"
```

#### Output (any shell)

```
README.md
plz
```
#### Pipe into it

It knows what data format is coming *in*

```bash
echo '{"users": [{"name": "Alice", "age": 30}, {"name": "Bob", "age": 25}]}' | plz "extract just the names"
```

#### Output (any shell)

```
Alice
Bob
```

#### Pipe out of it into anything

It also knows what data format it needs to go *to* (i.e json, because of jq)

```bash
# knows that its piping into `jq .` and so must provide json format
curl -s https://api.github.com/users/zachdaniel | plz "get the username and location" | jq .
```

##### Output (any shell)

```
{
  "username": "zachdaniel",
  "location": "Summit, NJ"
}
```

### Put it all together

```nushell
"zachdaniel,josevalim" | plz "get their github usernames and locations" | jq . | plz "capitalize the keys"
```

#### Output (any shell)

```
[
  {
    "Username": "zachdaniel",
    "Location": "Summit, NJ"
  },
  {
    "Username": "josevalim",
    "Location": "Kraków, Poland"
  }
]
```
