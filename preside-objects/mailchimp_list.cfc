/**
* @dataManagerGroup      mailchimp
* @dataManagerGridFields label,mailchimp_list_id,member_count,unsubscribe_count,datecreated,datemodified
*
*/
component output=false  {
	property name="web_id"               type="string"  dbtype="varchar"   required=true ;
	property name="mailchimp_list_id"    type="string"  dbtype="varchar"   required=true ;
	property name="member_count"         type="numeric" dbtype="numeric"  ;
	property name="unsubscribe_count"    type="numeric" dbtype="numeric"  ;
}