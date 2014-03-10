create or replace package body snaplogr

as

	function validate_id (
		id_in						in				varchar2
	)
	return boolean
	
	as
	
		l_ret_val			boolean := false;
		val_count			number;
	
	begin
	
		dbms_application_info.set_action('validate_id');

		select count(*)
		into val_count
		from snaplogr_clients
		where id = id_in;

		if val_count = 1 then
			l_ret_val := true;
		end if;

		dbms_application_info.set_action(null);
	
		return l_ret_val;
	
		exception
			when others then
				dbms_application_info.set_action(null);
				raise;
	
	end validate_id;

	function get_client_id (
		client_email						in				varchar2
	)
	return varchar2
	
	as
	
		l_ret_val			varchar2(4000);
	
	begin
	
		dbms_application_info.set_action('get_client_id');

		-- Use simple hash to generate client id
		l_ret_val := replace(utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(dbms_obfuscation_toolkit.md5(input_string => client_email)))), '==');
	
		dbms_application_info.set_action(null);
	
		return l_ret_val;
	
		exception
			when others then
				dbms_application_info.set_action(null);
				raise;
	
	end get_client_id;

	function compare_phrase (
		user_email						in				varchar2
		, phrase_in						in				varchar2
	)
	return boolean
	
	as
	
		l_ret_val			boolean := false;
		transmogryph		varchar2(500);
		real_phrase			varchar2(500);
	
	begin
	
		dbms_application_info.set_action('compare_phrase');

		transmogryph := get_client_id(phrase_in);

		select phrase
		into real_phrase
		from snaplogr_clients
		where email = user_email;

		if transmogryph = real_phrase then
			l_ret_val := true;
		end if;
	
		dbms_application_info.set_action(null);
	
		return l_ret_val;
	
		exception
			when others then
				dbms_application_info.set_action(null);
				raise;
	
	end compare_phrase;

	procedure create_snaplogr_user (
		user_email						in				varchar2
		, user_pass						in				varchar2
	)
	
	as
	
	begin
	
		dbms_application_info.set_action('create_snaplogr_user');

		insert into snaplogr_clients (
			id
			, phrase
			, email
		) values (
			get_client_id(user_email)
			, get_client_id(user_pass)
			, user_email
		);
	
		dbms_application_info.set_action(null);
	
		exception
			when others then
				dbms_application_info.set_action(null);
				raise;
	
	end create_snaplogr_user;

	procedure snap (
		snap_content					in				clob
	)
	
	as

		snap_json						json;
		type_val_num					number := null;
	
	begin
	
		dbms_application_info.set_action('snap');

		-- Parse input to json
		snap_json := json(snap_content);

		if validate_id(json_ext.get_string(snap_json, 'id')) then
			if snap_json.exist('content') then
				if snap_json.exist('type') then
					if snap_json.get('type').is_number then
						type_val_num := json_ext.get_number(snap_json, 'type');
					elsif snap_json.get('type').is_string then
						select id
						into type_val_num
						from snaplogr_snap_types
						where name = json_ext.get_string(snap_json, 'type');
					else
						type_val_num := 1;
					end if;
					if type_val_num is not null then
						if type_val_num = 1 then
							insert into snaplogr_snaps (
								id
								, client_id
								, type_id
								, snap
							) values (
								snap_seq.nextval
								, json_ext.get_string(snap_json, 'id')
								, type_val_num
								, snap_json.get('content').get_string
							);
						else
							insert into snaplogr_snaps (
								id
								, client_id
								, type_id
								, snap
							) values (
								snap_seq.nextval
								, json_ext.get_string(snap_json, 'id')
								, type_val_num
								, snap_json.get('content').to_char
							);
						end if;

						commit;
					end if;
				end if;
			end if;
		end if;
	
		dbms_application_info.set_action(null);
	
		exception
			when others then
				dbms_application_info.set_action(null);
				raise;
	
	end snap;

	function snapit (
		client_in						in				varchar2
	)
	return snap_rec_tab
	pipelined
	
	as
	
		-- Because we delete when we select, we are an autonomous transaction
		pragma							autonomous_transaction;
		row_data						snap_rec;
		snap_json						json;
		snap_list						json_list := json_list();
		temp_clob						clob := empty_clob();
		data_val						clob;

		cursor get_snaps is
			select
				ss.id
				, sst.name
				, ss.snap
			from 
				snaplogr_snaps ss
				, snaplogr_snap_types sst
			where 
				ss.client_id = client_in
			and
				ss.type_id = sst.id
			order by
				ss.id desc;

		type snaplist is table of get_snaps%rowtype index by pls_integer;
		snaps 							snaplist;
	
	begin
	
		dbms_application_info.set_action('snapit');

		open get_snaps;
		loop
			fetch get_snaps
			bulk collect
			into snaps
			limit 20;

			for indx in 1..snaps.count loop
				snap_json := json();
				data_val := snaps(indx).snap;
				snap_json.put('id', snaps(indx).id);
				snap_json.put('type', snaps(indx).name);
				if snaps(indx).name = 'string' then
					snap_json.put('content', data_val);
				elsif substr(data_val,1,1) = '[' then
					snap_json.put('content', json_list(data_val));
				else
					snap_json.put('content', json(data_val));
				end if;
				snap_list.append(snap_json.to_json_value);
				delete from snaplogr_snaps where id = snaps(indx).id;
			end loop;

			exit when snaps.count < 20;
		end loop;
		close get_snaps;
		commit;

		dbms_lob.createtemporary(temp_clob, true);
		snap_list.to_clob(temp_clob);

		row_data.snaplog := temp_clob;

		pipe row(row_data);

		dbms_lob.freetemporary(temp_clob);
	
		dbms_application_info.set_action(null);
	
		return;
	
	end snapit;

begin

	dbms_application_info.set_client_info('snaplogr');
	dbms_session.set_identifier('snaplogr');

end snaplogr;
/