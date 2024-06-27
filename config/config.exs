import Config

config :phoenix, :template_engines, sheex: Slime.Engine

if Mix.env() == :test do
  config :slime, :attr_list_delims, %{"[" => "]", "(" => ")"}

  config :slime, :embedded_engines, %{
    test_engine: RenderEmbeddedEngineTest.TestEngine
  }
end
