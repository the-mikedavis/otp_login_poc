defmodule One.Authentication do
  @moduledoc """
  Provides an interface for authenticating one time passwords
  """

  alias OneTimePassEcto.Base, as: OTP

  @secret_length 32
  @interval [interval_length: 300]

  @spec generate() :: {String.t(), String.t()}
  def generate do
    # ideally we store the secret in some sort of persistence (either database
    # or event stream)
    secret = OTP.gen_secret(@secret_length)
    otp = OTP.gen_totp(secret, @interval)

    {secret, otp}
  end

  @spec authenticate({String.t(), String.t()}) :: boolean()
  def authenticate({secret, maybe_otp}) do
    OTP.check_totp(maybe_otp, secret, @interval)
  end

  import Ecto.Changeset
  use Ecto.Schema

  embedded_schema do
    field(:password, :string)
    field(:secret, :string)
  end

  def changeset do
    {secret, otp} = generate()

    changeset(%{secret: secret, password: otp})
  end

  def changeset(%__MODULE__{} = transaction \\ %__MODULE__{}, %{} = attrs) do
    transaction
    |> cast(attrs, __schema__(:fields))
    |> validate_required(__schema__(:fields) -- [:id])
    |> validate_one_time_password()
  end

  @error_msg "One time password did not verify! Please check the password and try again."

  def validate_one_time_password(changeset) do
    validate_change(changeset, :password, fn :password, password ->
      secret = get_field(changeset, :secret)

      if authenticate({secret, password}) do
        []
      else
        [password: @error_msg]
      end
    end)
  end
end
