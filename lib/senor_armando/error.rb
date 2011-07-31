require 'goliath/validation/standard_http_errors'
require 'goliath/validation/error'
require 'gorillib/metaprogramming/class_attribute'

module Goliath
  module Validation

    #
    # Style guide:
    #
    # * be careful about interpolating messages into the error response.
    #   Escape anything that might lead to an injection attack.
    # * To quote text, use {}. For example,
    #      raise Apeyeye::ApiCallNotFoundError, "There is no api call at {#{request.path}}. Check the catalog at http://infochimps.com/api to ensure the path is correct. If there is a mismatch, please email help@infochimps.com."
    #   which leads eventually to
    #      {"error":"ApiCallNotFoundError","message":"There is no api call at {/describe/encyclopedic/freebase/list}. Check the catalog at http://infochimps.com/api to ensure the path is correct. If there is a mismatch, please email help@infochimps.com.","status":404}
    #   This is less likely to result in an injection attack, and means that the error is directly parseable.
    #
    # Good error messages have
    #
    # * A problem. States that a problem occurred.
    # * A cause. Explains why the problem occurred.
    # * A solution. Provides a solution so that users can fix the problem.
    #
    # * Relevant      - The message presents a problem that users care about.
    # * Actionable    - Users should either perform an action or change their behavior as the result of the message.
    # * User-centered - The message describes the problem in terms of target user actions or goals, not in terms of what the code is unhappy with.
    # * Brief         - The message is as short as possible, but no shorter.
    # * Clear         - The message uses plain language so that the target users can easily understand problem and solution.
    # * Specific      - The message describes the problem using specific language, giving specific names, locations, and values of the objects involved.
    # * Courteous     - Users shouldn't be blamed or made to feel stupid.
    # * Rare          - Displayed infrequently. Frequently displayed error messages are a sign of bad design.
    #

    # All endpoints must succeed (the given value is
    # returned), or fail (with the
    class Error
      class_attribute :description
      self.description = "Unspecified internal error"
    end

    #
    # Not Found (404) errors
    #
    #
    # Requested item not found:
    # * item isn't in the database, and thus doesn't exist.
    # * item isn't in the database, but might exist
    # Some calls distinguis

    class NotFoundMightBeThereThoughError < NotFoundError
      self.description = "Might not exist, or we might not have it yet. We'll have our robomonkey scrapers check it out."
    end

    class ApiCallNotFoundError < NotFoundError
      self.description = "No endpoint listening at that path. See listing at http://infochimps.com/api"
    end

    #
    # Bad Request (400) Errors
    #
    # Request is ill-formed. Why?
    # * Route doesn't exist
    # * Wrong method (POST, GET, etc)
    # * Validations:
    #   - missing one or more required params
    #   - wrong type for one or more params

    # The request was valid, everything about *handling* the call seemed to go
    # right, but the call itself failed: eg api call to parse the date "Feb 31
    # 2013"
    class RequestProcessError   < BadRequestError
      self.description = "The request was valid, everything about *handling* the call seemed to go right, but the call itself failed. Missing parameters - please check the documentation at http://infochimps.com/api or email help@infochimps.com"
    end

    # Supplied parameters fail validation
    class RequestValidationError < BadRequestError
      self.description = "Invalid parameters - please check the documentation at http://infochimps.com/api or email help@infochimps.com"
    end

    # User did not provide all the of the necessary parameters to complete the call
    class RequiredParamMissingError < RequestValidationError
      self.description = "Missing parameters - please check the documentation at http://infochimps.com/api or email help@infochimps.com"
    end


    #
    # Unauthorized (401) Errors
    #
    # User isn't authorized for this call. Why?
    #
    # * No API key provided.
    # * API key isn't found
    # * API key is found, but disabled or expired
    #
    # Spec says: "Similar to 403 Forbidden, but specifically for use when
    # authentication is possible but has failed or not yet been provided." Even
    # not specifically stated in HTTP spec, the common practice is 401 - For
    # authentication error 403 - For authorization error.
    #
    # We do NOT respond with unauthorized for the following:
    #
    # * API key is fine, but user needs to agree to the license for this call (this is a 403)
    # * Access to eg a protected twitter user (the data is scrubbed from our DB)
    #

    class MissingApikeyError < UnauthorizedError
      self.description = "No _apikey parameter supplied"
    end

    class ApikeyNotFoundError < UnauthorizedError
      self.description = "The _apikey supplied is not in our records. Visit http://infochimps.com/api to register, or email help@infochimps.com"
    end

    #
    # Payment Required (402) Errors
    #
    #

    class AccountBalanceError < PaymentRequiredError
      self.description = "Account limit hit. Please visit your user dashboard on http://infochimps.com or email help@infochimps.com"
    end

    #
    # Forbidden / Rate Limit / NeedsLicense (403) Errors
    #
    #   "The request was a legal request, but the server is refusing to respond to
    #   it. Unlike a 401 Unauthorized response, authenticating will make no
    #   difference."
    #

    # Too many calls for their account level
    class RateLimitExceededError < ForbiddenError
      self.description = "Rate limit exceeded. Please visit http://infochimps.com to increase your user plan, or email help@infochimps.com"
    end

    # Too many ip addresses for their account level
    class IpLimitExceededError < ForbiddenError
      self.description = "Remote host limit exceeded: too many distinct IPs this hour. Please visit http://infochimps.com to increase your user plan, or email help@infochimps.com"
    end

    # apikey is valid, but user needs to click a license or put some $$ down to use this call
    class UserNeedsLicenseError < ForbiddenError
      self.description = "This api call requires a license agreement. Visit http://infochimps.com/api to register, or email help@infochimps.com"
    end

    #
    # Internal Server Errors (500)
    #
    # Errors that are not the fault of the user. Apologize and give them the
    # emergency contact info.

    # The database is not responding, or something. Not the user's fault.
    class DatabaseOnFireError  < InternalServerError
      self.description = "Database on fire! This call failed -- but it's us, not you. Please email help@infochimps.com if this keeps happening."
    end

    # The request succeeded but processing it failed
    class MethodFailedError  < InternalServerError
      self.description = "Request failed"
    end

  end

  #
  # Maps each standard HTTP error code (4xx and 5xx) to a subclass of
  # Goliath::Validation::Error. The error will have the status_code and
  # message correct for that response:
  #
  #     HTTP_ERRORS[400]
  #     # Goliath::Validation::NotFoundError
  #
  # Each class is named for the standard HTTP message, so 504 'Gateway Time-out'
  # becomes a Goliath::Validation::GatewayTimeoutError (except 'Internal Server
  # Error', which becomes InternalServerError not InternalServerErrorError). All non-alphanumeric
  # characters are smushed together, with no upcasing or
  # downcasing.
  #
  HTTP_ERRORS = {}

  HTTP_ERROR_CODES.each do |code, msg|
    klass_name = "#{msg.gsub(/\W+/, '')}Error".gsub(/ErrorError$/, "Error")
    klass = Goliath::Validation.const_get(klass_name)
    HTTP_ERRORS[code] = klass
    klass.description = msg
  end

end
