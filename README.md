# Slime
> A refreshing way to slim down your markup in Elixir.

Slime is an [Elixir][elixir] library for rendering [Slim][slim]-like
templates as HTML using Phoenix's [heex][HEEx] Template Engine.

This library is a fork combination from [@tensiondriven/slime][tslime] and [@tensiondriven/phoenix_slime][t_phoenix_slime]

[heex]: https://hexdocs.pm/phoenix/components.html
[slim]: http://slim-lang.com
[elixir]: http://elixir-lang.com
[phoenix]: http://www.phoenixframework.org/
[phoenix-slime]: https://github.com/slime-lang/phoenix_slime
[tslime]: https://github.com/tensiondriven/slime
[t_phoenix_slime]: https://github.com/tensiondriven/phoenix_slime


Easily turn this:

```slim
doctype html
html
  head
    meta name="keywords" description="Slime"
    title = site_title
    javascript:
      alert('Slime supports embedded javascript!');
  body
    #id.class
      ul
        = Enum.map [1, 2], fn x ->
          li = x
```

Into this:

```html
<!DOCTYPE html>
<html>
<head>
  <meta name="keywords" description="Slime">
  <title>Website Title</title>
  <script>alert('Slime supports embedded javascript!');</script>
</head>

<body>
  <div class="class" id="id">
    <ul>
      <li>1</li>
      <li>2</li>
    </ul>
  </div>
</body>
</html>
```

## Usage

  1. Add `{:slime, git: "populimited/slime", branch: "phx1.7}` to your deps in `mix.exs`.
  2. Add the following to your Phoenix `config/config.exs`:

```elixir
  config :phoenix, :template_engines,
    sheex: Slime.Engine
```

## Reference

### Tags

Starting a line with a string followed by a space will create an html tag, as follows:

```slim
tt
  Always bring a towel.
```

```html
<tt>Always bring a towel.<tt>
```

### Attributes

Attributes can be assigned in a similar fashion to regular HTML.

```slim
a href="elixir-lang.org" target="_blank" Elixir
```
```html
<a href="elixir-lang.org" target="_blank">Elixir</a>
```

Elixir expressions can be used as attribute values using the interpolation
syntax.

```slim
a href="#{my_variable}" Elixir
```
```html
<a href="elixir-lang.org">Elixir</a>
```

Boolean attributes can be set using boolean values

```slim
input type="checkbox" checked=true
input type="checkbox" checked=false
```
```html
<input type="checkbox" checked>
<input type="checkbox">
```

There is a literal syntax for class and id attributes

```slim
.foo.bar
select.bar
#foo
body#bar
```
```html
<div class="foo bar"></div>
<select class="bar"></select>
<div id"foo"></div>
<body id="bar"></body>
```

See [HEEx Support](#heex-support) for assigning attributes when rendering to HEEx.

### Code

Elixir can be written inline using `-` and `=`.

`-` evalutes the expression.
`=` evalutes the expression, and then inserts the value into template.

```slim
- number = 40
p = number + 2
```
```html
<p>42</p>
```

The interpolation syntax can be used to insert expressions into text.

```slim
- name = "Felix"
p My cat's name is #{name}
```
```html
<p>My cat's name is Felix</p>
```


### Comments

Lines can be commented out using the `/` character.

```slim
/ p This line is commented out
p This line is not
```
```html
<p>This line is not</p>
```

HTML `<!-- -->` comments can be inserted using `/!`
```slim
/! Hello, world!
```
```html
<!-- Hello, world! -->
```


### Conditionals

We can use the regular Elixir flow control such as the `if` expression.

```slim
- condition = true
= if condition do
  p It was true.
- else
  p It was false.
```
```html
<p>It was true.</p>
```


### Doctype

There are shortcuts for common doctypes.

```slim
doctype html
doctype xml
doctype transitional
doctype strict
doctype frameset
doctype 1.1
doctype basic
doctype mobile
```
```html
<!DOCTYPE html>
<?xml version="1.0" encoding="utf-8" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">
<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">
```


### Iteration

Elixir's collection manipulation expressions can be used to iterate over
collections in your templates.

```slim
- names = ["Sarah", "Mia", "Harry"]

/! Enum.map
= Enum.map names, fn name ->
  p = name

/! for comprehension
= for name <- names do
  h1 = name
```
```html
<!-- Enum.map -->
<p>Sarah</p>
<p>Mia</p>
<p>Harry</p>

<!-- for comprehension -->
<h1>Sarah</h1>
<h1>Mia</h1>
<h1>Harry</h1>
```

### Embedded engines

Examples:

```slim
javascript:
  console.log("Test javascript");

css:
  body {
    color: black;
  }

elixir:
  a = [1, 2, 3]
  b = Enum.map(a, &(&1 + 1))

eex:
  Hello from <%= "eex" %>
```

You can define your own embedded engine in slime application config:

```elixir
# config.exs
config :slime, :embedded_engines, %{
  markdown: MyApp.MarkdownEngine
}

# markdown_engine.ex
defmodule MyApp.MarkdownEngine do
  @behaviour Slime.Parser.EmbeddedEngine

  def render(text, _options) do
    Earmark.to_html(text)
  end
end
```
Because the engines are being read on compile time you need to recompile
the library after you have added new engines. You can do this by:

```bash
mix deps.compile slime --force
```

# Components
HEEx's components are supported:
```slim
:greet user=@current_user.name :let=g
  ::subtitle
    | Hello there!
```

would create the following output:

```
<.greet user={@current_user.name} :let={g}>
  <:subtitle>Hello there!</:subtitle>
</:greet>
```

# Sigil
```slim
import Slime.Sigil

def button(assigns) do
  ~h"""
    :greet user=@current_user.name
      ::subtitle
        | Hello there!
  """
end
```

would be the equivalent of:

```
def button(assigns) do
  ~H"""
    <.greet user={@current_user.name}>
      <:subtitle>Hello there!</:subtitle>
    </:greet>
  """
end
```

## Differences to Ruby Slim

We aim for feature parity with the original [Slim](http://slim-lang.com)
implementation, but we deviate in some respects. We do this to be true to
Elixir – just like the original Slim implementation is true to its Ruby
foundations.

For example, in Slime you do

```slim
= if condition do
  p It was true.
- else
  p It was false.
```

where Ruby Slim would do

```slim
- if condition
  p It was true.
- else
  p It was false.
```

Note the `do` and the initial `=`, because we render the return value of the
conditional as a whole.

Slime also adds support for HEEx. See the section on [HEEx Support](#heex-support).

## Debugging

If you have trouble locating exceptions in Slime templates, you can add

```elixir
config :slime, :keep_lines, true
```

to your `config.exs` file.

With this option Slime will keep original template lines in result `heex` and `html`.

Keep in mind, that output is slightly different from default Slime output, for example `|` works like `'`, and empty lines are not ignored.


## Contributing

Feedback, feature requests, and fixes are welcomed and encouraged.  Please
make appropriate use of [Issues][issues] and [Pull Requests][pulls].  All code
should have accompanying tests.

[issues]: https://github.com/populimited/slime/issues
[pulls]: https://github.com/populimited/slime/pulls