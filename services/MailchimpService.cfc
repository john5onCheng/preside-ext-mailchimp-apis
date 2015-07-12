component output=false singleton=true {

// CONSTRUCTOR
	/**
	 * @mailchimpAPIWrapperService.inject  mailchimpAPIWrapperService
	 * @mailchimpListDao.inject     presidecms:object:mailchimp_list
	 */


	public any function init(
		  required any mailchimpAPIWrapperService
		, required any mailchimpListDao
	 ) output=false {
		_setMailchimpListDao(    arguments.mailchimpListDao     );
		_setMailchimpAPIWrapperService( arguments.mailchimpAPIWrapperService  );

		return this;
	}

// PUBLIC API METHODS

	/*
	 * Description   : Get all mailchimp lists and store in preside mailchimp_list object
	 */
	public boolean function getAllListsToPreside( any logger ) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canInfo         = loggerAvailable && arguments.logger.canInfo();
		var canError        = loggerAvailable && arguments.logger.canError();

		var resultData      = [];
		var result          = _getMailchimpAPIWrapperService().listsList();
		var resultContent   = _processResult( result = result , logger = arguments.logger);

		if( StructKeyExists(result,"errorDetail") && result.errorDetail != "" ){
			if( canError ){
				arguments.logger.error( "Error processing getAllListsToPreside method. Error [#SerializeJson(resultContent.error)#]" );
			}
			return false;
		}

		if( structKeyExists( resultContent, "data" ) ){
			resultData      = resultContent.data;
		}

		if( arrayLen( resultData ) ){
			var itemData        = "";
			loop array="#resultData#" item="itemData"{
				var mailChimpData = {
					  id                  = itemData.id
					, web_id              = itemData.web_id
					, label               = itemData.name
					, member_count        = itemData.stats.member_count
					, unsubscribe_count   = itemData.stats.unsubscribe_count
				}

				if( !_getMailchimpListDao().dataExists( filter={ web_id = itemData.web_id } ) ){
					 _getMailchimpListDao().insertData( mailChimpData );
					 if ( canInfo ) { arguments.logger.info( "Added list (id: #itemData.id# ) #itemData.name# to preside" ); }
				}else{
					 _getMailchimpListDao().updateData( filter= { web_id = itemData.web_id  } , data = mailChimpData );
					 if ( canInfo ) { arguments.logger.info( "Updated list (id: #itemData.id# ) #itemData.name# to preside" ); }
				}
			}

			if ( canInfo ) { arguments.logger.info( "GET all mailchimp lists to preside completed" ); }

			return true;
		}

		return false;
	}

	/*
	 * Description   : SET subscriber to list
	 */
	public boolean function setSubscriber(
	      required struct  email
		, required string  listID
	    ,          struct  mergeVars
		,          string  emailType        = "html"
		,          boolean doubleOptIn      = false
		,          boolean updateExisting   = true
		,          boolean replaceInterests = false
		,          boolean sendWelcome      = false
		,          any     logger
	) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canInfo         = loggerAvailable && arguments.logger.canInfo();
		var canError        = loggerAvailable && arguments.logger.canError();

		var result          = _getMailchimpAPIWrapperService().listsSubscribe(
								  id                = arguments.listID
								, email             = arguments.email
								, merge_vars        = arguments.mergeVars
								, email_type        = arguments.emailType
								, double_optin      = arguments.doubleOptIn
								, update_existing   = arguments.updateExisting
								, replace_interests = arguments.replaceInterests
								, send_welcome      = arguments.sendWelcome
							);

		var resultContent    = _processResult( result = result , logger = arguments.logger);

		if( StructKeyExists(result,"errorDetail") && result.errorDetail != "" ){
			if( canError ){
				arguments.logger.error( "Error processing setSubscriber method. Error [#SerializeJson(resultContent.error)#]" );
			}
			return false;
		}

		if ( canInfo ) {
			var otherOptionalField = "Double Opt-In : #arguments.doubleOptIn#, Update Existing: #arguments.updateExisting#, Replace Interests = #arguments.replaceInterests#, Send Welcome = #arguments.sendWelcome#";
			arguments.logger.info( "SET Subscriber to Mailchimp:  #resultContent.email# completed. #otherOptionalField#" );
		}

		return true;
	}

	public boolean function setUnsubscriber(
		  required struct  email
		, required any     listID
		,          boolean deleteMember = false
		,          boolean sendGoodbye  = false
		,          boolean sendNotify   = false
		,          any     logger
	) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canInfo         = loggerAvailable && arguments.logger.canInfo();
		var canError        = loggerAvailable && arguments.logger.canError();

		var result          = _getMailchimpAPIWrapperService().listsUnsubscribe(
								  id               = arguments.listID
								, email            = arguments.email
								, delete_member    = arguments.deleteMember
								, send_goodbye     = arguments.sendGoodbye
								, send_notify      = arguments.sendNotify
							);

		var resultContent    = _processResult( result = result , logger = arguments.logger);

		if( StructKeyExists(result,"errorDetail") && result.errorDetail != "" ){
			if( canError ){
				arguments.logger.error( "Error processing setUnsubscriber method. Error [#SerializeJson(resultContent.error)#]" );
			}
			return false;
		}

		if ( canInfo ) {
			var otherOptionalField = "Send Goodbye : #arguments.sendGoodbye#, Send Notify: #arguments.sendNotify#";
			if( arguments.deleteMember ){
				arguments.logger.info( "Remove subscriber #SerializeJson(arguments.email)# from Mailchimp list status:  #resultContent.complete#, #otherOptionalField# " );
			}else{
				arguments.logger.info( "Unsubscribe #SerializeJson(arguments.email)# from Mailchimp list status:  #resultContent.complete#, #otherOptionalField# " );
			}
		}

		return true;
	}

// PRIVATE METHODS

	private any function _processResult( required struct result, any logger ) output=false {

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
	private any function _getMailchimpListDao() output=false {
		return _mailchimpListDao;
	}
	private void function _setMailchimpListDao( required any mailchimpListDao ) output=false {
		_mailchimpListDao = arguments.mailchimpListDao;
	}

	private any function _getMailchimpAPIWrapperService() output=false {
		return _mailchimpAPIWrapperService;
	}
	private void function _setMailchimpAPIWrapperService( required any mailchimpAPIWrapperService ) output=false {
		_mailchimpAPIWrapperService = arguments.mailchimpAPIWrapperService;
	}

}