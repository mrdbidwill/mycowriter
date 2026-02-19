class ApiKeysController < ApplicationController
  before_action :authenticate_user!
  before_action :set_api_key, only: [ :destroy ]

  def index
    @api_keys = current_user.api_keys.order(created_at: :desc)
  end

  def create
    @api_key = current_user.api_keys.new(api_key_params)

    if @api_key.save
      flash[:notice] = "API key created successfully. Make sure to copy it now - you won't be able to see it again!"
      redirect_to api_keys_path
    else
      flash[:alert] = "Error creating API key: #{@api_key.errors.full_messages.join(', ')}"
      redirect_to api_keys_path
    end
  end

  def destroy
    @api_key.revoke!
    flash[:notice] = "API key revoked successfully."
    redirect_to api_keys_path
  end

  private

  def set_api_key
    @api_key = current_user.api_keys.find(params[:id])
  end

  def api_key_params
    params.require(:api_key).permit(:name, :expires_at)
  end
end
