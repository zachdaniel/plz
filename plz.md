A rough draft of a script that allows piping into and out of claude code in such a way that it is aware of its context.

Some examples:

```bash
# can give you a command
ls -la | plz "give me an awk command to extract filenames"
```


```bash
# or just run them
ls -la | plz "extract the filenames using awk"
```

```bash
echo '{"users": [{"name": "Alice", "age": 30}, {"name": "Bob", "age": 25}]}' | plz "extract just the names"
```

```bash
# knows that its piping into `jq .` and so must provide json format
curl -s https://api.github.com/users/zachdaniel | plz "get the username and location" | jq .
```