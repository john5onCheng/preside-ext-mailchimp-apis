component output=false singleton=true {

// CONSTRUCTOR
	/**
	 * @systemConfigurationService.inject  systemConfigurationService
	 *
	 */


	public any function init(
		  required any systemConfigurationService
	 ) output=false {
		_setSystemConfigurationService( arguments.systemConfigurationService  );

		return this;
	}

// PUBLIC API METHODS

	/*
	 * Method Name   : lists/list
	 * Description   : Retrieve all of the lists defined for your user account
	 * Dcoumentation : https://apidocs.mailchimp.com/api/2.0/lists/list.php
	 */
	public struct function listsList(
		           struct  filters
		,          numeric start
		,          numeric limit
		,          string  sort_field
		,          string  sort_dir
	) {
		var uri = "?apikey=" & _getAPIkey() & _convertArgumentsToUri( arguments );

		return _call(
						  uri    = "lists/list" & uri
						, method = "GET"
					 );
	}

	/*
	 * Method Name   : lists/members
	 * Description   : Get all of the list members for a list that are of a particular status and potentially matching a segment.
	 * Dcoumentation : https://apidocs.mailchimp.com/api/2.0/lists/members.php
	 */
	public struct function listsMembers(
		 required string  id
	   ,          string  status
	   ,          struct  opts
	) {
		var uri = "?apikey=" & _getAPIkey() & _convertArgumentsToUri( arguments );

		return _call(
						  uri    = "lists/members" & uri
						, method = "GET"
					 );
	}


	/*
	 * Method Name   : lists/subscribe
	 * Description   : Subscribe the provided email to a list. By default this sends a confirmation email - you will not see new members until the link contained in it is clicked!
	 * Dcoumentation : https://apidocs.mailchimp.com/api/2.0/lists/subscribe.php
	 */
	public struct function listsSubscribe(
	        required string  id
	      , required struct  email
	      ,          struct  merge_vars
	      ,          string  email_type
	      ,          string  double_optin
	      ,          boolean update_existing
	      ,          boolean replace_interests
	      ,          boolean send_welcome
	) {
		arguments.apikey = _getAPIkey();

		return _call( uri = "lists/subscribe", method="POST",  body = SerializeJson(arguments) );;
	}


	/*
	 * Method Name   : lists/unsubscribe
	 * Description   : Unsubscribe or remove the given email address from the list
	 * Dcoumentation : https://apidocs.mailchimp.com/api/2.0/lists/subscribe.php
	 */
	public struct function listsUnsubscribe(
	        required string  id
	      , required struct  email
	      ,          boolean delete_member
	      ,          boolean send_goodbye
	      ,          boolean send_notify
	) {
		arguments.apikey = _getAPIkey();

		return _call( uri = "lists/unsubscribe", method="POST",  body = SerializeJson(arguments) );;
	}


// PRIVATE METHODS

	private string  function _convertArgumentsToUri( required struct argumentStruct ) {
		var uri = "";

		for( var key in arguments.argumentStruct ){
			if( !isNull(arguments.argumentStruct[key]) ) {
				uri = '&#body[key]#=arguments.argumentStruct[key]';
			}
		}

		return uri;
	}


	private any function _call( required string method, required string uri, string body ) output=false {
		var result        = "";
		var success       = false;
		var attempts      = 0;
		var maxAttempts   = _getNullResponseRetryAttempts();
		var endpoint      = _getAPIEndpoint() & arguments.uri;
		var apiKey        = _getAPIkey();

		while( !success && attempts < maxAttempts ) {
			try {

				http url=endpoint method=arguments.method result="result" charset=_getCharset() getAsBinary="yes" timeout=_getRequestTimeoutInSeconds() {
					if ( StructKeyExists( arguments, "body" ) ) {
						httpparam type="body" value=arguments.body;
						httpparam type="header" name="Content-Type" value="application/json; charset=#_getCharset()#";
					}
				};

				success =  Len( Trim( result.responseHeader.status_code ?: "" ) );
			} catch( any e ) {
				success = false;
			}

			if ( !success ) {
				attempts++;
			}
		}

		if ( !success ) {
			_throw(
				  type      = "mailchimpAPI.communicationError"
				, message   = "Made #attempts# attempts to contact Mailchimp API server but none returned a response"
			);
		}

		return result;
	}

	private void function _throw(
		  string type      = "MailchimpApiWrapper.unknown"
		, string message   = ""
		, string detail    = ""
		, string errorCode = ""
	) output=false {

		throw( type=arguments.type, message=arguments.message, detail=arguments.detail, errorcode=arguments.errorCode );
	}


// GETTERS AND SETTERS
	private string function _getCharset() output=false {
		return _getSystemConfigurationService().getSetting( "elasticsearch", "charset", "UTF-8" );
	}

	private string function _getAPIkey() output=false {
		return listFirst(_getFullAPIKey(),'-');
	}

	private string function _getFullAPIkey() output=false {
		return _getSystemConfigurationService().getSetting('mailchimp','api_key');
	}

	private string function _getAPIEndpoint() output=false {
		var apiVersion = _getSystemConfigurationService().getSetting('mailchimp','api_version','2.0');
		var apiDC      = listLast(_getFullAPIKey(),'-');
		return  "https://#apiDC#.api.mailchimp.com/#apiVersion#/";
	}

	private any function _getSystemConfigurationService() output=false {
		return _systemConfigurationService;
	}
	private void function _setSystemConfigurationService( required any systemConfigurationService ) output=false {
		_systemConfigurationService = arguments.systemConfigurationService;
	}

	private numeric function _getRequestTimeoutInSeconds() output=false {
		return _getSystemConfigurationService().getSetting( "mailchimp", "api_call_timeout", 30 );
	}

	private numeric function _getNullResponseRetryAttempts() output=false {
		return _getSystemConfigurationService().getSetting( "mailchimp", "retry_attempts", 3 );
	}


}