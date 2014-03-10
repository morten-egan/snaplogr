create table snaplogr_clients (
	id						varchar2(500)			constraint snaplogr_clients_pk primary key
	, phrase				varchar2(500)			constraint snaplogr_clients_phrase_nn not null
	, email					varchar2(500)			constraint snaplogr_clients_email_nn not null
);

create table snaplogr_snap_types (
	id						number					constraint snaplogr_types_pk primary key
	, name					varchar2(250)			constraint snaplogr_types_name_nnu not null unique
	, description			clob
);

insert into snaplogr_snap_types values (1, 'string', 'Simple log string message. No formatting.');
insert into snaplogr_snap_types values (2, 'stringlist', 'A list of messages');
insert into snaplogr_snap_types values (3, 'error', 'One or more errors');
insert into snaplogr_snap_types values (4, 'runstat', 'Runstats of 2 runs');

create sequence snap_seq
increment by 1
start with 100
cache 200
maxvalue 999999999999
cycle;

create table snaplogr_snaps (
	id						number					constraint snaplogr_snaps_pk primary key
	, client_id				varchar2(500)			constraint snaplogr_snaps_client_ref references snaplogr_clients(id)
	, type_id				number					constraint snaplogr_snaps_type_ref references snaplogr_snap_types(id)
	, snap					clob
);