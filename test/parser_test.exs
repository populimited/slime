defmodule ParserTest do
  use ExUnit.Case, async: false

  import Slime.Parser, only: [parse: 1]

  alias Slime.Parser.Nodes.{DoctypeNode, EExNode, HTMLCommentNode, HTMLNode, InlineHTMLNode, VerbatimTextNode}

  describe "parse/1" do
    test "nested tags with blank lines" do
      slime = """
      div


      div


        p

          span

        p
      div


      """

      assert parse(slime) == [
               %HTMLNode{name: "div"},
               %HTMLNode{
                 name: "div",
                 children: [
                   %HTMLNode{name: "p", children: [%HTMLNode{name: "span"}]},
                   %HTMLNode{name: "p"}
                 ]
               },
               %HTMLNode{name: "div"}
             ]
    end

    test "inline tags" do
      slime = """
      .wrap: .row: .col-lg-12
        .box: p One
        .box: p Two
      p Three
      """

      assert parse(slime) == [
               %HTMLNode{
                 name: "div",
                 attributes: [{"class", "wrap"}],
                 children: [
                   %HTMLNode{
                     name: "div",
                     attributes: [{"class", "row"}],
                     children: [
                       %HTMLNode{
                         name: "div",
                         attributes: [{"class", "col-lg-12"}],
                         children: [
                           %HTMLNode{
                             name: "div",
                             attributes: [{"class", "box"}],
                             children: [
                               %HTMLNode{
                                 name: "p",
                                 children: [
                                   %VerbatimTextNode{content: ["One"]}
                                 ]
                               }
                             ]
                           },
                           %HTMLNode{
                             name: "div",
                             attributes: [{"class", "box"}],
                             children: [
                               %HTMLNode{
                                 name: "p",
                                 children: [
                                   %VerbatimTextNode{content: ["Two"]}
                                 ]
                               }
                             ]
                           }
                         ]
                       }
                     ]
                   }
                 ]
               },
               %HTMLNode{
                 name: "p",
                 children: [
                   %VerbatimTextNode{content: ["Three"]}
                 ]
               }
             ]
    end

    test "closed nodes" do
      slime = """
      img src="url"/
      """

      assert parse(slime) == [
               %HTMLNode{name: "img", attributes: [{"src", "url"}], closed: true}
             ]
    end

    test "components" do
      slime = """
      :button class="it-works"
        | This renders
        strong inside
        | the button!
      """

      assert parse(slime) == [
        %Slime.Parser.Nodes.HEExNode{
          name: ".button",
          attributes: [{"class", "it-works"}],
          spaces: %{},
          closed: false,
          children: [
            %Slime.Parser.Nodes.VerbatimTextNode{content: ["This renders"]},
            %Slime.Parser.Nodes.HTMLNode{
              name: "strong",
              attributes: [],
              spaces: %{},
              closed: false,
              children: [%Slime.Parser.Nodes.VerbatimTextNode{content: ["inside"]}]
            },
            %Slime.Parser.Nodes.VerbatimTextNode{content: ["the button!"]}
          ]
        }
      ]
    end

    test "component slots" do
      slime = """
      :modal
        | This is the body, everything not in a named slot is rendered in the default slot.
        ::footer
          | This is the bottom of the modal.
      """

      assert parse(slime) == [
        %Slime.Parser.Nodes.HEExNode{
          name: ".modal",
          attributes: [],
          spaces: %{},
          closed: false,
          children: [
            %Slime.Parser.Nodes.VerbatimTextNode{
              content: ["This is the body, everything not in a named slot is rendered in the default slot."]
            },
            %Slime.Parser.Nodes.HEExNode{
              name: ":footer",
              attributes: [],
              spaces: %{},
              closed: false,
              children: [
                %Slime.Parser.Nodes.VerbatimTextNode{
                  content: ["This is the bottom of the modal."]
                }
              ]
            }
          ]
        }
      ]
    end

    test "attributes" do
      slime = """
      div.class some-attr="value"
        p#id(wrapped-attr="value" another-attr="value")
      """

      assert parse(slime) == [
               %HTMLNode{
                 name: "div",
                 attributes: [
                   {"class", "class"},
                   {"some-attr", "value"}
                 ],
                 children: [
                   %HTMLNode{
                     name: "p",
                     attributes: [
                       {"another-attr", "value"},
                       {"id", "id"},
                       {"wrapped-attr", "value"}
                     ]
                   }
                 ]
               }
             ]
    end

    test "multiline attributes" do
      slime = """
      div
        a(href="/path"
        title="long title"
        data-something="value")
          span(
          class="icon") Icon
      """

      assert parse(slime) == [
               %HTMLNode{
                 name: "div",
                 attributes: [],
                 children: [
                   %HTMLNode{
                     name: "a",
                     attributes: [
                       {"data-something", "value"},
                       {"href", "/path"},
                       {"title", "long title"}
                     ],
                     children: [
                       %HTMLNode{
                         name: "span",
                         attributes: [{"class", "icon"}],
                         children: [%Slime.Parser.Nodes.VerbatimTextNode{content: ["Icon"]}]
                       }
                     ]
                   }
                 ]
               }
             ]
    end

    test "embedded code" do
      slime = """
      = for thing <- stuff do
        - output = process(thing)
        p
          = output
      """

      assert parse(slime) == [
               %EExNode{
                 content: "for thing <- stuff do",
                 output: true,
                 children: [
                   %EExNode{content: "output = process(thing)"},
                   %HTMLNode{
                     name: "p",
                     children: [
                       %EExNode{content: "output", output: true}
                     ]
                   }
                 ]
               }
             ]
    end

    test "embedded code (else is parsed as a child of if)" do
      slime = """
      main
        = if condition do
          | Something


        - else
          | Something else

      footer
      """

      assert parse(slime) == [
               %HTMLNode{
                 name: "main",
                 children: [
                   %EExNode{
                     content: "if condition do",
                     output: true,
                     children: [
                       %VerbatimTextNode{content: ["Something"]},
                       %EExNode{
                         content: "else",
                         children: [
                           %VerbatimTextNode{content: ["Something else"]}
                         ]
                       }
                     ]
                   }
                 ]
               },
               %HTMLNode{name: "footer"}
             ]
    end

    test "hash signs in attributes" do
      slime = """
      a href="#" Foo
      """

      assert parse(slime) == [
               %HTMLNode{
                 name: "a",
                 attributes: [{"href", "#"}],
                 children: [
                   %VerbatimTextNode{content: ["Foo"]}
                 ]
               }
             ]
    end

    test "inline eex" do
      slime = """
      p some-attribute=inline = hey
      span Text
      """

      assert parse(slime) == [
               %HTMLNode{
                 name: "p",
                 attributes: [{"some-attribute", {:eex, "inline"}}],
                 children: [%EExNode{content: "hey", output: true}]
               },
               %HTMLNode{name: "span", children: [%VerbatimTextNode{content: ["Text"]}]}
             ]
    end

    test "inline content" do
      slime = """
      p attr="value" Inline text
      """

      assert parse(slime) == [
               %HTMLNode{
                 name: "p",
                 attributes: [{"attr", "value"}],
                 children: [
                   %VerbatimTextNode{content: ["Inline text"]}
                 ]
               }
             ]
    end

    test "inline html" do
      slime = ~S"""
      <html>
        head
          <meta content="#{interpolation}"/>
        <body>
          table
            = for a <- articles do
              <tr>#{a.name}</tr>
        </body>
      </html>
      """

      assert parse(slime) == [
               %InlineHTMLNode{
                 content: ["<html>"],
                 children: [
                   %HTMLNode{
                     name: "head",
                     children: [
                       %InlineHTMLNode{content: ["<meta content=\"", {:eex, "interpolation"}, "\"/>"]}
                     ]
                   },
                   %InlineHTMLNode{
                     content: ["<body>"],
                     children: [
                       %HTMLNode{
                         name: "table",
                         children: [
                           %EExNode{
                             content: "for a <- articles do",
                             output: true,
                             children: [
                               %InlineHTMLNode{content: ["<tr>", {:eex, "a.name"}, "</tr>"]}
                             ]
                           }
                         ]
                       }
                     ]
                   },
                   %InlineHTMLNode{content: ["</body>"]}
                 ]
               },
               %InlineHTMLNode{content: ["</html>"]}
             ]
    end

    test "verbatim text nodes" do
      slime = ~S"""
      | multiline
         text with #{interpolation}
      ' and trailing whitespace
      """

      assert parse(slime) == [
               %VerbatimTextNode{content: ["multiline", "\n", " ", "text with ", {:eex, "interpolation"}]},
               %VerbatimTextNode{content: ["and trailing whitespace", " "]}
             ]
    end

    test "html comments" do
      slime = "/! html comment"
      assert parse(slime) == [%HTMLCommentNode{content: ["html comment"]}]
    end

    test "doctype" do
      slime = """
      doctype html
      div
      """

      assert parse(slime) == [
               %DoctypeNode{name: "html"},
               %HTMLNode{name: "div"}
             ]
    end

    test "doctype followed by empty line" do
      slime = """
      doctype html

      div
      """

      assert parse(slime) == [
               %DoctypeNode{name: "html"},
               %HTMLNode{name: "div"}
             ]
    end

    test ~s(raises error on unmatching attributes wrapper) do
      assert_raise(Slime.TemplateSyntaxError, fn -> parse(~S(div[id="test"})) end)
    end

    test ~s(raises error on unexpected indent) do
      assert_raise(Slime.TemplateSyntaxError, ~r/^Unexpected indent/, fn -> parse("\n  #test") end)
    end

    test ~s(raises error on unexpected symbol) do
      assert_raise(Slime.TemplateSyntaxError, ~r/^Unexpected symbol '#'/, fn -> parse("#^test") end)
    end
  end
end
