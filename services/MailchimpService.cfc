component output=false singleton=true {

// CONSTRUCTOR
	/**
	 * @mailchimpListDao.inject  presidecms:object:mailchimp_list
	 * @sysConfigService.inject  systemConfigurationService
	 */


	public any function init(
		  required any mailchimpListDao
		, required any sysConfigService
	 ) output=false {
		_setMailchimpListDao( arguments.mailchimpListDao  );
		_setSysConfigService( arguments.sysConfigService  );
		_setFullAPIKey();
		_setAPIKey();
		_setAPIDC();
		_setAPIVersion();
		_setServiceURL();

		return this;
	}

// PUBLIC API METHODS

	/*
	 * Method Name   : lists/list
	 * Description   : Get all mailchimp lists and store in preside mailchimp_list object
	 */
	public boolean function syncMailchimpList( any logger ) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canInfo         = loggerAvailable && arguments.logger.canInfo();

		var methodName      = "lists/list";
		var dataArray       = _getMailChimpData( methodName = methodName, logger = arguments.logger );
		var itemData        = "";

		if( arrayLen( dataArray ) ){

			loop array="#dataArray#" item="itemData"{
				var mailChimpData = {
					  web_id              = itemData.web_id
					, mailchimp_list_id   = itemData.id
					, label               = itemData.name
					, member_count        = itemData.stats.member_count
					, unsubscribe_count   = itemData.stats.unsubscribe_count
				}

				if( !_getMailchimpListDao().dataExists( filter={ web_id = itemData.web_id } ) ){
					 _getMailchimpListDao().insertData( mailChimpData );
					 if ( canInfo ) { arguments.logger.info( "Added (id: #itemData.id# ) #itemData.name# to preside" ); }
				}else{
					 _getMailchimpListDao().updateData( filter= { web_id = itemData.web_id  } , data = mailChimpData );
					 if ( canInfo ) { arguments.logger.info( "Updated (id: #itemData.id# ) #itemData.name# to preside" ); }
				}
			}

			if ( canInfo ) { arguments.logger.info( "Sync mailchimp list to preside completed" ); }

			return true;
		}

		return false;
	}


	/*
	 * Method Name   : lists/subscribe
	 * Description   : Subscribe the given email address from the list
	 *
	 * user              - Required. User's detail with email_address to subscribe
	 * e.g. user { email_address: 'johnson.cheng@pixl8.co.uk',first_name : 'johnson', last_name : 'cheng'  }
	 *
	 * listID            - Required. The list id to connect to
	 * emailType         - Optional. Email type preference for the email (html or text - defaults to html)
	 * doubleOptIn       - Optional. Flag to control whether a double opt-in confirmation message is sent, defaults to true. Abusing this may cause your account to be suspended
	 * updateExisting    - Optional. Flag to control whether existing subscribers should be updated instead of throwing an error
	 * replaceInterests  - Optional. Flag to determine whether we replace the interest groups with the groups provided or we add the provided groups to the member's interest groups
	 * sendWelcome       - Optional. If your doubleOptIn is false and this is true, we will send your lists Welcome Email if this subscribe succeeds - this will *not* fire if we end up updating an existing subscriber. If doubleOptIn is true, this has no effect
	 */
	public boolean function setNewSubscriber(
	      required struct  user
		, required any     listID
		,          string  emailType        = "html"
		,          boolean doubleOptIn      = false
		,          boolean updateExisting   = true
		,          boolean replaceInterests = false
		,          boolean sendWelcome      = false
		,          any     logger
	) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canError        = loggerAvailable && arguments.logger.canError();
		var canInfo         = loggerAvailable && arguments.logger.canInfo();

		var methodName      = "lists/subscribe";

		var serviceURL      = _getServiceURL() & methodName;

		var emailAddress    = arguments.user.email_address ?: "";
		var firstName       = arguments.user.first_name    ?: "";
		var lastName        = arguments.user.last_name     ?: "";

		http url ="#serviceURL#" method="post" name="list"{
			httpparam name="apikey"                              value=_getAPIKey()                 type="url";
			httpparam name="id"                                  value=arguments.listID             type="url";
			httpparam name="email[email]"                        value="#emailAddress#"             type="formfield";
			httpparam name="merge_vars[fname]"                   value="#firstName#"                type="formfield";
			httpparam name="merge_vars[lname]"                   value="#lastName#"                 type="formfield";
			httpparam name="email_type"                          value='#arguments.emailType#'      type="url";
			httpparam name="double_optin"                        value=arguments.doubleOptIn        type="url";
			httpparam name="update_existing"                     value=arguments.updateExisting     type="url";
			httpparam name="replace_interests"                   value=arguments.replaceInterests   type="url";
			httpparam name="send_welcome"                        value=arguments.sendWelcome        type="url";
		}

		var result = DeserializeJSON(cfhttp.filecontent);

		if( StructKeyExists(cfhttp,"errorDetail") && cfhttp.errorDetail != "" ){
			if( canError ){
				arguments.logger.error( "Error running method: #methodName#. Error [#SerializeJson( result.error )#]" );
				return false;
			}
		}


		if ( canInfo ) { arguments.logger.info( "Subscriber SET to Mailchimp:  #result.email#" ); }

		return true;
	}


	/*
	 * Method Name   : lists/unsubscribe
	 * Description   : Unsubscribe or remove the given email address from the list
	 *
	 * email         - Required. Email to unsubscribe
	 * listID        - Required. The list id to connect to
	 * sendGoodbye   - Optional. Flag to send the goodbye email to the email address
	 * sendNotify    - Optional. Flag to send the unsubscribe notification email to the address defined in the list email notification settings
	 * deleteMember  - Optional. Flag to completely delete the member from your list instead of just unsubscribing
	 */
	public boolean function setUnsubscriber(
		  required string  email
		, required any     listID
		,          boolean deleteMember = false
		,          boolean sendGoodbye  = false
		,          boolean sendNotify   = false
		,          any     logger
	) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canError        = loggerAvailable && arguments.logger.canError();
		var canInfo         = loggerAvailable && arguments.logger.canInfo();

		var methodName      = "lists/unsubscribe";

		var serviceURL      = _getServiceURL() & methodName;

		var emailAddress    = arguments.email ?: "";

		http url ="#serviceURL#" method="post" name="list"{
			httpparam name="apikey"             value=_getAPIKey()           type="url";
			httpparam name="id"                 value=arguments.listID       type="url";
			httpparam name="email[email]"       value="#emailAddress#"       type="formfield";
			httpparam name="delete_member"      value=arguments.deleteMember type="url";
			httpparam name="send_goodbye"       value=arguments.sendGoodbye  type="url";
			httpparam name="send_notify"        value=arguments.sendNotify   type="url";
		}

		var result = DeserializeJSON(cfhttp.filecontent);

		if( StructKeyExists(cfhttp,"errorDetail") && cfhttp.errorDetail != "" ){
			if( canError ){
				arguments.logger.error( "Error running method: #methodName#. Error [#SerializeJson( result.error )#]" );
				return false;
			}
		}

		if ( canInfo ) {
			var otherOptionalField = "Send Goodbye : #arguments.sendGoodbye#, Send Notify: #arguments.sendNotify#";
			if( arguments.deleteMember ){
				arguments.logger.info( "Remove subscriber #emailAddress# from Mailchimp list status:  #result.complete#, #otherOptionalField# " );
			}else{
				arguments.logger.info( "Unsubscribe #emailAddress# from Mailchimp list status:  #result.complete#, #otherOptionalField# " );
			}
		}

		return true;
	}


	/*
	 * Method Name   : lists/members
	 * Description   : Get all unsubscriber from list
	 *
	 * listID        - Required. The list id to connect to
	 */
	public array function getUnsubscriberList( required string listID,  any logger ) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canInfo         = loggerAvailable && arguments.logger.canInfo();

		var methodName      = "lists/members";

		return  _getMailChimpData( methodName = methodName, logger = arguments.logger, args = { status="unsubscribed", id = arguments.listID } );
	}


