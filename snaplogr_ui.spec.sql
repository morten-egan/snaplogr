create or replace package snaplogr_ui

as

	/** This is the UI package for the snaplogr site.
	* @author Morten Egan
	* @version 0.0.1
	* @project snaplogr
	*/
	p_version		varchar2(50) := '0.0.1';

	/** The start and login page
	* @author Morten Egan
	* @param page_in The page we are entering
	*/
	procedure startp (
		page_in						in				varchar2 default null
	);

	/** Validate login
	* @author Morten Egan
	* @param user_email The email the user has registered with
	*/
	procedure validate (
		user_email						in				varchar2
		, user_pass						in				varchar2
	);

	/** Show snaps of validated user
	* @author Morten Egan
	* @param page_in Page to show
	*/
	procedure snaps (
		page_in						in				varchar2 default null
	);

	/** AJAX call to get snaps
	* @author Morten Egan
	* @param snap_id The id to get snaps from
	*/
	procedure ajax_snaps;

	/** Load the formatter functions for snaplogr
	* @author Morten Egan
	* @param parm_name A description of the parameter
	*/
	procedure snaplogr_formatters;

end snaplogr_ui;
/