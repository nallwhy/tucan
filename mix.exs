defmodule Tucan.MixProject do
  use Mix.Project

  def project do
    [
      app: :tucan,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:nimble_options, "~> 1.0"},
      {:vega_lite, "~> 0.1.7"},
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
      {:fancy_fences, "~> 0.1", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      markdown_processor:
        {FancyFences,
         [
           fences: %{
             "vega-lite" => {Tucan.Docs, :vl, []}
           }
         ]},
      before_closing_body_tag: fn
        :html ->
          """
          <script src="https://cdn.jsdelivr.net/npm/vega@5.20.2"></script>
          <script src="https://cdn.jsdelivr.net/npm/vega-lite@5.1.1"></script>
          <script src="https://cdn.jsdelivr.net/npm/vega-embed@6.18.2"></script>
          <script>
            document.addEventListener("DOMContentLoaded", function () {
              for (const codeEl of document.querySelectorAll("pre code.vega-lite")) {
                try {
                  const preEl = codeEl.parentElement;
                  const spec = JSON.parse(codeEl.textContent);
                  const plotEl = document.createElement("div");
                  preEl.insertAdjacentElement("afterend", plotEl);
                  vegaEmbed(plotEl, spec);
                  preEl.remove();
                } catch (error) {
                  console.log("Failed to render Vega-Lite plot: " + error)
                }
              }
            });
          </script>
          """

        _ ->
          ""
      end
    ]
  end
end
