Rails.application.routes.draw do

  # Root of the app
  root 'twilio#index'

  # webhook for your Twilio number
  match 'ivr/welcome' => 'twilio#ivr_welcome', via: [:get, :post], as: 'welcome'

  # callback for user entry
  match 'ivr/selection' => 'twilio#menu_selection', via: [:get, :post], as: 'menu'

  # callback for phone tree
  match 'ivr/next_caller/:num' => 'twilio#next_caller', via: [:get, :post], as: 'number'
end
