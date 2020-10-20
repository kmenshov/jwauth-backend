class JwauthTestController < ApplicationController
  include Jwauth

  def index
    head :ok
  end

  def session_source_data
    { 'session' => 'Data to send' }
  end
end
