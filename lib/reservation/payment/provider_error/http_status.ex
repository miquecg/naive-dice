defmodule Reservation.Payment.ProviderError.HTTPStatus do
  defexception [:status_code, :response]

  @impl Exception
  def exception(attributes) do
    %__MODULE__{
      status_code: attributes[:status_code],
      response: attributes[:response]
    }
  end

  @impl Exception
  def message(exception) do
    """
    Invalid status code: #{exception.status_code}
    Response: #{inspect(exception.response)}
    """
  end
end
