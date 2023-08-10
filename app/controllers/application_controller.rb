class ApplicationController < ActionController::API
  rescue_from StandardError,                with: :internal_server_error
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def route404
    render json: { error: 'Invalid route' }, status: :not_found
  end

  private

  def not_found(exception)
    render json: { error: exception.message, text: 'Not Found' }, status: :not_found
  end

  def internal_server_error(exception)
    response = if Rails.env.development?
                 { type: exception.class.to_s, error: exception.message, text: 'Internal Server Error' }
               else
                 { error: 'Internal Server Error' }
               end
    render json: response, status: :internal_server_error
  end
end
