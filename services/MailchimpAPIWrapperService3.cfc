/**
* @singleton
* @presideService
*/
component {

	function init() {
		return this;
	}

// PUBLIC API METHODS
	/*
	 * Method Name   : GET /lists
	 * Description   : Get information about all lists in the account
	 * Dcoumentation : http://developer.mailchimp.com/documentation/mailchimp/reference/lists/#read-get_lists
	 */
	public struct function getAllLists(
		  string  fields
		, string  exclude_fields
		, numeric count
		, numeric offset
		, string  before_date_created
		, string  since_date_created
		, string  before_campaign_last_sent
		, string  since_campaign_last_sent
		, string  email
		, string  sort_field
		, string  sort_dir
	) {
		return _call( uri="lists/" & _convertArgumentsToUri( arguments ) , method="GET" );
	}

	/*
	 * Method Name   : GET /lists/{list_id}/members
	 * Description   : Get information about members in a specific MailChimp list.
	 * Dcoumentation : http://developer.mailchimp.com/documentation/mailchimp/reference/lists/members/#read-get_lists_list_id_members
	 */
	public struct function getListMembers(
		  required string  list_id
		,          string  fields
		,          string  exclude_fields
		,          numeric count
		,          numeric offset
		,          string  email_type
		,          string  status
		,          string  since_timestamp_opt
		,          string  before_timestamp_opt
		,          string  since_last_changed
		,          string  before_last_changed
		,          string  unique_email_id
		,          string  vip_only
		,          string  interest_category_id
		,          string  interest_ids
		,          string  interest_match

	) {
		var methodName = "/lists/#arguments.list_id#/members";
		structDelete( arguments, "list_id" );
		return _call(
			  uri    = methodName & _convertArgumentsToUri( arguments )
			, method = "GET"
		 );
	}

	/*
	 * Method Name   : GET /lists/{list_id}/interest-categories/{interest_category_id}
	 * Description   : Get information about a specific interest category.
	 * Dcoumentation : http://developer.mailchimp.com/documentation/mailchimp/reference/lists/interest-categories/#read-get_lists_list_id_interest_categories_interest_category_id
	 */
	public struct function getListInterestCategories(
		  required string  list_id
		, required string  interest_category_id
		,          string  fields
		,          string  exclude_fields
	) {
		var methodName = "/lists/#arguments.list_id#/interest-categories/#arguments.interest_category_id#/interests";
		structDelete( arguments, "list_id" );
		structDelete( arguments, "interest_category_id" );
		return _call(
			  uri   = methodName & _convertArgumentsToUri( arguments )
			, method = "GET"
		 );
	}

	/*
	 * Method Name   : GET /lists/{list_id}/interest-categories
	 * Description   : Get information about a list’s interest categories.
	 * Dcoumentation : http://developer.mailchimp.com/documentation/mailchimp/reference/lists/interest-categories/#read-get_lists_list_id_interest_categories
	 */
	public struct function getListCategories(
		  required string  list_id
		,          string  fields
		,          string  exclude_fields
		,          numeric count
		,          numeric offset
		,          string  type
	) {
		var methodName = "/lists/#arguments.list_id#/interest-categories";
		structDelete( arguments, "list_id" );
		return _call(
			   uri   = methodName & _convertArgumentsToUri( arguments )
			, method = "GET"
		 );
	}

	/*
	 * Method Name   : POST /lists/{list_id}/interest-categories
	 * Description   : Create a new interest category.
	 * Dcoumentation : http://developer.mailchimp.com/documentation/mailchimp/reference/lists/interest-categories/#create-post_lists_list_id_interest_categories
	 */
	public struct function createNewInterestCategory(
		  required string  list_id
		, required string  title
		, required string  type
		,          numeric display_orders
	) {
		var methodName = "/lists/#arguments.list_id#/interest-categories";
		structDelete( arguments, "list_id" );

		return _call( uri=methodName, method="POST",  body=_convertArgumentsToJSON( arguments ) );
	}

	/*
	 * Method Name   : POST /lists/{list_id}/interest-categories/{interest_category_id}/interests
	 * Description   : Create a new interest or ‘group name’ for a specific category.
	 * Dcoumentation : http://developer.mailchimp.com/documentation/mailchimp/reference/lists/interest-categories/interests/#create-post_lists_list_id_interest_categories_interest_category_id_interests
	 */
	public struct function createNewInterest(
		  required string  list_id
		, required string  interest_category_id
		, required string  name
		,          numeric display_orders
	) {
		var methodName = "/lists/#arguments.list_id#/interest-categories/#arguments.interest_category_id#/interests";;
		structDelete( arguments, "list_id" );

		return _call( uri=methodName, method="POST",  body=_convertArgumentsToJSON( arguments ) );
	}

	/*
	 * Method Name   : POST /lists/{list_id}/segments
	 * Description   : Create a new segment in a specific list.
	 * Dcoumentation : http://developer.mailchimp.com/documentation/mailchimp/reference/lists/segments/#create-post_lists_list_id_segments
	 */
	public struct function createNewSegment(
		  required string list_id
		, required string name
		,          array  static_segment
		,          struct options
	) {
		var methodName = "/lists/#arguments.list_id#/segments";
		structDelete( arguments, "list_id" );

		return _call( uri=methodName, method="POST",  body=_convertArgumentsToJSON( arguments ) );
	}

	/*
	 * Method Name   : POST /lists/{list_id}
	 * Description   : Batch subscribe or unsubscribe list members.
	 * Dcoumentation : http://developer.mailchimp.com/documentation/mailchimp/reference/lists/#create-post_lists_list_id
	 */
	public struct function batchSubscribeUnsubscribeListMember(
		  required string  list_id
		, required array   members
		,          boolean update_existing
	) {
		var methodName = "/lists/#arguments.list_id#";
		structDelete( arguments, "list_id" );

		return _call( uri=methodName, method="POST",  body=_convertArgumentsToJSON( arguments ) );
	}

	/*
	 * Method Name   : POST /lists/{list_id}/members
	 * Description   : Add a new member to the list.
	 * Dcoumentation : http://developer.mailchimp.com/documentation/mailchimp/reference/lists/members/#create-post_lists_list_id_members
	 */
	public struct function addNewMemberToList(
		  required string  list_id
		, required string  email_address
		,          string  status
		,          string  email_type
		,          struct  merge_fields
		,          struct  interests
		,          struct  location
		,          string  language
		,          boolean vip
		,          string  ip_signup
		,          string  timestamp_signup
		,          string  ip_opt
		,          string  timestamp_opt
	) {
		var methodName = "/lists/#arguments.list_id#/members";
		structDelete( arguments, "list_id" );

		return _call( uri=methodName, method="POST",  body=_convertArgumentsToJSON( arguments ) );
	}

	/*
	 * Method Name   : DELETE /lists/{list_id}/members/{subscriber_hash}
	 * Description   : Delete a member from a list.
	 * Dcoumentation : http://developer.mailchimp.com/documentation/mailchimp/reference/lists/members/#delete-delete_lists_list_id_members_subscriber_hash
	 */
	public struct function deleteListMember(
		  required string  list_id
		, required string  subscriber_hash
	) {
		var methodName = "/lists/#arguments.list_id#/members/#arguments.subscriber_hash#";
		return _call( uri=methodName, method="DELETE" );
	}

// PRIVATE METHODS
	private string function _convertArgumentsToUri( required struct parameters ) {

		var parameterString = "?apikey=" & _getAPIkey() ;

		for( var key in arguments.parameters ){
			if( !isNull( arguments.parameters[key] ) ) {
				parameterString &=  "&#key#=#arguments.parameters[key]#";
			}
		}

		return  parameterString;
	}

	private string function _convertArgumentsToJSON( required struct parameters ) {
		var cleanArguments = structNew();

		for( var key in arguments.parameters ){
			if( !isNull( arguments.parameters[key] ) ) {
				cleanArguments['#key#'] = arguments.parameters[key];
			}
		}

		return SerializeJson( cleanArguments );
	}

	private any function _call( required string method, required string uri, string body ) {
		var result        = "";
		var success       = false;
		var attempts      = 0;
		var maxAttempts   = 3;
		var endpoint      = _getAPIEndpoint() & arguments.uri;

		while( !success && attempts < maxAttempts ) {
			try {
				http url=endpoint method=arguments.method result="result" charset="UTF-8" getAsBinary="yes" timeout=30 {
					if ( StructKeyExists( arguments, "body" ) ) {
						httpparam type="body" value=arguments.body;
						httpparam type="header" name="Content-Type"    value="application/json;";
					}
					if( arguments.method!="GET" ){
						httpparam type="header" name="Authorization"   value="Basic " & ToBase64("apikey:#_getAPIkey()#");
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
	) {

		throw( type=arguments.type, message=arguments.message, detail=arguments.detail, errorcode=arguments.errorCode );
	}

// GETTERS AND SETTERS
	private string function _getAPIkey() {
		return listFirst(_getFullAPIKey(),'-');
	}

	private string function _getFullAPIkey() {
		return $getSystemConfigurationService().getSetting('mailchimp','api_key');
	}

	private string function _getAPIEndpoint() {
		var apiVersion = "3.0";
		var apiDC      = listLast(_getFullAPIKey(),'-');
		return  "https://#apiDC#.api.mailchimp.com/#apiVersion#/";
	}

}