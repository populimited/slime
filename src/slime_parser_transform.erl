-module(slime_parser_transform).
-export([transform/3]).

%% Add clauses to this function to transform syntax nodes
%% from the parser into semantic output.
transform(Symbol, Node, _Index) when is_atom(Symbol) ->
  Node.