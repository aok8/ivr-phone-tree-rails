require 'twilio-ruby'
require 'sanitize'

class TwilioController < ApplicationController
  


  def index
    render text: "Dial Me."
  end

  # POST ivr/welcome
  def ivr_welcome
    response = Twilio::TwiML::VoiceResponse.new
    gather = Twilio::TwiML::Gather.new(num_digits: '1', action: menu_path)
    gather.say("Thanks for calling the Household Phone Service. Please press 1 for
    information and instructions. Press 2 to be transfered to the next available number", loop: 3)
    response.append(gather)

    render xml: response.to_s
  end

  # GET ivr/selection
  def menu_selection
    user_selection = params[:Digits]

    case user_selection
    when "1"
      @output = "This phone routing service is to make reaching the most available responsible party."
      twiml_say(@output, true)
    when "2"
      phone_tree
    else
      @output = "Returning to the main menu."
      twiml_say(@output)
    end

  end

  private


  def twiml_say(phrase, exit = false)
    # Respond with some TwiML and say something.
    # Should we hangup or go back to the main menu?
    response = Twilio::TwiML::VoiceResponse.new do |r|
      r.say(phrase, voice: 'alice', language: 'en-GB')
      if exit
        r.say("Thanks for calling the Household Phone Service.")
        r.hangup
      else
        r.redirect(welcome_path)
      end
    end

    render xml: response.to_s
  end

  def twiml_dial(phone_number)
    response = Twilio::TwiML::VoiceResponse.new do |r|
      r.dial(number: phone_number)
    end

    render xml: response.to_s
  end
end

def phone_tree
  numbers = []
  names = []
  
  response = Twilio::TwiML::VoiceResponse.new
  response.say("Connecting you to #{names[i]}.")
  response.dial(number: numbers[i],
                action: "/ivr/welcome")
  render xml: response.to_s
end

