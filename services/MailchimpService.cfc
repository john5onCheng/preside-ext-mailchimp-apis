/**
*
*  WARNING: 2.0 is deprecated. Please upgrade your method to 3.0.
*  SEE MailchimpService3.cfc
*  Will keep this file until year 2020 only
*
* @singleton
*/
component  {

// CONSTRUCTOR
	/**
	 * @mailchimpAPIWrapperService.inject mailchimpAPIWrapperService3
	 * @mailchimpService.inject           mailchimpService3
	 * @mailchimpListDao.inject           presidecms:object:mailchimp_list
	 */


	public any function init(
		  required any mailchimpAPIWrapperService
		, required any mailchimpService
		, required any mailchimpListDao
	 ) {
		_setMailchimpListDao(           arguments.mailchimpListDao            );
		_setMailchimpService(           arguments.mailchimpService            );
		_setMailchimpAPIWrapperService( arguments.mailchimpAPIWrapperService  );

		return this;
	}

// PUBLIC API METHODS

	public boolean function getAllListsToPreside( any logger ) {
		return _getMailchimpService().getAllListsToPreside( logger );
	}

	public array function getMemberFromList( required string listID, string status,  any logger ) {
		var members = _getMailchimpService().getListMembers( listID=arguments.listID, status=arguments.status, exclude_fields="members._links,members.list_id", logger=arguments.logger );
		if( arrayLen( members ) ) {
			for( var member in members ){
				member['email'] = member['email_address'] ?: "";
				structDelete( member, "email_address" );
			}
		}
		return members;
	}

	public boolean function setSubscriber(
	      required struct  email
		, required string  listID
	    ,          struct  mergeVars
		,          string  emailType        = "html"
		,          boolean updateExisting   = true
		,          any     logger
	) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canInfo         = loggerAvailable && arguments.logger.canInfo();
		var canError        = loggerAvailable && arguments.logger.canError();
		var mergeVarsUCase  = {};

		var members = {
			  status        = "subscribed"
			, email_address = arguments.email.email
			, email_type    = arguments.emailType
		}

		if( !structIsEmpty( arguments.mergeVars ) ){
			for( var mVar in arguments.mergeVars ){
				mergeVarsUCase[ UCase( mVar ) ] = arguments.mergeVars[mVar];
			}
			members.merge_fields = mergeVarsUCase;
		}

		var result = _getMailchimpAPIWrapperService().batchSubscribeUnsubscribeListMember(
			  list_id         = arguments.listID
			, members         = [ members ]
			, update_existing = arguments.updateExisting
		);

		var resultContent     = _processResult( result=result , logger=arguments.logger );

		if( StructKeyExists( result,"errorDetail") && result.errorDetail != "" ){
			if( canError ){
				arguments.logger.error( "Error: [#SerializeJson(resultContent)#]" );
			}
			return false;
		}

		var success = ( resultContent.total_updated ?: 0 ) + ( resultContent.total_created ?: 0 );

		if ( canInfo && success ) {
			arguments.logger.info( "Subscribed #arguments.email.email# to mailchimp" );
		}

		if ( canError && arraylen( resultContent.errors ?: [] ) ) {
			arguments.logger.error( "#SerializeJson( resultContent.errors )#" );
		}

		return success;
	}

	public boolean function setUnsubscriber(
		  required struct  email
		, required any     listID
		,          boolean deleteMember = false
		,          any     logger
	) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canInfo         = loggerAvailable && arguments.logger.canInfo();
		var canError        = loggerAvailable && arguments.logger.canError();

		if( !arguments.deleteMember ){

			var members = {
				  status        = "unsubscribed"
				, email_address = arguments.email.email
			}

			var result = _getMailchimpAPIWrapperService().batchSubscribeUnsubscribeListMember(
				  list_id         = arguments.listID
				, members         = [ members ]
				, update_existing = true
			);

			var resultContent     = _processResult( result=result , logger=arguments.logger );

			if( StructKeyExists( result,"errorDetail") && result.errorDetail != "" ){
				if( canError ){
					arguments.logger.error( "Error: [#SerializeJson(resultContent)#]" );
				}
				return false;
			}

			var success = ( resultContent.total_updated ?: 0 ) + ( resultContent.total_created ?: 0 );

			if ( canInfo && success ) {
				arguments.logger.info( "Unsubscribed #arguments.email.email# to mailchimp" );
			}

			if ( canError && arraylen( resultContent.errors ?: [] ) ) {
				arguments.logger.error( "#SerializeJson( resultContent.errors )#" );
			}

			return success;

		} else {

			var result = _getMailchimpAPIWrapperService().deleteListMember(
				  list_id         = arguments.listID
				, subscriber_hash = hash( arguments.email.email )
			);

			var resultContent = _processResult( result=result , logger=arguments.logger );

			if( StructKeyExists( result,"errorDetail") && result.errorDetail != "" ){
				if( canError ){
					arguments.logger.error( "Error: [#SerializeJson(resultContent)#]" );
				}
				return false;
			}

			if ( canInfo && isEmpty( resultContent ) ) {
				arguments.logger.info( "Removed #arguments.email.email# from mailchimp" );
				return true;
			}

			return false;
		}

	}

	public boolean function setBatchSubscriber(
		  required array   batch
		, required any     listID
		,          boolean updateExisting = true
		,          any     logger
	) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canInfo         = loggerAvailable && arguments.logger.canInfo();
		var canError        = loggerAvailable && arguments.logger.canError();

		var refinedMembers = [];

		for( var member in arguments.batch ){
			var mergeVarsUCase = {};
			var refinedMember  = {
				  status        = "subscribed"
				, email_address = member.email.email
			}

			if( !structIsEmpty( member.merge_vars ) ){
				for( var mVar in member.merge_vars ){
					mergeVarsUCase[ UCase( mVar ) ] = member.merge_vars[mVar];
				}
				refinedMember.merge_fields = mergeVarsUCase;
			}

			arrayAppend( refinedMembers, refinedMember );
		}

		var result = _getMailchimpAPIWrapperService().batchSubscribeUnsubscribeListMember(
			  list_id         = arguments.listID
			, members         = refinedMembers
			, update_existing = arguments.updateExisting
		);

		var resultContent    = _processResult( result = result , logger = arguments.logger);

		if( StructKeyExists(result,"errorDetail") && result.errorDetail != "" ){
			if( canError ){
				arguments.logger.error( "Error processing setBatchSubscriber method. Error [#SerializeJson(resultContent.error)#]" );
			}

			return false;
		}

		if ( canInfo ) {
			arguments.logger.info( "Total new subscribed #( resultContent.total_created ?: 0 )#" );
			arguments.logger.info( "Total updated #( resultContent.total_updated ?: 0 )#" );
			arguments.logger.info( "Total error(s) #( resultContent.error_count ?: 0 )#" );
		}

		if ( canError && arraylen( resultContent.errors ?: [] ) ) {
			arguments.logger.error( "#SerializeJson( resultContent.errors )#" );
		}

		return true;

	}

	public boolean function setBatchUnsubscriber(
		  required array   batch
		, required any     listID
		,          boolean deleteMember = false
		,          any     logger
	) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canInfo         = loggerAvailable && arguments.logger.canInfo();
		var canError        = loggerAvailable && arguments.logger.canError();

		if( !arguments.deleteMember ){

			var refinedMembers = [];

			for( var member in arguments.batch ){
				arrayAppend( refinedMembers, {
					  status        = "unsubscribed"
					, email_address = member.email.email
				} );
			}

			var result = _getMailchimpAPIWrapperService().batchSubscribeUnsubscribeListMember(
				  list_id         = arguments.listID
				, members         = refinedMembers
				, update_existing = true
			);

			var resultContent     = _processResult( result=result , logger=arguments.logger );

			if( StructKeyExists( result,"errorDetail") && result.errorDetail != "" ){
				if( canError ){
					arguments.logger.error( "Error: [#SerializeJson(resultContent)#]" );
				}
				return false;
			}

			if ( canInfo ) {
				arguments.logger.info( "Total new subscribed #( resultContent.total_created ?: 0 )#" );
				arguments.logger.info( "Total updated #( resultContent.total_updated ?: 0 )#" );
				arguments.logger.info( "Total error(s) #( resultContent.error_count ?: 0 )#" );
			}

			if ( canError && arraylen( resultContent.errors ?: [] ) ) {
				arguments.logger.error( "#SerializeJson( resultContent.errors )#" );
			}

			return true;

		} else {

			for( var member in arguments.batch ){
				var result = _getMailchimpAPIWrapperService().deleteListMember(
					  list_id         = arguments.listID
					, subscriber_hash = hash( member.email.email )
				);
				var resultContent = _processResult( result=result , logger=arguments.logger );

				if( StructKeyExists( result,"errorDetail") && result.errorDetail != "" ){
					if( canError ){
						arguments.logger.error( "Error: [#SerializeJson(resultContent)#]" );
					}
				}

				if ( canInfo && isEmpty( resultContent ) ) {
					arguments.logger.info( "Removed #member.email.email# from mailchimp" );
				}
			}

			return true;
		}
	}


