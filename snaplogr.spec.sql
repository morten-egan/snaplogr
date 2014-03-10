create or replace package snaplogr

as

	/** This is the main snaplogr server package. It handles the core communication with snaplogr clients
	* @author Morten Egan
	* @version 0.0.1
	* @project snaplogr
	*/
	p_version		varchar2(50) := '0.0.1';

	function compare_phrase (
		user_email						in				varchar2
		, phrase_in						in				varchar2
	)
	return boolean;

	/** Return a new client id for snaplogr
	* @author Morten Egan
	* @param client_email The email address of the client
	*/
	function get_client_id (
		client_email						in				varchar2
	)
	return varchar2;

	/** Insert snap into the snap table
	* @author Morten Egan
	* @param client_id The ID of the client snapping
	*/
	procedure snap (
		snap_content					in				clob
	);

	/** Create a snaplogr user
	* @author Morten Egan
	* @param user_email The email address of the user
	*/
	procedure create_snaplogr_user (
		user_email						in				varchar2
		, user_pass						in				varchar2
	);

	/** Return the current list of snaps, as a pipelined function. It will delete from the table at the
	* same time, so once selected, the client will show them and they will not exist once logged out.
	* @author Morten Egan
	* @param client_in The client to get current snaps from.
	*/
	type snap_rec is record (
		snaplog						clob
	);
	type snap_rec_tab is table of snap_rec;

	function snapit (
		client_in						in				varchar2
	)
	return snap_rec_tab
	pipelined;

end snaplogr;
/