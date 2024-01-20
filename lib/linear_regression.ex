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

  # Set of useful machine learning functions.
  # https://github.com/elixir-nx/scholar
  alias Scholar.Preprocessing

  # This allows us to use numerical definitions.
  import Nx.Defn

  # This is the linear regression function.
  # A linear regression line has an equation of the form Y = wX + b.
  defn predict({w, b}, x) do
    w * x + b
  end

  # This calculates the mean squared error.
  # MSE calculates the difference between the predicted fuel economy and the actual economy.
  defn loss(params, x, y) do
    y_hat = predict(params, x)

    (y - y_hat)
    |> Nx.power(2)
    |> Nx.mean()
  end

  # This finds the gradient and updates w and b accordingly.
  # The gradient minimizes the distance between predicted and true outcomes based on the loss function.
  # w and b are weights that must be updated to get closer to the real value.
  # lr stands for learning rate, which is a parameter that determines the step size
  # at each iteration while moving toward a minimum of a loss function.
  defn update({w, b} = params, x, y, lr) do
    {grad_w, grad_b} = grad(params, &loss(&1, x, y))

    {
      w - grad_w * lr,
      b - grad_b * lr
    }
  end

  # This is just to generate some initial values for weights and bias.
  defn init_random_params do
    w = Nx.random_normal({}, 0.0, 0.1)
    b = Nx.random_normal({}, 0.0, 0.1)
    {w, b}
  end

  # This is for training based on the number of epochs.
  @spec train(data :: tuple(), lr :: float(), epochs :: integer()) ::
          {Nx.Tensor.t(), Nx.Tensor.t()}
  def train(data, lr, epochs) do
    init_params = init_random_params()

    {x, y} = Enum.unzip(data)

    x = Preprocessing.standard_scaler(Nx.tensor(x))
    y = Nx.tensor(y)

    for _ <- 1..epochs, reduce: init_params do
      acc -> update(acc, x, y, lr)
    end
  end

  # The train-test split is a technique for evaluating the performance of a machine learning algorithm.
  # It's important to simulate how a model would perform on new/unseen data.
  @spec train_test_split(data :: list(), train_size :: float()) :: tuple()
  def train_test_split(data, train_size) do
    num_examples = Enum.count(data)
    num_train = floor(train_size * num_examples)
    Enum.split(data, num_train)
  end


  defmodule NxLinearRegression.FuelEconomy do
    @moduledoc """
    Try to predict the likely fuel consumption efficiency
    https://www.kaggle.com/vinicius150987/regression-fuel-consumption
    """

    # Functions to handle CSVfiles
    # https://github.com/dashbitco/nimble_csv
    alias NimbleCSV.RFC4180, as: CSV

    # Set of useful machine learning functions
    # https://github.com/elixir-nx/scholar
    alias Scholar.Preprocessing

    # Let's define some defaults epochs and learning rate.
    @epochs 2000
    @learning_rate 0.1

    # This will call our internal training function with epochs and learning rate we defined above.
    @spec train(data :: tuple) :: {Nx.Tensor.t(), Nx.Tensor.t()}
    def train(data) do
      NxLinearRegression.train(data, @learning_rate, @epochs)
    end

    # This is going to predict based on the params previously learned.
    @spec predict(params :: tuple(), data :: list()) :: Nx.Tensor.t()
    def predict(params, data) do
      x =
        data
        |> Nx.tensor()
        |> Preprocessing.standard_scaler()

      NxLinearRegression.predict(params, x)
    end

    # This is going to calculate the MSE based on the params previously learned.
    @spec mse(params :: tuple(), data :: tuple()) :: Nx.Tensor.t()
    def mse(params, data) do
      {x, y} = Enum.unzip(data)

      x = Preprocessing.standard_scaler(Nx.tensor(x))
      y = Nx.tensor(y)

      NxLinearRegression.loss(params, x, y)
    end

    # This is going to load the data as streams.
    @spec load_data :: Stream.t()
    def load_data do
      "FuelEconomy.csv"
      |> File.stream!()
      |> CSV.parse_stream()
      |> Stream.map(fn [horse_power, fuel_economy] ->
        {
          Float.parse(horse_power) |> elem(0),
          Float.parse(fuel_economy) |> elem(0)
        }
      end)
    end
  end



end
