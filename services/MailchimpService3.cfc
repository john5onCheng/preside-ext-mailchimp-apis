/**
* @singleton
*/
component {

// CONSTRUCTOR
	/**
	 * @mailchimpAPIWrapperService.inject mailchimpAPIWrapperService3
	 * @mailchimpListDao.inject           presidecms:object:mailchimp_list
	 */

	public any function init(
		  required any mailchimpAPIWrapperService
		, required any mailchimpListDao
	 ) {
		_setMailchimpListDao(           arguments.mailchimpListDao            );
		_setMailchimpAPIWrapperService( arguments.mailchimpAPIWrapperService  );

		return this;
	}

// PUBLIC API METHODS
	public boolean function getAllListsToPreside( any logger, string fields="lists.id,lists.web_id,lists.name,lists.stats.member_count,lists.stats.unsubscribe_count" ) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canInfo         = loggerAvailable && arguments.logger.canInfo();
		var canError        = loggerAvailable && arguments.logger.canError();
		var itemData        = "";
		var resultData      = [];
		var result          = _getMailchimpAPIWrapperService().getAllLists( fields=arguments.fields );
		var resultContent   = _processResult( result = result , logger = arguments.logger );

		if( StructKeyExists(result,"errorDetail") && result.errorDetail != "" ){
			if( canError ){
				arguments.logger.error( "Error processing getAllListsToPreside method. Error [#SerializeJson(resultContent)#]" );
			}
			return false;
		}

		if( structKeyExists( resultContent, "lists" ) ){
			resultData = resultContent.lists;
		}

		if( arrayLen( resultData ) ){
			loop array="#resultData#" item="itemData"{
				var stats         = itemData.stats ?: {};
				var mailChimpData = {
					  id                 = itemData.id
					, web_id             = itemData.web_id
					, label              = itemData.name
					, member_count       = stats.member_count      ?: 0
					, unsubscribe_count  = stats.unsubscribe_count ?: 0
				}

				if( !_getMailchimpListDao().dataExists( filter={ id = itemData.id } ) ){
					 _getMailchimpListDao().insertData( mailChimpData );
					 if ( canInfo ) { arguments.logger.info( "Added list (id: #itemData.id# ) #itemData.name# to preside" ); }
				} else {
					 _getMailchimpListDao().updateData( filter= { id = itemData.id  } , data = mailChimpData );
					 if ( canInfo ) { arguments.logger.info( "Updated list (id: #itemData.id# ) #itemData.name# to preside" ); }
				}
			}

			if ( canInfo ) { arguments.logger.info( "GET all mailchimp lists to preside completed" ); }

			return true;
		}

		return false;
	}

	public array function getListMembers(
		  required string  listID
		,          string  fields
		,          string  exclude_fields
		,          string  status
		,          numeric count
		,          numeric offset
		,          any     logger
	) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canInfo         = loggerAvailable && arguments.logger.canInfo();
		var canError        = loggerAvailable && arguments.logger.canError();
		var result          = _getMailchimpAPIWrapperService().getListMembers( list_id=arguments.listID, fields=arguments.fields, exclude_fields=arguments.exclude_fields, status=arguments.status, count=arguments.count, offset=arguments.offset );
		var resultContent   = _processResult( result=result, logger=arguments.logger);

		if( StructKeyExists( result, "errorDetail" ) && result.errorDetail != "" ){
			if( canError ){
				arguments.logger.error( "Error processing getListMembers method. Error [#SerializeJson( resultContent )#]" );
			}
			return [];
		}

		return resultContent.members ?: [];
	}

	public struct function createNewInterestCategory(
		  required string  listID
		, required string  title
		, required string  type
		,          numeric displayOrders
		,          any     logger
	) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canInfo         = loggerAvailable && arguments.logger.canInfo();
		var canError        = loggerAvailable && arguments.logger.canError();
		var result          = _getMailchimpAPIWrapperService().createNewInterestCategory( list_id=arguments.listID, title=arguments.title, type=arguments.type, display_orders=arguments.displayOrders );
		var resultContent   = _processResult( result=result, logger=arguments.logger );

		if( StructKeyExists( result, "errorDetail" ) && result.errorDetail != "" ){
			if( canError ){
				arguments.logger.error( "Error processing createNewInterestCategory method. Error [#SerializeJson( resultContent )#]" );
			}
			return {};
		}

		return resultContent;
	}

	public struct function createNewInterest(
		  required string  listID
		, required string  interestCategoryId
		, required string  name
		,          numeric displayOrders
		,          any     logger
	) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canInfo         = loggerAvailable && arguments.logger.canInfo();
		var canError        = loggerAvailable && arguments.logger.canError();
		var result          = _getMailchimpAPIWrapperService().createNewInterest( list_id=arguments.listID, interest_category_id=arguments.interestCategoryId, name=arguments.name, display_orders=arguments.displayOrders );
		var resultContent   = _processResult( result=result, logger=arguments.logger );

		if( StructKeyExists( result, "errorDetail" ) && result.errorDetail != "" ){
			if( canError ){
				arguments.logger.error( "Error processing createNewInterest method. Error [#SerializeJson( resultContent )#]" );
			}
			return {};
		}

		return resultContent;
	}

	public struct function createNewSegment(
		  required string listID
		, required string name
		,          array  staticSegment
		,          struct options
		,          any    logger
	) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canInfo         = loggerAvailable && arguments.logger.canInfo();
		var canError        = loggerAvailable && arguments.logger.canError();
		var result          = _getMailchimpAPIWrapperService().createNewSegment( list_id=arguments.listID, name=arguments.name, static_segment=arguments.staticSegment, options=arguments.options );
		var resultContent   = _processResult( result=result, logger=arguments.logger );

		if( StructKeyExists( result, "errorDetail" ) && result.errorDetail != "" ){
			if( canError ){
				arguments.logger.error( "Error processing createNewSegment method. Error [#SerializeJson( resultContent )#]" );
			}
			return {};
		}

		return resultContent;
	}

	public array function getListCategories(
		  required string  listID
		,          string  fields
		,          any     logger
	) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canError        = loggerAvailable && arguments.logger.canError();

		var result          = _getMailchimpAPIWrapperService().getListCategories( list_id=arguments.listID, fields=arguments.fields );
		var resultContent   = _processResult( result=result, logger=arguments.logger );

		if( StructKeyExists( result, "errorDetail" ) && result.errorDetail != "" ){
			if( canError ){
				arguments.logger.error( "Error processing getListCategories method. Error [#SerializeJson( resultContent )#]" );
			}
			return [];
		}

		return resultContent.categories ?: [];
	}

	public array function getListInterestCategories(
		  required string  listID
		, required string  interestCategoryId
		,          string  fields
		,          any     logger
	) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canError        = loggerAvailable && arguments.logger.canError();

		var result          = _getMailchimpAPIWrapperService().getListInterestCategories( list_id=arguments.listID, interest_category_id=arguments.interestCategoryId, fields=arguments.fields );
		var resultContent   = _processResult( result=result, logger=arguments.logger );

		if( StructKeyExists( result, "errorDetail" ) && result.errorDetail != "" ){
			if( canError ){
				arguments.logger.error( "Error processing getListInterestCategories method. Error [#SerializeJson( resultContent )#]" );
			}
			return [];
		}

		return resultContent.interests ?: [];
	}

	public struct function batchSubscribeUnsubscribeListMember(
		  required string  listID
		, required array   members
		,          boolean updateExisting
		,          any     logger
	) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canError        = loggerAvailable && arguments.logger.canError();

		var result          = _getMailchimpAPIWrapperService().batchSubscribeUnsubscribeListMember( list_id=arguments.listID, members=arguments.members, update_existing=arguments.updateExisting );
		var resultContent   = _processResult( result=result, logger=arguments.logger );

		if( StructKeyExists( result, "errorDetail" ) && result.errorDetail != "" ){
			if( canError ){
				arguments.logger.error( "Error processing batchSubscribeUnsubscribeListMember method. Error [#SerializeJson( resultContent )#]" );
			}
			return {};
		}

		return resultContent;
	}

	public struct function addOrUpdateMemberToList(
		  required string  listID
		, required string  emailAddress
		,          string  status
		,          struct  mergeFields
		,          struct  interests
		,          any     logger
	) {

		var loggerAvailable = StructKeyExists( arguments, "logger" );
		var canError        = loggerAvailable && arguments.logger.canError();

		var result          = _getMailchimpAPIWrapperService().addOrUpdateMemberToList( list_id=arguments.listID, subscriber_hash=hash( arguments.emailAddress ), email_address=arguments.emailAddress, interests=arguments.interests, status=arguments.status, merge_fields=arguments.mergeFields );
		var resultContent   = _processResult( result=result, logger=arguments.logger );

		if( StructKeyExists( result, "errorDetail" ) && result.errorDetail != "" ){
			if( canError ){
				arguments.logger.error( "Error processing addOrUpdateMemberToList method. Error [#SerializeJson( resultContent )#]" );
			}
			return {};
		}

		return resultContent;
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

}