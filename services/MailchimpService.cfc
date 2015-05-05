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
		_setListID();
		_setAPIDC();
		_setAPIVersion();
		_setServiceURL();

		return this;
	}

// PUBLIC API METHODS
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

	public boolean function syncNewSubscriberToMailChimp( required struct user, any logger ) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canError        = loggerAvailable && arguments.logger.canError();
		var canInfo         = loggerAvailable && arguments.logger.canInfo();

		var methodName      = "lists/subscribe";

		var serviceURL      = _getServiceURL() & methodName;

		var emailAddress    = arguments.user.email_address ?: "";
		var firstName       = arguments.user.first_name    ?: "";
		var lastName        = arguments.user.last_name     ?: "";

		http url ="#serviceURL#" method="post" name="list"{
			httpparam name="apikey"                              value=_getAPIKey()        type="url";
			httpparam name="id"                                  value=_getListID()        type="url";
			httpparam name="double_optin"                        value=false               type="url";
			httpparam name="update_existing"                     value=true                type="url";
			httpparam name="replace_interests"                   value=false               type="url";
			httpparam name="email[email]"                        value="#emailAddress#"    type="formfield";
			httpparam name="merge_vars[fname]"                   value="#firstName#"       type="formfield";
			httpparam name="merge_vars[lname]"                   value="#lastName#"        type="formfield";
		}

		if( StructKeyExists(cfhttp,"errorDetail") && cfhttp.errorDetail != "" ){
			if( canError ){
				arguments.logger.error( "Error running method: #methodName#. Error statusCode: #cfhttp.error.statusCode#. Error detail: #cfhttp.error.errorDetail#" );
				return arrayNew(1);
			}
		}

		var result = DeserializeJSON(cfhttp.filecontent);

		if ( canInfo ) { arguments.logger.info( "Subscriber SET:  #result.email#" ); }

		return true;
	}


	public array function getUnsubscriberList( any logger ) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canInfo         = loggerAvailable && arguments.logger.canInfo();

		var methodName      = "lists/members";

		return  _getMailChimpData( methodName = methodName, logger = arguments.logger, status="unsubscribed" );
	}


// PRIVATE METHODS

	private array function _getMailChimpData( required string methodName, any logger, any status ) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canError        = loggerAvailable && arguments.logger.canError();
		var canInfo         = loggerAvailable && arguments.logger.canInfo();

		var serviceURL = _getServiceURL() & arguments.methodName;

		if ( canInfo ) { arguments.logger.info( "Retreiving by method #methodName#" ); }

		http url ="#serviceURL#" method="get" name="list"{
			httpparam name="apikey" value=_getAPIKey()     type="url";
			httpparam name="id"     value=_getListID()     type="url";
			httpparam name="status" value=arguments.status type="url";
		}

		if( StructKeyExists(cfhttp,"errorDetail") && cfhttp.errorDetail != "" ){
			if( canError ){
				arguments.logger.error( "Error running method: #methodName#. Error statusCode: #cfhttp.error.statusCode#. Error detail: #cfhttp.error.errorDetail#" );
				return arrayNew(1);
			}
		}

		return DeserializeJSON(cfhttp.filecontent).data;
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

	private any function _getListID() output=false {
		return _listID;
	}
	private void function _setListID() output=false {

		var subscriberList = _getSysConfigService().getSetting('mailchimp','subscriber_list');
		_listID            =  "";

		if( subscriberList.len() ){
		 	_listID =  _getMailchimpListDao().selectData( selectField = [ 'mailchimp_list_id' ], id = subscriberList).mailchimp_list_id;
		}

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