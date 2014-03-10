	create or replace package body snaplogr_ui

	as

		function allowed
		return boolean
		
		as

			v_cookie_val		owa_cookie.cookie;
			logrid				varchar2(500);
			logrverify			varchar2(500);
		
		begin
		
			dbms_application_info.set_action('allowed');

			v_cookie_val  := owa_cookie.get('snaplogr');
			if v_cookie_val.num_vals > 0 then
				logrid := v_cookie_val.vals(1);
				return true;
			else
				return false;
			end if;
		
			dbms_application_info.set_action(null);
		
			exception
				when others then
					dbms_application_info.set_action(null);
					return false;
		
		end allowed;

		function get_curr_id
		return varchar2

		as

			v_cookie_val		owa_cookie.cookie;
			logrid				varchar2(500) := 'none';

		begin

			v_cookie_val  := owa_cookie.get('snaplogr');
			if v_cookie_val.num_vals > 0 then
				logrid := v_cookie_val.vals(1);
			end if;

			return logrid;

		end get_curr_id;

		procedure snaplogr_formatters
		
		as
		
		begin
		
			dbms_application_info.set_action('snaplogr_formatters');

			-- Helper function to create content div
			htp.p('
				function createContent(i, c, s) {
					var contentdiv = $("<div/>", {
						"class": "snaps",
						"id": "snap" + i,
						html: c
					});

					/* var snapContent = ''This entry will snap at - <span class="snaptimeleft">'' + s + ''</span>'';

					var snaptimediv = $("<div/>", {
						"class": "snaps_destruct",
						html: snapContent
					}).appendTo(contentdiv); */

					return contentdiv;
				}
			');

			-- Simple string formatter
			htp.p('
				function sl_string(i, c, s) {
					return createContent(i, c, s);
				}
			');

			-- List of strings formatter
			htp.p('
				function sl_stringlist(i, c, s) {
					items = [];
					for(var x=0; x<c.length; x++){
						items.push(''<li>'' + c[x] + ''</li>'');
					}

					// Make ul
					var ul = $("<ul/>", {
							"class": "stringlist",
							html: items.join("")
						});

					return createContent(i, ul, s);
				}
			');

			-- List of errors formatter
			htp.p('
				function sl_error(i, c, s) {
					errors = [];
					for(var x=0; x<c.length; x++) {
						errors.push(''<div class="sl_error"><span class="label label-info">'' + c[x].errnum + ''</span> '' + c[x].errmsg + ''</div>'');
					}

					var all_errors = $("<div/>", {
							html: errors.join("")
						});

					return createContent(i, all_errors, s);
				}
			');

			-- Runstats display
			htp.p('
				function sl_runstat(i, c, s) {

					return createContent(i, "Hello World", s);
				}
			');
		
			dbms_application_info.set_action(null);
		
			exception
				when others then
					dbms_application_info.set_action(null);
					raise;
		
		end snaplogr_formatters;

		procedure html_head (
			page_in						in				varchar2 default null
		)
		
		as
		
		begin
		
			dbms_application_info.set_action('html_head');

			htp.p('
				<html>
					<head>
						<title>SnapLogr</title>

						<link href="http://netdna.bootstrapcdn.com/bootstrap/3.0.3/css/bootstrap.min.css" rel="stylesheet">
						<script src="http://code.jquery.com/jquery-1.10.1.min.js"></script>
						<script src="http://code.jquery.com/jquery-migrate-1.2.1.min.js"></script>
						<script src="snaplogr_ui.snaplogr_formatters"></script>
			');

			if page_in = 'snaps' and allowed then
				htp.p('
					<!-- Load the snaps library and scripts -->
					<script>
						function snapRemove(idin) {
							$("#snap" + idin).remove();
						};

						function addMinutes(minutes) {
							var nd = new Date();
							var sd = new Date(nd.getTime() + minutes * 60000);
							return sd.getHours() + ":" + sd.getMinutes() + ":" + sd.getSeconds();
						}

						function loadSnaps() {
							$.getJSON( "snaplogr_ui.ajax_snaps", function( data ) {
							  var items = [];
							  $.each( data, function(index) {
							  	var snaptime = addMinutes(2);
							    // items.push(''<div class="snaps" id="snap'' + this.id + ''">'' + this.content + ''<div class="snaps_destruct">This entry will snap at - <span class="snaptimeleft">'' + snaptime + ''</span></div></div>'');
							    var itemdata = window["sl_" + this.type](this.id, this.content, snaptime);
							    items.push(itemdata)
							    var t = "snapRemove(" + this.id + ")";
							    setTimeout(t,120000);
							  });
							 
							  $("#snaps_here").append(items);
							});
						}

						function initSnaps() {
							loadSnaps();
							setInterval(function() {loadSnaps();}, 10000);
						};
					</script>
				');
			end if;

			htp.p('
						<style>
							body {
								background-color: #333333;
								color: white;
								font-family:Arial,sans-serif;
							}

							.snaps {
								margin-left: 10px; 
								margin-top: 10px; 
								background-color: #5C5C5C; 
								font-size: 16px; 
								font-weight: bold; 
								padding: 10px;
								padding-left: 20px;
								color: #FFFFCC;
							}

							.snaps_destruct {
								margin: 5px; 
								padding: 5px; 
								background-color: #333333; 
								font-size: 10px;
								font-weight: normal; 
								color: #5C5C5C;
							}

							.snaptimeleft {
								color: #FFFFCC;
								font-weight: bold;
							}

							.sl_error {
								margin-bottom: 5px;
							}
						</style>
					</head>
					<body>
			');
		
			dbms_application_info.set_action(null);
		
			exception
				when others then
					dbms_application_info.set_action(null);
					raise;
		
		end html_head;

		procedure html_end (
			page_in						in				varchar2 default null
		)
		
		as
		
		begin
		
			dbms_application_info.set_action('html_end');

			htp.p('
					</body>
				</html>
			');
		
			dbms_application_info.set_action(null);
		
			exception
				when others then
					dbms_application_info.set_action(null);
					raise;
		
		end html_end;

		procedure startp (
			page_in						in				varchar2 default null
		)
		
		as
		
		begin
		
			dbms_application_info.set_action('start');

			html_head;

			htp.p('
				<div class="row" style="margin-top: 15px;">
					<div class="col-md-4">
					</div>
					<div class="col-md-4">
						<div class="text-center">
							<form role="form" action="snaplogr_ui.validate" method="post">
	  							<div class="form-group">
	    							<label for="user_email">Email address</label>
	    							<input type="email" class="form-control" id="user_email" name="user_email" placeholder="Enter email">
	  							</div>
	  							<div class="form-group">
	  							  <label for="user_pass">Password</label>
	  							  <input type="password" class="form-control" id="user_pass" name="user_pass" placeholder="Password">
	  							</div>
								<button type="submit" class="btn btn-default">Submit</button>
							</form>
						</div>
					</div>
					<div class="col-md-4">
					</div>
				</div>
			');

			html_end;
		
			dbms_application_info.set_action(null);
		
			exception
				when others then
					dbms_application_info.set_action(null);
					raise;
		
		end startp;

		procedure ajax_snaps
		
		as

			snap_data					clob;

			cursor get_snaps(id_in varchar2) is
				select
					snaplog
				from
					table(snaplogr.snapit(id_in));

			ecode NUMBER;
 			emesg VARCHAR2(200);
		
		begin
		
			dbms_application_info.set_action('ajax_snaps');

			if allowed then

				open get_snaps(get_curr_id);
				fetch get_snaps into snap_data;
				close get_snaps;

				-- owa_util.mime_header('application/json', false);

				htp.p(snap_data);

			end if;
		
			dbms_application_info.set_action(null);
		
			exception
				when others then
					dbms_application_info.set_action(null);
					ecode := SQLCODE;
  					emesg := SQLERRM;
					htp.p(emesg);
		
		end ajax_snaps;

		procedure snaps (
			page_in						in				varchar2 default null
		)
		
		as

			cursor get_snaps(id_in varchar2) is
				select
					snaplog
				from
					table(snaplogr.snapit(id_in));
		
		begin
		
			dbms_application_info.set_action('snaps');

			html_head('snaps');

			if allowed then

				htp.p('
					<div class="row" style="margin-top: 15px;">
						<div class="col-md-3">
						</div>
						<div class="col-md-6">
							<div id="snaps_here">
							</div>
						</div>
						<div class="col-md-3">
						</div>
					</div>
					<script>
						initSnaps();
					</script>
				');

			end if;

			html_end('snaps');

			commit;
		
			dbms_application_info.set_action(null);
		
			exception
				when others then
					rollback;
					dbms_application_info.set_action(null);
					raise;
		
		end snaps;

		procedure location (
			loc_in						in				number default 0
		)
		
		as
		
		begin
		
			dbms_application_info.set_action('location');

			if loc_in = 0 then
				htp.p('
					<html>
						<head>
							<title>Processing login information ..</title>
							<meta HTTP-EQUIV="REFRESH" content="0; url=snaplogr_ui.snaps">
						</head>
						<body>
						</body>
					</html>
				');
			else
				htp.p('
					<html>
						<head>
							<title>Processing login information ..</title>
							<meta HTTP-EQUIV="REFRESH" content="0; url=snaplogr_ui.startp">
						</head>
						<body>
						</body>
					</html>
				');
			end if;
		
			dbms_application_info.set_action(null);
		
			exception
				when others then
					dbms_application_info.set_action(null);
					raise;
		
		end location;

		procedure validate (
			user_email						in				varchar2
			, user_pass						in				varchar2
		)
		
		as

			snaplogr_val					varchar2(500);
		
		begin
		
			dbms_application_info.set_action('validate');

			if snaplogr.compare_phrase(user_email, user_pass) then
				snaplogr_val := snaplogr.get_client_id(user_email);
				-- Set the cookie and run location
				owa_util.mime_header('text/html', false);
				owa_cookie.send('snaplogr', snaplogr_val);
				owa_util.http_header_close;
				snaplogr_ui.location;
			else
				snaplogr_ui.location(1);
			end if;
		
			dbms_application_info.set_action(null);
		
			exception
				when others then
					dbms_application_info.set_action(null);
					location(1);
		
		end validate;

	begin

		dbms_application_info.set_client_info('snaplogr_ui');
		dbms_session.set_identifier('snaplogr_ui');

	end snaplogr_ui;
	/