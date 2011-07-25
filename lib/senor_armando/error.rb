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
end