// PRIVATE METHODS
	private array function _getMailChimpData( required string methodName, any logger, struct args = {} ) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canError        = loggerAvailable && arguments.logger.canError();
		var canInfo         = loggerAvailable && arguments.logger.canInfo();

		var serviceURL = _getServiceURL() & arguments.methodName;

		if ( canInfo ) { arguments.logger.info( "Retreiving by method #methodName#" ); }

		http url ="#serviceURL#" method="get" name="list"{
			httpparam name="apikey" value=_getAPIKey()     type="url";
			for( var key in arguments.args ){
				httpparam name="#key#"     value=arguments.args[key] type="url";
			}
		}

		var result = DeserializeJSON(cfhttp.filecontent);

		if( StructKeyExists(cfhttp,"errorDetail") && cfhttp.errorDetail != "" ){
			if( canError ){
				arguments.logger.error( "Error running method: #methodName#. Error [#SerializeJson( result.error )#]" );
				return arrayNew(1);
			}
		}

		return result.data;
	}


// GETTERS AND SETTERS
	private any function _getMailchimpListDao() output=false {
		return _mailchimpListDao;
	}
	private void function _setMailchimpListDao( required any mailchimpListDao ) output=false {
		_mailchimpListDao = arguments.mailchimpListDao;
	}

	private any function _getFullAPIkey() output=false {
		return _apiFullKey;
	}
	private void function _setFullAPIKey() output=false {
		_apiFullKey = _getSysConfigService().getSetting('mailchimp','api_key');
	}

	private any function _getAPIkey() output=false {
		return _apiKey;
	}
	private void function _setAPIKey() output=false {
		_apiKey = listFirst(_getFullAPIKey(),'-');
	}

	private any function _getAPIDC() output=false {
		return _apiDc;
	}
	private void function _setAPIDC() output=false {
		_apiDc =  listLast(_getFullAPIKey(),'-');
	}

	private any function _getAPIVersion() output=false {
		return _apiVersion;
	}
	private void function _setAPIVersion() output=false {
		_apiVersion = _getSysConfigService().getSetting('mailchimp','api_version','2.0');
	}

	private any function _getServiceURL() output=false {
		return _serviceURL;
	}
	private void function _setServiceURL() output=false {
		_serviceURL =   "https://#_getAPIDC()#.api.mailchimp.com/#_getAPIVersion()#/";
	}

	private any function _getSysConfigService() output=false {
		return _sysConfigService;
	}
	private void function _setSysConfigService( required any sysConfigService ) output=false {
		_sysConfigService = arguments.sysConfigService;
	}

}