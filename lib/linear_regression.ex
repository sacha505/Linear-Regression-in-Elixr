defmodule LinearRegression do
  @moduledoc """
  Documentation for `LinearRegression`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> LinearRegression.hello()
      :world

  """

@spec load_cars_csv_file(integer) ::
        {:ok, {list, list, list, list}} | {:error, binary}
def load_cars_csv_file(test_size) do
  root_path = Path.expand(".")
  file_path = Path.join([root_path, "data", "cars.csv"])

  if File.exists?(file_path) do
    {test_data, data} =
      file_path
      |> File.stream!()
      |> CSV.parse_stream()
      |> Stream.map(fn row ->
        [
          _passedemissions,
          mpg,
          cylinders,
          displacement,
          horsepower,
          weight,
          _acceleration,
          modelyear,
          _carname
        ] = row

        {[
            parse_float(horsepower),
            parse_float(cylinders),
            parse_float(weight),
            parse_float(displacement),
            parse_float(modelyear)
          ], [parse_float(mpg)]}
      end)
      |> Enum.to_list()
      |> Enum.shuffle()
      |> Enum.split(test_size)

    features = Enum.map(data, &elem(&1, 0))
    labels = Enum.map(data, &elem(&1, 1))
    test_features = Enum.map(test_data, &elem(&1, 0))
    test_labels = Enum.map(test_data, &elem(&1, 1))

    {:ok, {features, labels, test_features, test_labels}}
  else
    {:error, "File doesn't exist!"}
  end
end

@type t :: %State{
  batch_size: integer,
  batch_quantity: integer | nil,
  features: Nx.t() | nil,
  iterations: integer,
  labels: Nx.t() | nil,
  learning_rate: float,
  mean: Nx.t() | nil,
  mse_history: [float],
  standardize_features: boolean,
  std_dev: Nx.t() | nil,
  test_features: Nx.t() | nil,
  test_labels: Nx.t() | nil,
  test_size: integer,
  training_iteration: integer | nil,
  weights: Nx.t() | nil
}

def handle_call(:load_data, _from, %State{} = state) do
  case CsvLoader.load_cars_csv_file(state.test_size) do
    {:ok, {features, labels, test_features, test_labels}} ->
      state
      |> Map.put(:features, Nx.tensor(features))
      |> Map.put(:labels, Nx.tensor(labels))
      |> Map.put(:test_features, Nx.tensor(test_features))
      |> Map.put(:test_labels, Nx.tensor(test_labels))
      |> maybe_standardize_features()
      |> adjust_features()
      |> set_weights()
      |> tap(&Logger.info("Loaded data for #{elem(&1.features.shape, 1)} features"))
      |> then(&{:reply, nil, &1})

    {:error, error} ->
      {:reply, error, state}
  end
end
end
