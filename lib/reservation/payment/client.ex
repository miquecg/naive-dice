defmodule Reservation.Payment.Client do
  @moduledoc """
  API client for payments.
  """

  alias Reservation.Payment.Provider
  alias Reservation.Payment.ProviderError.HTTPStatus
  alias Reservation.Schemas.Order

  def create_checkout(provider, %Order{} = order, extra) do
    request = Provider.session_create(provider, order, extra)
    credentials = Provider.credentials(provider)

    with {:ok, response} <- do_request(request, credentials),
         {:ok, session} <- decode(response) do
      {:ok, Provider.parse(provider, session)}
    end
  end

  def retrieve_checkout(provider, session_id) do
    request = Provider.session_retrieve(provider, session_id)
    credentials = Provider.credentials(provider)

    with {:ok, response} <- do_request(request, credentials),
         {:ok, session} <- decode(response) do
      {:ok, Provider.parse(provider, session)}
    end
  end

  defp do_request({:form, url, body}, credentials), do: post_form(url, body, credentials)

  defp do_request({:get, url}, credentials), do: get(url, credentials)

  defp post_form(url, body, credentials) do
    form_data = URI.encode_query(body)
    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]
    opts = [hackney: [basic_auth: basic_auth(credentials)]]
    HTTPoison.post(url, form_data, headers, opts)
  end

  defp get(url, credentials) do
    headers = []
    opts = [hackney: [basic_auth: basic_auth(credentials)]]
    HTTPoison.get(url, headers, opts)
  end

  defp basic_auth(credentials) do
    {:ok, {_, _} = username_password} = Keyword.fetch(credentials, :basic)
    username_password
  end

  defp decode(%{status_code: 200} = response), do: Jason.decode(response.body)

  defp decode(response) do
    {:error,
     %HTTPStatus{
       status_code: response.status_code,
       response: response
     }}
  end
end
