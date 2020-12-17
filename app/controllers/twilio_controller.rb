require 'twilio-ruby'
require 'sanitize'
require 'phones'
include PhoneNumbers
@voice = 'alice'
@language = 'en-GB'
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
      twiml_say(@output, false)
    when "2"
      phone_tree(0)
    else
      @output = "Returning to the main menu."
      twiml_say(@output)
    end

  end

  
  def next_caller
    @numbers = LIST['list-1']
    @number = params[:num].to_i
    if @number < @numbers.length
      Rails.logger.warn "New Call ##{@numbers[@number]}"
      response = Twilio::TwiML::VoiceResponse.new
      response.say("Connecting you to next available reciever.", voice: @voice, language: @language)
      response.dial(number: @numbers[@number],
                    action: "/ivr/next_caller/#{@number+1}")
      render xml: response.to_s
    else
      response = Twilio::TwiML::VoiceResponse.new
      response.say("Thanks for calling the Household Phone Service. Goodbye.", voice: @voice, language: @language)
      response.hangup
      render xml: response.to_s
    end
  end  

  private


  def twiml_say(phrase, exit = false)
    # Respond with some TwiML and say something.
    # Should we hangup or go back to the main menu?
    response = Twilio::TwiML::VoiceResponse.new do |r|
      r.say(phrase, voice: @voice, language: @language)
      if exit
        r.say("Thanks for calling the Household Phone Service.", voice: @voice, language: @language)
        r.hangup
      else
        r.redirect(welcome_path)
      end
    end

    render xml: response.to_s
  end
  
  def phone_tree(reciever_number)
    @numbers = LIST['list-1']
    response = Twilio::TwiML::VoiceResponse.new
    response.say("Connecting you to next available reciever.", voice: @voice, language: @language)
    Rails.logger.warn "New Call ##{@numbers[reciever_number]}"
    response.dial(number: @numbers[reciever_number],
                  action: "/ivr/next_caller/#{reciever_number+1}")
    render xml: response.to_s
  end

end