// PRIVATE METHODS

	private any function _processResult( required struct result, any logger ) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canInfo         = loggerAvailable && arguments.logger.canInfo();
		var canError        = loggerAvailable && arguments.logger.canError();

		var deserialized = {};

		try {
			if ( StructKeyExists( result, 'filecontent' ) ) {
				deserialized = DeserializeJson( result.filecontent );
			}
		} catch ( any e ) {
			if( canError ){
				arguments.logger.info( "Could not parse result from Mailchimp API Server. See detail for response. [ #result.filecontent#]" );
			}
		}

		return deserialized;

	}


// GETTERS AND SETTERS
	private any function _getMailchimpListDao() {
		return _mailchimpListDao;
	}
	private void function _setMailchimpListDao( required any mailchimpListDao ) {
		_mailchimpListDao = arguments.mailchimpListDao;
	}

	private any function _getMailchimpAPIWrapperService() {
		return _mailchimpAPIWrapperService;
	}
	private void function _setMailchimpAPIWrapperService( required any mailchimpAPIWrapperService ) {
		_mailchimpAPIWrapperService = arguments.mailchimpAPIWrapperService;
	}

	private any function _getMailchimpService() {
		return _mailchimpService;
	}
	private void function _setMailchimpService( required any mailchimpService ) {
		_mailchimpService = arguments.mailchimpService;
	}

}